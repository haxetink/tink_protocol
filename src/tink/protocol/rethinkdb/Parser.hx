package tink.protocol.rethinkdb;

import haxe.Int64;
import haxe.Json;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import tink.io.Buffer;
import tink.io.StreamParser;

using tink.CoreApi;

class Parser implements StreamParser<Bytes> {
	
	var id:Int64;
	var length = 0;
	var result:Option<Bytes>;
	var out:BytesBuffer;
	
	public function new() {
		result = None;
		out = new BytesBuffer();
	}
	
	public function minSize() 
		return 4;
	
	public function eof():Outcome<Bytes, Error> {
		return Success(null); // TODO: will this ever happen?
	}
	
	public function progress(buffer:Buffer):Outcome<Option<Bytes>, Error> {
		if(result != None) {
			out = new BytesBuffer();
			result = None;
		}
		buffer.writeTo(this);
		return Success(result);
	}
	
	function writeBytes(bytes:Bytes, start:Int, len:Int) {
		if(length == 0) {
			if(len < 12) return 0;
			id = Int64.make(bytes.getInt32(start), bytes.getInt32(start + 4));
			length = bytes.getInt32(start + 8) + 12;
		}
		
		inline function min(a:Int, b:Int) return a > b ? b : a;
		var read = min(length - out.length, len);
		out.addBytes(bytes, start, read);
		if(out.length == length) {
			result = Some(out.getBytes());
			length = 0;
		}
		return read;
	}
}


