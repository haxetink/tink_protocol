package tink.protocol.rethinkdb;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

using tink.protocol.rethinkdb.Term;
using StringTools;
using tink.CoreApi;

@:forward
abstract QueryToken(Int64) from Int64 to Int64 {
	static var counterHigh = 0;
	static var counterLow = 0;
	
	public function new() {
		this = 
			if(counterLow == 0xffffffff) {
				counterLow = 0;
				counterHigh++; // will it ever exceed the limit?!
			} else
				counterLow++;
				
			Int64.make(counterHigh, counterLow);
	}
}

class Query {
	public var token:Int64;
	public var type:QueryKind;
	public var term(get, never):Term;
	
	public function new(type) {
		this.type = type;
		this.token = switch type {
			case QStart(query): new QueryToken();
			case QContinue(t): t;
			case QStop(t): t;
			case QNoreplyWait: new QueryToken();
			case QServerInfo: new QueryToken();
		}
	}
	
	public function toBytes():Bytes {
		var out = new BytesOutput();
		
		var serializedQuery = toString();
		
		out.writeInt32(token.high);
		out.writeInt32(token.low);
		out.writeInt32(serializedQuery.length);
		out.writeString(serializedQuery);
		var bytes = out.getBytes();
		
		// trace([for(i in 0...12) bytes.get(i).hex(2)].join(',') + bytes.sub(12, bytes.length-12).toString());
		
		return bytes;
	}
	
	public function toString() {
		return switch type {
			case QStart(query): '[$START,${query.asString()},{}]';
			case QContinue(t): '[$CONTINUE,[],{}]';
			case QStop(t): '[$STOP,[],{}]';
			case QNoreplyWait: '[$NOREPLY_WAIT,[],{}]';
			case QServerInfo: '[$SERVER_INFO,[],{}]';
		}
	}
	
	function get_term() {
		return switch type {
			case QStart(t): t;
			default: null;
		}
	}
}

enum QueryKind {
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