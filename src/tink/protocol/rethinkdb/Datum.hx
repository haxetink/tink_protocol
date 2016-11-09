package tink.protocol.rethinkdb;

import haxe.crypto.Base64;
import haxe.io.Bytes;

using tink.protocol.rethinkdb.Term;
using tink.CoreApi;

class DatumTools {
	
	public static function ofAny(v:Dynamic):Datum {
		// this is the lazy way, we can probably use tink_typecrawler to convert at compile time
		function handle(i:Dynamic) {
			return if(i == null) DNull;
			else if(Std.is(i, Term)) DJson((i:Term).asString())
			else if(Std.is(i, String)) DString(i);
			else if(Std.is(i, Float)) DNumber(i);
			else if(Std.is(i, Bool)) DBool(i);
			else if(Std.is(i, Date)) DDate(i);
			else if(Std.is(i, Bytes)) DBinary(i);
			else if(Std.is(i, Array)) DArray([for(item in (i:Array<Dynamic>)) handle(item)]);
			else if(Reflect.isEnumValue(i)) throw 'Cannot convert enum';
			else {
				var fields = Reflect.fields(i);
				DObject([for(field in fields) new Named(field, handle(Reflect.field(i, field)))]);
			} 
		}
		
		return handle(v);
	}
		
	public static function asString(d:Datum):String {
		return switch d {
			case null | DNull: 'null';
			case DBool(v): v ? 'true' : 'false';
			case DNumber(v): '$v';
			case DString(v): haxe.Json.stringify(v);
			case DArray(v): '[$MAKE_ARRAY,[' + [for(i in v) asString(i)].join(',') + ']]';
			case DObject(v): '{' + [for(i in v) '"${i.name}":${asString(i.value)}'].join(',') + '}';
			case DDate(v): '{"$$reql_type$$":"TIME","epoch_time":${v.getTime()/1000},"timezone":"+00:00"}';
			case DBinary(v): '{"$$reql_type$$":"BINARY","data":"${Base64.encode(v)}"}';
			case DJson(v): v;
		}
	}
}

enum Datum {
	DNull;
	DBool(v:Bool);
	DNumber(v:Float);
	DString(v:String);
	DArray(v:Array<Datum>);
	DObject(v:Array<Named<Datum>>);
	DJson(v:String);
	DDate(v:Date);
	DBinary(v:Bytes);
}

@:enum
abstract DatumType(Int) from Int {
	var R_NULL = 1;
	var R_BOOL = 2;
	var R_NUM = 3;
	var R_STR = 4;
	var R_ARRAY = 5;
	var R_OBJECT = 6;
	var R_JSON = 7;
}