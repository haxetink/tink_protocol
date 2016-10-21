package tink.protocol.rethinkdb;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

using StringTools;
using tink.CoreApi;

@:forward
abstract Query(QueryBase) from QueryBase to QueryBase {
	
	public function new(type, ?query, ?token)
		return new QueryBase(type, query, token == null ? nextToken() : token);
		
	@:to
	public function toBytes():Bytes {
		var out = new BytesOutput();
		
		out.writeInt32(this.token.high);
		out.writeInt32(this.token.low);
		
		var serializedQuery = switch this.type {
			case START: '[${this.type},${this.query.toString()},{}]';
			case CONTINUE | STOP | NOREPLY_WAIT | SERVER_INFO: '[${this.type},[],{}]';
		}
		out.writeInt32(serializedQuery.length);
		out.writeString(serializedQuery);
		var bytes = out.getBytes();
		
		trace([for(i in 0...12) bytes.get(i).hex(2)].join(',') + bytes.sub(12, bytes.length-12).toString());
		
		return bytes;
	}
	
	public static inline function nextToken()
		return QueryBase.nextToken();
}

class QueryBase {
	public var type:QueryType;
	public var query:Term;
	public var token:Int64;
	public var OBSOLETE_noreply:Bool; // TODO: figure out how these work
	public var accepts_r_json:Bool; // TODO: figure out how these work
	public var global_optargs:Array<Named<Term>>; // TODO: figure out how these work
	
	static var counterHigh = 0;
	static var counterLow = 0;
	
	public function new(type, query, token) {
		this.type = type;
		this.query = query;
		this.token = token;
	}
	
	public static function nextToken() {
		if(counterLow == 0xffffffff) {
			counterLow = 0;
			counterHigh++; // will it ever exceed the limit?!
		} else
			counterLow++;
			
		return Int64.make(counterHigh, counterLow);
	}
}

@:enum
abstract QueryType(Int) from Int {
	var START = 1;
	var CONTINUE = 2; 
	var STOP = 3;
	var NOREPLY_WAIT = 4;
	var SERVER_INFO = 5;
}