package websocket;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import tink.io.StreamParser;

class FrameParser extends ByteWiseParser<Frame> {
	
	// frame structure
	var fin:Bool;
	var rsv1:Bool;
	var rsv2:Bool;
	var rsv3:Bool;
	var opcode:Int;
	var mask:Bool;
	var payloadLength:Int;
	var maskingKey:Bytes;
	var payload:Bytes;
	
	// parser internal
	var stage:Stage;
	var bytesToRead:Int;
	var buf:BytesBuffer;
	
	public function new() {
		super();
		stage = Head;
		bytesToRead = -1;
		buf = new BytesBuffer();
	}
	
	override function read(c:Int):ParseStep<Frame> {
		
		function buffer():Void {
			buf.addByte(c);
			bytesToRead--;
		}
	
		function startBuffer(n:Int, skipCurrent = false) {
			bytesToRead = n;
			if(!skipCurrent) buffer();
		}
		
		function flush():Bytes {
			bytesToRead = -1;
			buf.addByte(c);
			var bytes = buf.getBytes();
			buf = new BytesBuffer();
			return bytes;
		}
		
		switch stage {
			case Head:
				fin = (c >> 7 & 1) == 1;
				rsv1 = (c >> 6 & 1) == 1;
				rsv2 = (c >> 5 & 1) == 1;
				rsv3 = (c >> 4 & 1) == 1;
				opcode = c & 0xf;
				bytesToRead = -1;
				stage.advance();
				
			case PayloadLength:
				switch bytesToRead {
					case -1:
						mask = (c >> 7 & 1) == 1;
						switch c & 127 {
							case 127:
								startBuffer(8, true);
							case 126:
								startBuffer(2, true);
							case len:
								payloadLength = len;
								stage.advance();
						}
					
					case 1:
						var bytes = flush();
						payloadLength = 0;
						for(i in 0...bytes.length) payloadLength = payloadLength << 8 + bytes.get(i); // TODO: very likely fail if 64-bit
						stage.advance();
						if(!mask) stage.advance(); // skip the masking key stage
					
					default:
						buffer();
				}
				
			case MaskingKey:
				switch bytesToRead {
					case -1:
						startBuffer(4);
					case 1:
						maskingKey = flush();
						stage.advance();
					default:
						buffer();
				}
				
			case Payload:
				switch bytesToRead {
					case -1:
						startBuffer(payloadLength);
						
					case 1:
						payload = flush();
						
						if(mask) {
							var buf = new BytesBuffer();
							for (i in 0...payload.length) buf.addByte(payload.get(i) ^ maskingKey.get(i % 4));
							payload = buf.getBytes();
						}
						
						stage.reset(); // end of frame
						return Done(new Frame(fin, opcode, payload));
						
					default:
						buffer();
				}
				
		}
		return Progressed;
	}
}

@:enum
abstract Stage(Int) {
	var Head = 0;
	var PayloadLength = 1;
	var MaskingKey = 2;
	var Payload = 3;
	
	public inline function reset() this = 0; 
	public inline function advance() this++; 
}
