package tink.protocol.rethinkdb;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

using StringTools;
using tink.CoreApi;

@:forward
abstract Query(QueryBase) from QueryBase to QueryBase {
	
	@:from
	public static function ofEnum(e:QueryEnum):Query {
		var token = switch e {
			case QStart(query): QueryToken.next();
			case QContinue(t): t;
			case QStop(t): t;
			case QNoreplyWait: QueryToken.next();
			case QServerInfo: QueryToken.next();
		}
		return new QueryBase(token, e);
	}
	
	@:to
	public function toBytes():Bytes {
		var out = new BytesOutput();
		
		var serializedQuery;
		serializedQuery = switch this.type {
			case QStart(query): '[$START,${query.toString()},{}]';
			case QContinue(t): '[$CONTINUE,[],{}]';
			case QStop(t): '[$STOP,[],{}]';
			case QNoreplyWait: '[$NOREPLY_WAIT,[],{}]';
			case QServerInfo: '[$SERVER_INFO,[],{}]';
		}
		
		out.writeInt32(this.token.high);
		out.writeInt32(this.token.low);
		out.writeInt32(serializedQuery.length);
		out.writeString(serializedQuery);
		var bytes = out.getBytes();
		
		// trace([for(i in 0...12) bytes.get(i).hex(2)].join(',') + bytes.sub(12, bytes.length-12).toString());
		
		return bytes;
	}
}

@:forward
abstract QueryToken(Int64) from Int64 to Int64 {
	static var counterHigh = 0;
	static var counterLow = 0;
	
	public static function next():QueryToken {
		if(counterLow == 0xffffffff) {
			counterLow = 0;
			counterHigh++; // will it ever exceed the limit?!
		} else
			counterLow++;
			
		return Int64.make(counterHigh, counterLow);
	}
}

class QueryBase {
	public var token:Int64;
	public var type:QueryEnum;
	
	public function new(token, type) {
		this.token = token;
		this.type = type;
	}
}

enum QueryEnum {
	QStart(query:Term);
	QContinue(token:Int64);
	QStop(token:Int64);
	QNoreplyWait;
	QServerInfo;
}

@:enum
abstract QueryType(Int) from Int {
	var START = 1;
	var CONTINUE = 2; 
	var STOP = 3;
	var NOREPLY_WAIT = 4;
	var SERVER_INFO = 5;
}