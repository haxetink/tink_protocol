package tink.protocol.websocket;

import haxe.ds.Option;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import tink.io.Buffer;
import tink.io.StreamParser;

using tink.CoreApi;

class Parser implements StreamParser<Bytes> {
	var mask:Bool; // mask bit of the frame
	var length = 0; // total length of frame
	var required = 0; // required length for next read
	var result:Option<Bytes>;
	var out:BytesBuffer;
	
	public function new() {
		result = None;
		required = 2;
	}
	
	public function minSize()
		return 8;
		
	public function eof() {
		return switch result {
			case Some(v): Success(v);
			case None: Failure(new Error('Unexpected end of stream'));
		}
	}
	
	public function progress(buffer:Buffer) {
		result = None;
		buffer.writeTo(this);
		return Success(result);
	}
	
	function writeBytes(bytes:Bytes, start:Int, len:Int) {
		if(len < required) return 0;
		switch length {
			case 0:
				var secondByte = bytes.get(start + 1);
				mask = secondByte >> 7 == 1;
				required = switch secondByte & 127 {
					case 127: length = -2; 8;
					case 126: length = -1; 2;
					case len: length = len + 2 + (mask ? 4 : 0); 0;
				}
				out = new BytesBuffer();
				out.addBytes(bytes, start, 2);
				return 2;
			
			case -1 | -2:
				length = 0;
				for(i in 0...required) length = length << 8 + bytes.get(start + i);
				var read = required;
				length += 2 + read + (mask ? 4 : 0);
				out.addBytes(bytes, start, read);
				required = 0;
				return read;
			
			default:
		}
		
		inline function min(a:Int, b:Int) return a > b ? b : a;
		var read = min(length - out.length, len);
		out.addBytes(bytes, start, read);
		if(out.length == length) {
			result = Some(out.getBytes());
			length = 0;
			required = 2;
		}
		return read;
	}
}