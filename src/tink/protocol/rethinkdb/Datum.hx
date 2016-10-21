package tink.protocol.rethinkdb;

import tink.protocol.rethinkdb.Term;

using tink.CoreApi;

@:forward
abstract Datum(DatumBase) from DatumBase to DatumBase {
	
	public var type(get, never):DatumType;
	
	function get_type() {
		return switch this {
			case Null: R_NULL;
			case Bool(_): R_BOOL;
			case Num(_): R_NUM;
			case Str(_): R_STR;
			case Arr(_): R_ARRAY;
			case Object(_): R_OBJECT;
			case Json(_): R_JSON;
		}
	}
	
	@:from
	public static inline function ofString(v:String):Datum
		return Str(v);
		
	@:from
	public static inline function ofFloat(v:Float):Datum
		return Num(v);
	
	@:from
	public static inline function ofBool(v:Bool):Datum
		return Bool(v);
		
	@:from
	public static inline function ofArray(v:Array<Datum>):Datum
		return Arr(v);
		
	@:from
	public static inline function ofObject(v:Array<Named<Datum>>):Datum
		return Object(v);
	
	@:to
	public function toString():String {
		return switch this {
			case Null: 'null';
			case Bool(v): v ? 'true' : 'false';
			case Num(v): '$v';
			case Str(v): '"$v"';
			case Arr(v): '[$MAKE_ARRAY,' + [for(i in v) i.toString()].join(',') + ']';
			case Object(v): '{' + [for(i in v) '"${i.name}":${i.value.toString()}'].join(',') + '}';
			case Json(v): v;
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
			return if(i == null) Null;
			else if(Std.is(i, String)) Str(i);
			else if(Std.is(i, Float)) Num(i);
			else if(Std.is(i, Bool)) Bool(i);
			else if(Std.is(i, Array)) Arr([for(item in (i:Array<Dynamic>)) handle(item)]);
			else {
				var fields = Reflect.fields(i);
				Object([for(field in fields) new Named(field, handle(Reflect.field(i, field)))]);
			} 
		}
		
		return handle(v);
	}
}

enum DatumBase {
	Null;
	Bool(v:Bool);
	Num(v:Float);
	Str(v:String);
	Arr(v:Array<Datum>);
	Object(v:Array<Named<Datum>>);
	Json(v:String);
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