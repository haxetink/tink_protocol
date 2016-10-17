package tink.protocol.mongodb;

import bson.Bson;
import bson.BsonDocument;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import haxe.io.BytesBuffer;

abstract Message(MessageEnum) from MessageEnum to MessageEnum {
	@:to
	public function toBytes() {
		var opcode, bodyBytes;
		switch this {
			case Update(body):
				bodyBytes = body.toBytes();
				opcode = OP_UPDATE;
			case Insert(body):
				bodyBytes = body.toBytes();
				opcode = OP_INSERT;
			case Query(body):
				bodyBytes = body.toBytes();
				opcode = OP_QUERY;
			case GetMore(body):
				bodyBytes = body.toBytes();
				opcode = OP_GET_MORE;
			case Delete(body):
				bodyBytes = body.toBytes();
				opcode = OP_DELETE;
			case KillCursors(body):
				bodyBytes = body.toBytes();
				opcode = OP_KILL_CURSORS;
			case Response(body):
				bodyBytes = body.toBytes();
				opcode = 0; // OP_RESPONSE;
		}
		var out = new BytesBuffer();
		out.add(new MessageHeader(bodyBytes.length + 16, RequestCounter.next(), 0, opcode).toBytes());
		out.add(bodyBytes);
		return out.getBytes();
	}
}

enum MessageEnum {
	Update(message:UpdateMessageBody);
	Insert(message:InsertMessageBody);
	Query(message:QueryMessageBody);
	GetMore(message:GetMoreMessageBody);
	Delete(message:DeleteMessageBody);
	KillCursors(message:KillCursorsMessageBody);
	Response(message:ResponseMessageBody);
}

class RequestCounter {
	static var counter = Std.random(1 << 32);
	public static function next() {
		counter = (counter + 1) % 1 << 32;
		return counter;
	}
}

@:forward
abstract ResponseMessage(MessageObject<ResponseMessageBody>) from MessageObject<ResponseMessageBody> to MessageObject<ResponseMessageBody> {
	
	@:from
	public static function fromBytes(bytes:Bytes):ResponseMessage {
		var input = new BytesInput(bytes);
		
		input.position = 16; // skip header
		var responseFlags = input.readInt32();
		var cursorId = {
			var high = input.readInt32();
			var low = input.readInt32();
			Int64.make(high, low);
		}
		var startingFrom = input.readInt32();
		var numberReturned = input.readInt32();
		var documents = Bson.decodeMultiple(input.readAll(), numberReturned);
		
		var header = MessageHeader.fromBytes(bytes);
		var body = new ResponseMessageBody(responseFlags, cursorId, startingFrom, numberReturned, documents);
		return new MessageObject(header, body);
	}
	
	@:to
	public inline function toMessage():Message
		return Response(this.body);
}

class MessageHeader {
	public var messageLength:Int;
	public var requestID:Int;
	public var responseTo:Int;
	public var opCode:Opcode;
	
	public function new(messageLength, requestID, responseTo, opCode) {
		this.messageLength = messageLength;
		this.requestID = requestID;
		this.responseTo = responseTo;
		this.opCode = opCode;
	}
	
	public static function fromBytes(bytes:Bytes) {
		var input = new BytesInput(bytes);
		
		var messageLength = input.readInt32();
		var requestID = input.readInt32();
		var responseTo = input.readInt32();
		var opCode = input.readInt32();
		
		return new MessageHeader(messageLength, requestID, responseTo, opCode);
	}
	
	public function toBytes():Bytes {
		var out = new BytesOutput();
		out.writeInt32(messageLength);
		out.writeInt32(requestID);
		out.writeInt32(responseTo);
		out.writeInt32(opCode);
		return out.getBytes();
	}
}

class MessageObject<T> {
	public var header:MessageHeader;
	public var body:T;
	
	public function new(header, body) {
		this.header = header;
		this.body = body;
	}
}

class UpdateMessageBody {
	public var fullCollectionName:String;
	public var flags:Int;
	public var selector:BsonDocument;
	public var update:BsonDocument;
	
	public function new(fullCollectionName, flags, selector, update) {
		this.fullCollectionName = fullCollectionName;
		this.flags = flags;
		this.selector = selector;
		this.update = update;
	}
	
	public function toBytes():Bytes {
		var out = new BytesOutput();
		out.writeInt32(0); // reserved
		out.writeString(fullCollectionName);
		out.writeByte(0x00);
		out.writeInt32(flags);
		out.write(Bson.encode(selector));
		out.write(Bson.encode(update));
		return out.getBytes();
	}
}

class InsertMessageBody {
	public var flags:Int;
	public var fullCollectionName:String;
	public var documents:Array<BsonDocument>;
	
	public function new(flags, fullCollectionName, documents) {
		this.flags = flags;
		this.fullCollectionName = fullCollectionName;
		this.documents = documents;
	}
	
	public function toBytes():Bytes {
		var out = new BytesOutput();
		out.writeInt32(flags);
		out.writeString(fullCollectionName);
		out.writeByte(0x00);
		out.write(Bson.encodeMultiple(documents));
		return out.getBytes();
	}
}

class QueryMessageBody {
	public var flags:Int;
	public var fullCollectionName:String;
	public var numberToSkip:Int;
	public var numberToReturn:Int;
	public var query:BsonDocument;
	public var projection:BsonDocument;
	
	public function new(flags, fullCollectionName, numberToSkip, numberToReturn, query, ?projection) {
		this.flags = flags;
		this.fullCollectionName = fullCollectionName;
		this.numberToSkip = numberToSkip;
		this.numberToReturn = numberToReturn;
		this.query = query;
		this.projection = projection;
	}
	
	public function toBytes():Bytes {
		var out = new BytesOutput();
		out.writeInt32(flags);
		out.writeString(fullCollectionName);
		out.writeByte(0x00);
		out.writeInt32(numberToSkip);
		out.writeInt32(numberToReturn);
		
		if(query == null) query = {};
		out.write(Bson.encode(query));
		
		if(projection != null)
			out.write(Bson.encode(projection));
			
		return out.getBytes();
	}
}

class GetMoreMessageBody {
	public var fullCollectionName:String;
	public var numberToReturn:Int;
	public var cursorId:Int64;
	
	public function new(fullCollectionName, numberToReturn, cursorId) {
		this.fullCollectionName = fullCollectionName;
		this.numberToReturn = numberToReturn;
		this.cursorId = cursorId;
	}
	
	public function toBytes():Bytes {
		var out = new BytesOutput();
		out.writeInt32(0); // reserved
		out.writeString(fullCollectionName);
		out.writeByte(0x00);
		out.writeInt32(numberToReturn);
		out.writeInt32(cursorId.high);
		out.writeInt32(cursorId.low);
		return out.getBytes();
	}
}

class DeleteMessageBody {
	public var flags:Int;
	public var fullCollectionName:String;
	public var selector:BsonDocument;
	
	public function new(flags, fullCollectionName, selector) {
		this.flags = flags;
		this.fullCollectionName = fullCollectionName;
		this.selector = selector;
	}
	
	public function toBytes():Bytes {
		var out = new BytesOutput();
		out.writeInt32(0); // reserved
		out.writeString(fullCollectionName);
		out.writeByte(0x00);
		out.writeInt32(flags);
		if(selector == null) selector = new BsonDocument();
		out.write(Bson.encode(selector));
		return out.getBytes();
	}
}

class KillCursorsMessageBody {
	public var numCursors:Int;
	public var cursorIds:Array<Int64>;
	
	public function new(numCursors, cursorIds) {
		this.numCursors = numCursors;
		this.cursorIds = cursorIds;
	}
	
	public function toBytes():Bytes {
		var out = new BytesOutput();
		out.writeInt32(0); // reserved
		out.writeInt32(cursorIds.length);
		
		for(id in cursorIds) {
			out.writeInt32(id.high);
			out.writeInt32(id.low);
		}
		
		return out.getBytes();
	}
}

class ResponseMessageBody {
	public var responseFlags:Int;
	public var cursorId:Int64;
	public var startingFrom:Int;
	public var numberReturned:Int;
	public var documents:Array<BsonDocument>;
	
	public function new(responseFlags, cursorId, startingFrom, numberReturned, documents) {
		this.responseFlags = responseFlags;
		this.cursorId = cursorId;
		this.startingFrom = startingFrom;
		this.numberReturned = numberReturned;
		this.documents = documents;
	}
	
	public function toBytes():Bytes {
		return Bytes.alloc(0); // TODO: well, seems we will never construct a reponse message
	}
}

@:enum
abstract Opcode(Int) from Int to Int
{
	var OP_REPLY        = 1; // used by server
	var OP_MSG          = 1000; // not used
	var OP_UPDATE       = 2001;
	var OP_INSERT       = 2002;
	// var OP_GET_BY_OID   = 2003;
	var OP_QUERY        = 2004;
	var OP_GET_MORE     = 2005;
	var OP_DELETE       = 2006;
	var OP_KILL_CURSORS = 2007;
}

