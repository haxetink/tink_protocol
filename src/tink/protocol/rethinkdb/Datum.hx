package tink.protocol.rethinkdb;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import tink.protocol.rethinkdb.Term;

using tink.CoreApi;

@:forward
abstract Datum(DatumBase) from DatumBase to DatumBase {
	
	public var type(get, never):DatumType;
	
	function get_type() {
		return switch this {
			case DNull: R_NULL;
			case DBool(_): R_BOOL;
			case DNumber(_): R_NUM;
			case DString(_): R_STR;
			case DArray(_): R_ARRAY;
			case DObject(_) | DDate(_) | DBinary(_): R_OBJECT;
			case DJson(_): R_JSON;
		}
	}
	
	@:from
	public static inline function ofString(v:String):Datum
		return DString(v);
		
	@:from
	public static inline function ofFloat(v:Float):Datum
		return DNumber(v);
	
	@:from
	public static inline function ofBool(v:Bool):Datum
		return DBool(v);
		
	@:from
	public static inline function ofArray(v:Array<Datum>):Datum
		return DArray(v);
		
	@:from
	public static inline function ofObject(v:Array<Named<Datum>>):Datum
		return DObject(v);
	
	@:to
	public function toString():String {
		return switch this {
			case DNull: 'null';
			case DBool(v): v ? 'true' : 'false';
			case DNumber(v): '$v';
			case DString(v): '"$v"';
			case DArray(v): '[$MAKE_ARRAY,[' + [for(i in v) i.toString()].join(',') + ']]';
			case DObject(v): '{' + [for(i in v) '"${i.name}":${i.value.toString()}'].join(',') + '}';
			case DDate(v): '{"$$reql_type$$":"TIME","epoch_time":${v.getTime()/1000},"timezone":"+00:00"}';
			case DBinary(v): '{"$$reql_type$$":"BINARY","data":"${Base64.encode(v)}"}';
			case DJson(v): v;
		}
	}
	
	@:from
	public static function fromString(v:String):Datum {
		// TODO: should parse directly into the enums, instead of using reflection to check type
		return fromDynamic(haxe.Json.parse(v));
	}
	
	public static function fromDynamic(v:Dynamic):Datum {
		
		// this is the lazy way
		function handle(i:Dynamic) {
			return if(i == null) DNull;
			else if(Std.is(i, String)) DString(i);
			else if(Std.is(i, Float)) DNumber(i);
			else if(Std.is(i, Bool)) DBool(i);
			else if(Std.is(i, Date)) DDate(i);
			else if(Std.is(i, Bytes)) DBinary(i);
			else if(Std.is(i, Array)) DArray([for(item in (i:Array<Dynamic>)) handle(item)]);
			else {
				var fields = Reflect.fields(i);
				DObject([for(field in fields) new Named(field, handle(Reflect.field(i, field)))]);
			} 
		}
		
		return handle(v);
	}
}

enum DatumBase {
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