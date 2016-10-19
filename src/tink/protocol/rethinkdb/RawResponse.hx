package tink.protocol.rethinkdb;

import haxe.Int64;
import haxe.io.Bytes;
import tink.protocol.rethinkdb.Response;

@:forward
abstract RawResponse(RawResponseBase) from RawResponseBase to RawResponseBase {
	@:from
	public static function fromBytes(bytes:Bytes):RawResponse {
		var token = Int64.make(bytes.getInt32(0), bytes.getInt32(4));
		var json = bytes.sub(12, bytes.length - 12).toString();
		return new RawResponseBase(token, json);
	}
}

class RawResponseBase {
	public var token:Int64;
	public var json:String;
	public function new(token, json) {
		this.token = token;
		this.json = json;
	}
}