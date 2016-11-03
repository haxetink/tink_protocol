package tink.protocol.rethinkdb;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.crypto.Base64;
import tink.protocol.rethinkdb.Datum;

@:forward
abstract Response(ResponseBase) from ResponseBase to ResponseBase {
	
	static inline var PSEUDOTYPE_KEY = "$reql_type$";
	
	@:from
	public static function fromBytes(bytes:Bytes):Response {
		var token = Int64.make(bytes.getInt32(0), bytes.getInt32(4));
		var json = bytes.sub(12, bytes.length - 12).toString();
		var res = haxe.Json.parse(json);
		// trace(json);
		var type:ResponseType = res.t;
		
		var response:Array<Dynamic> = res.r;
		// var response:Dynamic = switch type {
		// 	case SUCCESS_ATOM | SERVER_INFO | CLIENT_ERROR | COMPILE_ERROR | RUNTIME_ERROR: res.r[0];
		// 	case SUCCESS_SEQUENCE | SUCCESS_PARTIAL: res.r;
		// 	case WAIT_COMPLETE: null;
		// }
		
		var backtrace = res.b; // TODO: parse it
		var profile = Datum.fromDynamic(res.p); // TODO: parse it
		var notes = res.n == null ? [] : res.n;
		var errorType = res.e == null ? 0 : res.e;
		return new ResponseBase(res.t, token, response, backtrace, profile, notes, errorType);
	}
	
	public inline function convert(format:{rawTime:Bool, rawGroups:Bool, rawBinary:Bool}, level = 100) {
		this.response = convertPseudo(this.response, format, level);
	}
	
	static function convertPseudo(obj:Dynamic, format:{rawTime:Bool, rawGroups:Bool, rawBinary:Bool}, level:Int):Dynamic {
		if(level == 0) throw "Depth exceeded";
		
		return if(Std.is(obj, String)) {
			obj;
		} else if(Std.is(obj, Array)) {
			[for(o in (obj:Array<Dynamic>)) convertPseudo(o, format, level - 1)];
		} else if(Reflect.isObject(obj)) {
			var fields = Reflect.fields(obj);
			if(fields.indexOf(PSEUDOTYPE_KEY) != -1) {
				switch Reflect.field(obj, PSEUDOTYPE_KEY) {
					case 'TIME': format.rawTime ? obj : Date.fromTime(obj.epoch_time * 1000);
					case 'BINARY': format.rawBinary ? obj : Base64.decode(obj.data);
					case 'GROUPED_DATA': obj; // TODO
					case 'GEOMETRY': obj; // TODO
					default: obj;
				}
			} else {
				var result = {};
				for(field in fields) Reflect.setField(result, field, convertPseudo(Reflect.field(obj, field), format, level - 1));
				result;
			}
		} else {
			obj;
		}
	}
	
}

class ResponseBase {
	public var type:ResponseType;
	public var token:Int64;
	public var response:Array<Dynamic>;
	public var backtrace:Backtrace;
	public var profile:Datum;
	public var notes:Array<ResponseNote>;
	public var errorType:ErrorType;
	
	public function new(type, token, response, backtrace, profile, notes, errorType) {
		this.type = type;
		this.token = token;
		this.response = response;
		this.backtrace = backtrace;
		this.profile = profile;
		this.notes = notes;
		this.errorType = errorType;
	}
	
	public function isWaitComplete() {
		return type == WAIT_COMPLETE;
	}
	
	public function isFeed() {
		for(n in notes) switch n {
			case SEQUENCE_FEED | ATOM_FEED | ORDER_BY_LIMIT_FEED | UNIONED_FEED: return true; 
			default:
		}
		return false;
	}
	
	public function isError() {
		return switch type {
			case CLIENT_ERROR | COMPILE_ERROR | RUNTIME_ERROR: true;
			default: false;
		}
	}
	
	public function isAtom() {
		return type == SUCCESS_ATOM;
	}
	
	public function isSequence() {
		return type == SUCCESS_SEQUENCE;
	}
	
	public function isPartial() {
		return type == SUCCESS_PARTIAL;
	}
}

@:enum
abstract ResponseType(Int) from Int {
	var SUCCESS_ATOM = 1;
	var SUCCESS_SEQUENCE = 2;
	var SUCCESS_PARTIAL = 3;
	var WAIT_COMPLETE = 4;
	var SERVER_INFO = 5;
	var CLIENT_ERROR = 16;
	var COMPILE_ERROR = 17;
	var RUNTIME_ERROR = 18;
}

@:enum
abstract ErrorType(Int) from Int {
	var INTERNAL = 1000000;
	var RESOURCE_LIMIT = 2000000;
	var QUERY_LOGIC = 3000000;
	var NON_EXISTENCE = 3100000;
	var OP_FAILED = 4100000;
	var OP_INDETERMINATE = 4200000;
	var USER = 5000000;
	var PERMISSION_ERROR = 6000000;
}

@:enum
abstract ResponseNote(Int) from Int {
	var SEQUENCE_FEED = 1;
	var ATOM_FEED = 2;
	var ORDER_BY_LIMIT_FEED = 3;
	var UNIONED_FEED = 4;
	var INCLUDES_STATES = 5;
}

