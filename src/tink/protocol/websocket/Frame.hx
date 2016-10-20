package tink.protocol.websocket;

import haxe.ds.Option;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import tink.io.Source;
import tink.protocol.websocket.Message;

@:forward
abstract Frame(FrameBase) from FrameBase to FrameBase {
	
	@:to
	public inline function toSource():Source
		return toBytes();
		
	@:to
	public function toBytes():Bytes {
		var out = new BytesBuffer();
		
		// first byte:
		out.addByte(
			(this.fin ? 1 << 7 : 0) |
			(this.rsv1 ? 1 << 6 : 0) |
			(this.rsv2 ? 1 << 5 : 0) |
			(this.rsv3 ? 1 << 4 : 0) |
			this.opcode
		);
		
		// second byte:
		out.addByte(
			(this.mask ? 1 << 7 : 0) |
			(this.payloadLength < 126 ? this.payloadLength : 126) // TODO: support 64-bit length
		);
		
		// extended payload length: (TODO: support 64-bit length)
		if(this.payloadLength >= 126) {
			out.addByte(this.payloadLength >> 8 & 0xff);
			out.addByte(this.payloadLength & 0xff);
		}
		
		// masking key:
		if(this.mask) out.addBytes(this.maskingKey, 0, 4);
		
		// payload:
		if(this.payload != null) out.addBytes(this.payload, 0, this.payload.length);
		
		return out.getBytes();
	}
	
	@:from
	public static function fromBytes(bytes:Bytes):Frame {
		var data = bytes.getData();
		var length = bytes.length;
		var pos = 0;
		
		// first byte
		var c = Bytes.fastGet(data, pos++);
		var fin = (c >> 7 & 1) == 1;
		var rsv1 = (c >> 6 & 1) == 1;
		var rsv2 = (c >> 5 & 1) == 1;
		var rsv3 = (c >> 4 & 1) == 1;
		var opcode = c & 0xf;
		
		// second byte & length
		var c = Bytes.fastGet(data, pos++);
		var mask = c >> 7 == 1;
		var len = switch c & 127 {
			case 127: var l = 0; for(i in 0...8) l = l << 8 + Bytes.fastGet(data, pos++); l;
			case 126: var l = 0; for(i in 0...2) l = l << 8 + Bytes.fastGet(data, pos++); l;
			case v: v;
		}
		
		// masking key
		var maskingKey = 
			if(mask) {
				var key = bytes.sub(pos, 4);
				pos += 4;
				key;
			} else null;
			
		// payload
		var payload = bytes.sub(pos, length - pos);
		
		return new FrameBase(fin, rsv1, rsv2, rsv3, opcode, mask, payload.length, maskingKey, payload);
	}
	
	public static function encode(decoded:Bytes, key:Bytes) {
		var encoded = Bytes.alloc(decoded.length);
		var data = decoded.getData();
		var key = key.getData();
		for(i in 0...decoded.length) encoded.set(i, Bytes.fastGet(data, i) ^ Bytes.fastGet(key, i % 4));
		return encoded;
	}
	
	public static inline function decode(encoded:Bytes, key:Bytes) {
		return encode(encoded, key);
	}
	
	public static function toMessage(frames:Array<Frame>):Option<Message> {
		var last = frames[frames.length - 1];
		if(!last.fin) return None;
		
		function mergeBytes() {
			if(frames.length == 1) return frames[0].payload;
			var out = new BytesBuffer();
			for(frame in frames) out.add(frame.payload);
			return out.getBytes();
		}
		
		return switch frames[0].opcode {
			case Continuation:
				throw 'Unreachable'; // technically
			case Text:
				Some(Message.Text(mergeBytes().toString()));
			case Binary:
				Some(Message.Binary(mergeBytes()));
			case ConnectionClose:
				Some(Message.ConnectionClose);
			case Ping:
				Some(Message.Ping(mergeBytes()));
			case Pong:
				Some(Message.Pong(mergeBytes()));
		}
	}
	
	@:from
	public static function fromMessage(message:Message):Frame {
		var opcode = 0;
		var payload = null;
		switch message {
			case Text(v):
				opcode = Text;
				payload = Bytes.ofString(v);
			case Binary(b):
				opcode = Binary;
				payload = b;
			case ConnectionClose:
				opcode = ConnectionClose;
			case Ping(b):
				opcode = Ping;
				payload = b;
			case Pong(b):
				opcode = Pong;
				payload = b;
		}
		return new FrameBase(true, false, false, false, opcode, false, payload.length, null, payload);
	}
	
	public inline function unmask()
		maskWith(null);
	
	public function maskWith(key:Bytes) {
		switch [this.maskingKey, key] {
			case [null, null]: return;
			case [null, key]: this.payload = encode(this.payload, key); this.mask = true; this.maskingKey = key;
			case [key, null]: this.payload = decode(this.payload, key); this.mask = false; this.maskingKey = null;
			case [oldKey, newKey] if(oldKey.compare(newKey) == 0): return;
			case [oldKey, newKey]: this.payload = encode(decode(this.payload, oldKey), newKey); this.maskingKey = newKey;
		}
	}
}

class FrameBase {
	public var fin:Bool;
	public var rsv1:Bool;
	public var rsv2:Bool;
	public var rsv3:Bool;
	public var opcode:Opcode;
	public var mask:Bool;
	public var payloadLength:Int = 0;
	public var maskingKey:Bytes;
	public var payload:Bytes; // encoded
	
	public function new(fin, rsv1, rsv2, rsv3, opcode, mask, payloadLength, maskingKey, payload) {
		this.fin = fin;
		this.rsv1 = rsv1;
		this.rsv2 = rsv2;
		this.rsv3 = rsv3;
		this.opcode = opcode;
		this.mask = mask;
		this.payloadLength = payloadLength;
		this.maskingKey = maskingKey;
		this.payload = payload;
	}
}

@:enum
abstract Opcode(Int) from Int to Int {
	var Continuation = 0x0;
	var Text = 0x1;
	var Binary = 0x2;
	var ConnectionClose = 0x8;
	var Ping = 0x9;
	var Pong = 0xa;
}