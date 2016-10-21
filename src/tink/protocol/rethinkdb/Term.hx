package tink.protocol.rethinkdb;

import haxe.Json;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

using tink.CoreApi;

@:forward
abstract Term(TermBase) from TermBase to TermBase {
	@:to
	public function toString():String {
		return switch this {
			case TDatum(datum): datum.toString();
			case TMakeArray(args, opt): '[$MAKE_ARRAY,${args.toString()}${opt.toString()}]';
			case TMakeObj(args, opt): '[$MAKE_OBJ,${args.toString()}${opt.toString()}]';
			case TVar(args, opt): '[$VAR,${args.toString()}${opt.toString()}]';
			case TJavascript(args, opt): '[$JAVASCRIPT,${args.toString()}${opt.toString()}]';
			case TUuid(args, opt): '[$UUID,${args.toString()}${opt.toString()}]';
			case THttp(args, opt): '[$HTTP,${args.toString()}${opt.toString()}]';
			case TError(args, opt): '[$ERROR,${args.toString()}${opt.toString()}]';
			case TImplicitVar(args, opt): '[$IMPLICIT_VAR,${args.toString()}${opt.toString()}]';
			case TDb(args, opt): '[$DB,${args.toString()}${opt.toString()}]';
			case TTable(args, opt): '[$TABLE,${args.toString()}${opt.toString()}]';
			case TGet(args, opt): '[$GET,${args.toString()}${opt.toString()}]';
			case TGetAll(args, opt): '[$GET_ALL,${args.toString()}${opt.toString()}]';
			case TEq(args, opt): '[$EQ,${args.toString()}${opt.toString()}]';
			case TNe(args, opt): '[$NE,${args.toString()}${opt.toString()}]';
			case TLt(args, opt): '[$LT,${args.toString()}${opt.toString()}]';
			case TLe(args, opt): '[$LE,${args.toString()}${opt.toString()}]';
			case TGt(args, opt): '[$GT,${args.toString()}${opt.toString()}]';
			case TGe(args, opt): '[$GE,${args.toString()}${opt.toString()}]';
			case TNot(args, opt): '[$NOT,${args.toString()}${opt.toString()}]';
			case TAdd(args, opt): '[$ADD,${args.toString()}${opt.toString()}]';
			case TSub(args, opt): '[$SUB,${args.toString()}${opt.toString()}]';
			case TMul(args, opt): '[$MUL,${args.toString()}${opt.toString()}]';
			case TDiv(args, opt): '[$DIV,${args.toString()}${opt.toString()}]';
			case TMod(args, opt): '[$MOD,${args.toString()}${opt.toString()}]';
			case TFloor(args, opt): '[$FLOOR,${args.toString()}${opt.toString()}]';
			case TCeil(args, opt): '[$CEIL,${args.toString()}${opt.toString()}]';
			case TRound(args, opt): '[$ROUND,${args.toString()}${opt.toString()}]';
			case TAppend(args, opt): '[$APPEND,${args.toString()}${opt.toString()}]';
			case TPrepend(args, opt): '[$PREPEND,${args.toString()}${opt.toString()}]';
			case TDifference(args, opt): '[$DIFFERENCE,${args.toString()}${opt.toString()}]';
			case TSetInsert(args, opt): '[$SET_INSERT,${args.toString()}${opt.toString()}]';
			case TSetIntersection(args, opt): '[$SET_INTERSECTION,${args.toString()}${opt.toString()}]';
			case TSetUnion(args, opt): '[$SET_UNION,${args.toString()}${opt.toString()}]';
			case TSetDifference(args, opt): '[$SET_DIFFERENCE,${args.toString()}${opt.toString()}]';
			case TSlice(args, opt): '[$SLICE,${args.toString()}${opt.toString()}]';
			case TSkip(args, opt): '[$SKIP,${args.toString()}${opt.toString()}]';
			case TLimit(args, opt): '[$LIMIT,${args.toString()}${opt.toString()}]';
			case TOffsetsOf(args, opt): '[$OFFSETS_OF,${args.toString()}${opt.toString()}]';
			case TContains(args, opt): '[$CONTAINS,${args.toString()}${opt.toString()}]';
			case TGetField(args, opt): '[$GET_FIELD,${args.toString()}${opt.toString()}]';
			case TKeys(args, opt): '[$KEYS,${args.toString()}${opt.toString()}]';
			case TValues(args, opt): '[$VALUES,${args.toString()}${opt.toString()}]';
			case TObject(args, opt): '[$OBJECT,${args.toString()}${opt.toString()}]';
			case THasFields(args, opt): '[$HAS_FIELDS,${args.toString()}${opt.toString()}]';
			case TWithFields(args, opt): '[$WITH_FIELDS,${args.toString()}${opt.toString()}]';
			case TPluck(args, opt): '[$PLUCK,${args.toString()}${opt.toString()}]';
			case TWithout(args, opt): '[$WITHOUT,${args.toString()}${opt.toString()}]';
			case TMerge(args, opt): '[$MERGE,${args.toString()}${opt.toString()}]';
			case TBetweenDeprecated(args, opt): '[$BETWEEN_DEPRECATED,${args.toString()}${opt.toString()}]';
			case TBetween(args, opt): '[$BETWEEN,${args.toString()}${opt.toString()}]';
			case TReduce(args, opt): '[$REDUCE,${args.toString()}${opt.toString()}]';
			case TMap(args, opt): '[$MAP,${args.toString()}${opt.toString()}]';
			case TFold(args, opt): '[$FOLD,${args.toString()}${opt.toString()}]';
			case TFilter(args, opt): '[$FILTER,${args.toString()}${opt.toString()}]';
			case TConcatMap(args, opt): '[$CONCAT_MAP,${args.toString()}${opt.toString()}]';
			case TOrderBy(args, opt): '[$ORDER_BY,${args.toString()}${opt.toString()}]';
			case TDistinct(args, opt): '[$DISTINCT,${args.toString()}${opt.toString()}]';
			case TCount(args, opt): '[$COUNT,${args.toString()}${opt.toString()}]';
			case TIsEmpty(args, opt): '[$IS_EMPTY,${args.toString()}${opt.toString()}]';
			case TUnion(args, opt): '[$UNION,${args.toString()}${opt.toString()}]';
			case TNth(args, opt): '[$NTH,${args.toString()}${opt.toString()}]';
			case TBracket(args, opt): '[$BRACKET,${args.toString()}${opt.toString()}]';
			case TInnerJoin(args, opt): '[$INNER_JOIN,${args.toString()}${opt.toString()}]';
			case TOuterJoin(args, opt): '[$OUTER_JOIN,${args.toString()}${opt.toString()}]';
			case TEqJoin(args, opt): '[$EQ_JOIN,${args.toString()}${opt.toString()}]';
			case TZip(args, opt): '[$ZIP,${args.toString()}${opt.toString()}]';
			case TRange(args, opt): '[$RANGE,${args.toString()}${opt.toString()}]';
			case TInsertAt(args, opt): '[$INSERT_AT,${args.toString()}${opt.toString()}]';
			case TDeleteAt(args, opt): '[$DELETE_AT,${args.toString()}${opt.toString()}]';
			case TChangeAt(args, opt): '[$CHANGE_AT,${args.toString()}${opt.toString()}]';
			case TSpliceAt(args, opt): '[$SPLICE_AT,${args.toString()}${opt.toString()}]';
			case TCoerceTo(args, opt): '[$COERCE_TO,${args.toString()}${opt.toString()}]';
			case TTypeOf(args, opt): '[$TYPE_OF,${args.toString()}${opt.toString()}]';
			case TUpdate(args, opt): '[$UPDATE,${args.toString()}${opt.toString()}]';
			case TDelete(args, opt): '[$DELETE,${args.toString()}${opt.toString()}]';
			case TReplace(args, opt): '[$REPLACE,${args.toString()}${opt.toString()}]';
			case TInsert(args, opt): '[$INSERT,${args.toString()}${opt.toString()}]';
			case TDbCreate(args, opt): '[$DB_CREATE,${args.toString()}${opt.toString()}]';
			case TDbDrop(args, opt): '[$DB_DROP,${args.toString()}${opt.toString()}]';
			case TDbList(args, opt): '[$DB_LIST,${args.toString()}${opt.toString()}]';
			case TTableCreate(args, opt): '[$TABLE_CREATE,${args.toString()}${opt.toString()}]';
			case TTableDrop(args, opt): '[$TABLE_DROP,${args.toString()}${opt.toString()}]';
			case TTableList(args, opt): '[$TABLE_LIST,${args.toString()}${opt.toString()}]';
			case TConfig(args, opt): '[$CONFIG,${args.toString()}${opt.toString()}]';
			case TStatus(args, opt): '[$STATUS,${args.toString()}${opt.toString()}]';
			case TWait(args, opt): '[$WAIT,${args.toString()}${opt.toString()}]';
			case TReconfigure(args, opt): '[$RECONFIGURE,${args.toString()}${opt.toString()}]';
			case TRebalance(args, opt): '[$REBALANCE,${args.toString()}${opt.toString()}]';
			case TSync(args, opt): '[$SYNC,${args.toString()}${opt.toString()}]';
			case TGrant(args, opt): '[$GRANT,${args.toString()}${opt.toString()}]';
			case TIndexCreate(args, opt): '[$INDEX_CREATE,${args.toString()}${opt.toString()}]';
			case TIndexDrop(args, opt): '[$INDEX_DROP,${args.toString()}${opt.toString()}]';
			case TIndexList(args, opt): '[$INDEX_LIST,${args.toString()}${opt.toString()}]';
			case TIndexStatus(args, opt): '[$INDEX_STATUS,${args.toString()}${opt.toString()}]';
			case TIndexWait(args, opt): '[$INDEX_WAIT,${args.toString()}${opt.toString()}]';
			case TIndexRename(args, opt): '[$INDEX_RENAME,${args.toString()}${opt.toString()}]';
			case TSetWriteHook(args, opt): '[$SET_WRITE_HOOK,${args.toString()}${opt.toString()}]';
			case TGetWriteHook(args, opt): '[$GET_WRITE_HOOK,${args.toString()}${opt.toString()}]';
			case TFuncall(args, opt): '[$FUNCALL,${args.toString()}${opt.toString()}]';
			case TBranch(args, opt): '[$BRANCH,${args.toString()}${opt.toString()}]';
			case TOr(args, opt): '[$OR,${args.toString()}${opt.toString()}]';
			case TAnd(args, opt): '[$AND,${args.toString()}${opt.toString()}]';
			case TForEach(args, opt): '[$FOR_EACH,${args.toString()}${opt.toString()}]';
			case TFunc(args, opt): '[$FUNC,${args.toString()}${opt.toString()}]';
			case TAsc(args, opt): '[$ASC,${args.toString()}${opt.toString()}]';
			case TDesc(args, opt): '[$DESC,${args.toString()}${opt.toString()}]';
			case TInfo(args, opt): '[$INFO,${args.toString()}${opt.toString()}]';
			case TMatch(args, opt): '[$MATCH,${args.toString()}${opt.toString()}]';
			case TUpcase(args, opt): '[$UPCASE,${args.toString()}${opt.toString()}]';
			case TDowncase(args, opt): '[$DOWNCASE,${args.toString()}${opt.toString()}]';
			case TSample(args, opt): '[$SAMPLE,${args.toString()}${opt.toString()}]';
			case TDefault(args, opt): '[$DEFAULT,${args.toString()}${opt.toString()}]';
			case TJson(args, opt): '[$JSON,${args.toString()}${opt.toString()}]';
			case TToJsonString(args, opt): '[$TO_JSON_STRING,${args.toString()}${opt.toString()}]';
			case TIso8601(args, opt): '[$ISO8601,${args.toString()}${opt.toString()}]';
			case TToIso8601(args, opt): '[$TO_ISO8601,${args.toString()}${opt.toString()}]';
			case TEpochTime(args, opt): '[$EPOCH_TIME,${args.toString()}${opt.toString()}]';
			case TToEpochTime(args, opt): '[$TO_EPOCH_TIME,${args.toString()}${opt.toString()}]';
			case TNow(args, opt): '[$NOW,${args.toString()}${opt.toString()}]';
			case TInTimezone(args, opt): '[$IN_TIMEZONE,${args.toString()}${opt.toString()}]';
			case TDuring(args, opt): '[$DURING,${args.toString()}${opt.toString()}]';
			case TDate(args, opt): '[$DATE,${args.toString()}${opt.toString()}]';
			case TTimeOfDay(args, opt): '[$TIME_OF_DAY,${args.toString()}${opt.toString()}]';
			case TTimezone(args, opt): '[$TIMEZONE,${args.toString()}${opt.toString()}]';
			case TYear(args, opt): '[$YEAR,${args.toString()}${opt.toString()}]';
			case TMonth(args, opt): '[$MONTH,${args.toString()}${opt.toString()}]';
			case TDay(args, opt): '[$DAY,${args.toString()}${opt.toString()}]';
			case TDayOfWeek(args, opt): '[$DAY_OF_WEEK,${args.toString()}${opt.toString()}]';
			case TDayOfYear(args, opt): '[$DAY_OF_YEAR,${args.toString()}${opt.toString()}]';
			case THours(args, opt): '[$HOURS,${args.toString()}${opt.toString()}]';
			case TMinutes(args, opt): '[$MINUTES,${args.toString()}${opt.toString()}]';
			case TSeconds(args, opt): '[$SECONDS,${args.toString()}${opt.toString()}]';
			case TTime(args, opt): '[$TIME,${args.toString()}${opt.toString()}]';
			case TMonday(args, opt): '[$MONDAY,${args.toString()}${opt.toString()}]';
			case TTuesday(args, opt): '[$TUESDAY,${args.toString()}${opt.toString()}]';
			case TWednesday(args, opt): '[$WEDNESDAY,${args.toString()}${opt.toString()}]';
			case TThursday(args, opt): '[$THURSDAY,${args.toString()}${opt.toString()}]';
			case TFriday(args, opt): '[$FRIDAY,${args.toString()}${opt.toString()}]';
			case TSaturday(args, opt): '[$SATURDAY,${args.toString()}${opt.toString()}]';
			case TSunday(args, opt): '[$SUNDAY,${args.toString()}${opt.toString()}]';
			case TJanuary(args, opt): '[$JANUARY,${args.toString()}${opt.toString()}]';
			case TFebruary(args, opt): '[$FEBRUARY,${args.toString()}${opt.toString()}]';
			case TMarch(args, opt): '[$MARCH,${args.toString()}${opt.toString()}]';
			case TApril(args, opt): '[$APRIL,${args.toString()}${opt.toString()}]';
			case TMay(args, opt): '[$MAY,${args.toString()}${opt.toString()}]';
			case TJune(args, opt): '[$JUNE,${args.toString()}${opt.toString()}]';
			case TJuly(args, opt): '[$JULY,${args.toString()}${opt.toString()}]';
			case TAugust(args, opt): '[$AUGUST,${args.toString()}${opt.toString()}]';
			case TSeptember(args, opt): '[$SEPTEMBER,${args.toString()}${opt.toString()}]';
			case TOctober(args, opt): '[$OCTOBER,${args.toString()}${opt.toString()}]';
			case TNovember(args, opt): '[$NOVEMBER,${args.toString()}${opt.toString()}]';
			case TDecember(args, opt): '[$DECEMBER,${args.toString()}${opt.toString()}]';
			case TLiteral(args, opt): '[$LITERAL,${args.toString()}${opt.toString()}]';
			case TGroup(args, opt): '[$GROUP,${args.toString()}${opt.toString()}]';
			case TSum(args, opt): '[$SUM,${args.toString()}${opt.toString()}]';
			case TAvg(args, opt): '[$AVG,${args.toString()}${opt.toString()}]';
			case TMin(args, opt): '[$MIN,${args.toString()}${opt.toString()}]';
			case TMax(args, opt): '[$MAX,${args.toString()}${opt.toString()}]';
			case TSplit(args, opt): '[$SPLIT,${args.toString()}${opt.toString()}]';
			case TUngroup(args, opt): '[$UNGROUP,${args.toString()}${opt.toString()}]';
			case TRandom(args, opt): '[$RANDOM,${args.toString()}${opt.toString()}]';
			case TChanges(args, opt): '[$CHANGES,${args.toString()}${opt.toString()}]';
			case TArgs(args, opt): '[$ARGS,${args.toString()}${opt.toString()}]';
			case TBinary(args, opt): '[$BINARY,${args.toString()}${opt.toString()}]';
			case TGeojson(args, opt): '[$GEOJSON,${args.toString()}${opt.toString()}]';
			case TToGeojson(args, opt): '[$TO_GEOJSON,${args.toString()}${opt.toString()}]';
			case TPoint(args, opt): '[$POINT,${args.toString()}${opt.toString()}]';
			case TLine(args, opt): '[$LINE,${args.toString()}${opt.toString()}]';
			case TPolygon(args, opt): '[$POLYGON,${args.toString()}${opt.toString()}]';
			case TDistance(args, opt): '[$DISTANCE,${args.toString()}${opt.toString()}]';
			case TIntersects(args, opt): '[$INTERSECTS,${args.toString()}${opt.toString()}]';
			case TIncludes(args, opt): '[$INCLUDES,${args.toString()}${opt.toString()}]';
			case TCircle(args, opt): '[$CIRCLE,${args.toString()}${opt.toString()}]';
			case TGetIntersecting(args, opt): '[$GET_INTERSECTING,${args.toString()}${opt.toString()}]';
			case TFill(args, opt): '[$FILL,${args.toString()}${opt.toString()}]';
			case TGetNearest(args, opt): '[$GET_NEAREST,${args.toString()}${opt.toString()}]';
			case TPolygonSub(args, opt): '[$POLYGON_SUB,${args.toString()}${opt.toString()}]';
			case TMinval(args, opt): '[$MINVAL,${args.toString()}${opt.toString()}]';
			case TMaxval(args, opt): '[$MAXVAL,${args.toString()}${opt.toString()}]';
		}
	}
}

abstract TermArgs(Array<Term>) from Array<Term> {
	@:to
	public function toString():String
		return '[' + [for(i in this) i.toString()].join(',') + ']';

}

abstract TermOptions(Array<Named<Term>>) from Array<Named<Term>> {
	@:to
	public function toString():String
		return this == null ? '' : ',{' + [for(o in this) '"${o.name}":${o.value}'].join(',') + '}';
}

@:enum
abstract TermType(Int) from Int {
	var DATUM = 1;
	var MAKE_ARRAY = 2;
	var MAKE_OBJ = 3;
	var VAR = 10;
	var JAVASCRIPT = 11;
	var UUID = 169;
	var HTTP = 153;
	var ERROR = 12;
	var IMPLICIT_VAR = 13;
	var DB = 14;
	var TABLE = 15;
	var GET = 16;
	var GET_ALL = 78;
	var EQ = 17;
	var NE = 18;
	var LT = 19;
	var LE = 20;
	var GT = 21;
	var GE = 22;
	var NOT = 23;
	var ADD = 24;
	var SUB = 25;
	var MUL = 26;
	var DIV = 27;
	var MOD = 28;
	var FLOOR = 183;
	var CEIL = 184;
	var ROUND = 185;
	var APPEND = 29;
	var PREPEND = 80;
	var DIFFERENCE = 95;
	var SET_INSERT = 88;
	var SET_INTERSECTION = 89;
	var SET_UNION = 90;
	var SET_DIFFERENCE = 91;
	var SLICE = 30;
	var SKIP = 70;
	var LIMIT = 71;
	var OFFSETS_OF = 87;
	var CONTAINS = 93;
	var GET_FIELD = 31;
	var KEYS = 94;
	var VALUES = 186;
	var OBJECT = 143;
	var HAS_FIELDS = 32;
	var WITH_FIELDS = 96;
	var PLUCK = 33;
	var WITHOUT = 34;
	var MERGE = 35;
	var BETWEEN_DEPRECATED = 36;
	var BETWEEN = 182;
	var REDUCE = 37;
	var MAP = 38;
	var FOLD = 187;
	var FILTER = 39;
	var CONCAT_MAP = 40;
	var ORDER_BY = 41;
	var DISTINCT = 42;
	var COUNT = 43;
	var IS_EMPTY = 86;
	var UNION = 44;
	var NTH = 45;
	var BRACKET = 170;
	var INNER_JOIN = 48;
	var OUTER_JOIN = 49;
	var EQ_JOIN = 50;
	var ZIP = 72;
	var RANGE = 173;
	var INSERT_AT = 82;
	var DELETE_AT = 83;
	var CHANGE_AT = 84;
	var SPLICE_AT = 85;
	var COERCE_TO = 51;
	var TYPE_OF = 52;
	var UPDATE = 53;
	var DELETE = 54;
	var REPLACE = 55;
	var INSERT = 56;
	var DB_CREATE = 57;
	var DB_DROP = 58;
	var DB_LIST = 59;
	var TABLE_CREATE = 60;
	var TABLE_DROP = 61;
	var TABLE_LIST = 62;
	var CONFIG = 174;
	var STATUS = 175;
	var WAIT = 177;
	var RECONFIGURE = 176;
	var REBALANCE = 179;
	var SYNC = 138;
	var GRANT = 188;
	var INDEX_CREATE = 75;
	var INDEX_DROP = 76;
	var INDEX_LIST = 77;
	var INDEX_STATUS = 139;
	var INDEX_WAIT = 140;
	var INDEX_RENAME = 156;
	var SET_WRITE_HOOK = 189;
	var GET_WRITE_HOOK = 190;
	var FUNCALL = 64;
	var BRANCH = 65;
	var OR = 66;
	var AND = 67;
	var FOR_EACH = 68;
	var FUNC = 69;
	var ASC = 73;
	var DESC = 74;
	var INFO = 79;
	var MATCH = 97;
	var UPCASE = 141;
	var DOWNCASE = 142;
	var SAMPLE = 81;
	var DEFAULT = 92;
	var JSON = 98;
	var TO_JSON_STRING = 172;
	var ISO8601 = 99;
	var TO_ISO8601 = 100;
	var EPOCH_TIME = 101;
	var TO_EPOCH_TIME = 102;
	var NOW = 103;
	var IN_TIMEZONE = 104;
	var DURING = 105;
	var DATE = 106;
	var TIME_OF_DAY = 126;
	var TIMEZONE = 127;
	var YEAR = 128;
	var MONTH = 129;
	var DAY = 130;
	var DAY_OF_WEEK = 131;
	var DAY_OF_YEAR = 132;
	var HOURS = 133;
	var MINUTES = 134;
	var SECONDS = 135;
	var TIME = 136;
	var MONDAY = 107;
	var TUESDAY = 108;
	var WEDNESDAY = 109;
	var THURSDAY = 110;
	var FRIDAY = 111;
	var SATURDAY = 112;
	var SUNDAY = 113;
	var JANUARY = 114;
	var FEBRUARY = 115;
	var MARCH = 116;
	var APRIL = 117;
	var MAY = 118;
	var JUNE = 119;
	var JULY = 120;
	var AUGUST = 121;
	var SEPTEMBER = 122;
	var OCTOBER = 123;
	var NOVEMBER = 124;
	var DECEMBER = 125;
	var LITERAL = 137;
	var GROUP = 144;
	var SUM = 145;
	var AVG = 146;
	var MIN = 147;
	var MAX = 148;
	var SPLIT = 149;
	var UNGROUP = 150;
	var RANDOM = 151;
	var CHANGES = 152;
	var ARGS = 154;
	var BINARY = 155;
	var GEOJSON = 157;
	var TO_GEOJSON = 158;
	var POINT = 159;
	var LINE = 160;
	var POLYGON = 161;
	var DISTANCE = 162;
	var INTERSECTS = 163;
	var INCLUDES = 164;
	var CIRCLE = 165;
	var GET_INTERSECTING = 166;
	var FILL = 167;
	var GET_NEAREST = 168;
	var POLYGON_SUB = 171;
	var MINVAL = 180;
	var MAXVAL = 181;
}

enum TermBase {
	TDatum(datum:Datum);
	TMakeArray(args:TermArgs, ?options:TermOptions);
	TMakeObj(args:TermArgs, ?options:TermOptions);
	TVar(args:TermArgs, ?options:TermOptions);
	TJavascript(args:TermArgs, ?options:TermOptions);
	TUuid(args:TermArgs, ?options:TermOptions);
	THttp(args:TermArgs, ?options:TermOptions);
	TError(args:TermArgs, ?options:TermOptions);
	TImplicitVar(args:TermArgs, ?options:TermOptions);
	TDb(args:TermArgs, ?options:TermOptions);
	TTable(args:TermArgs, ?options:TermOptions);
	TGet(args:TermArgs, ?options:TermOptions);
	TGetAll(args:TermArgs, ?options:TermOptions);
	TEq(args:TermArgs, ?options:TermOptions);
	TNe(args:TermArgs, ?options:TermOptions);
	TLt(args:TermArgs, ?options:TermOptions);
	TLe(args:TermArgs, ?options:TermOptions);
	TGt(args:TermArgs, ?options:TermOptions);
	TGe(args:TermArgs, ?options:TermOptions);
	TNot(args:TermArgs, ?options:TermOptions);
	TAdd(args:TermArgs, ?options:TermOptions);
	TSub(args:TermArgs, ?options:TermOptions);
	TMul(args:TermArgs, ?options:TermOptions);
	TDiv(args:TermArgs, ?options:TermOptions);
	TMod(args:TermArgs, ?options:TermOptions);
	TFloor(args:TermArgs, ?options:TermOptions);
	TCeil(args:TermArgs, ?options:TermOptions);
	TRound(args:TermArgs, ?options:TermOptions);
	TAppend(args:TermArgs, ?options:TermOptions);
	TPrepend(args:TermArgs, ?options:TermOptions);
	TDifference(args:TermArgs, ?options:TermOptions);
	TSetInsert(args:TermArgs, ?options:TermOptions);
	TSetIntersection(args:TermArgs, ?options:TermOptions);
	TSetUnion(args:TermArgs, ?options:TermOptions);
	TSetDifference(args:TermArgs, ?options:TermOptions);
	TSlice(args:TermArgs, ?options:TermOptions);
	TSkip(args:TermArgs, ?options:TermOptions);
	TLimit(args:TermArgs, ?options:TermOptions);
	TOffsetsOf(args:TermArgs, ?options:TermOptions);
	TContains(args:TermArgs, ?options:TermOptions);
	TGetField(args:TermArgs, ?options:TermOptions);
	TKeys(args:TermArgs, ?options:TermOptions);
	TValues(args:TermArgs, ?options:TermOptions);
	TObject(args:TermArgs, ?options:TermOptions);
	THasFields(args:TermArgs, ?options:TermOptions);
	TWithFields(args:TermArgs, ?options:TermOptions);
	TPluck(args:TermArgs, ?options:TermOptions);
	TWithout(args:TermArgs, ?options:TermOptions);
	TMerge(args:TermArgs, ?options:TermOptions);
	TBetweenDeprecated(args:TermArgs, ?options:TermOptions);
	TBetween(args:TermArgs, ?options:TermOptions);
	TReduce(args:TermArgs, ?options:TermOptions);
	TMap(args:TermArgs, ?options:TermOptions);
	TFold(args:TermArgs, ?options:TermOptions);
	TFilter(args:TermArgs, ?options:TermOptions);
	TConcatMap(args:TermArgs, ?options:TermOptions);
	TOrderBy(args:TermArgs, ?options:TermOptions);
	TDistinct(args:TermArgs, ?options:TermOptions);
	TCount(args:TermArgs, ?options:TermOptions);
	TIsEmpty(args:TermArgs, ?options:TermOptions);
	TUnion(args:TermArgs, ?options:TermOptions);
	TNth(args:TermArgs, ?options:TermOptions);
	TBracket(args:TermArgs, ?options:TermOptions);
	TInnerJoin(args:TermArgs, ?options:TermOptions);
	TOuterJoin(args:TermArgs, ?options:TermOptions);
	TEqJoin(args:TermArgs, ?options:TermOptions);
	TZip(args:TermArgs, ?options:TermOptions);
	TRange(args:TermArgs, ?options:TermOptions);
	TInsertAt(args:TermArgs, ?options:TermOptions);
	TDeleteAt(args:TermArgs, ?options:TermOptions);
	TChangeAt(args:TermArgs, ?options:TermOptions);
	TSpliceAt(args:TermArgs, ?options:TermOptions);
	TCoerceTo(args:TermArgs, ?options:TermOptions);
	TTypeOf(args:TermArgs, ?options:TermOptions);
	TUpdate(args:TermArgs, ?options:TermOptions);
	TDelete(args:TermArgs, ?options:TermOptions);
	TReplace(args:TermArgs, ?options:TermOptions);
	TInsert(args:TermArgs, ?options:TermOptions);
	TDbCreate(args:TermArgs, ?options:TermOptions);
	TDbDrop(args:TermArgs, ?options:TermOptions);
	TDbList(args:TermArgs, ?options:TermOptions);
	TTableCreate(args:TermArgs, ?options:TermOptions);
	TTableDrop(args:TermArgs, ?options:TermOptions);
	TTableList(args:TermArgs, ?options:TermOptions);
	TConfig(args:TermArgs, ?options:TermOptions);
	TStatus(args:TermArgs, ?options:TermOptions);
	TWait(args:TermArgs, ?options:TermOptions);
	TReconfigure(args:TermArgs, ?options:TermOptions);
	TRebalance(args:TermArgs, ?options:TermOptions);
	TSync(args:TermArgs, ?options:TermOptions);
	TGrant(args:TermArgs, ?options:TermOptions);
	TIndexCreate(args:TermArgs, ?options:TermOptions);
	TIndexDrop(args:TermArgs, ?options:TermOptions);
	TIndexList(args:TermArgs, ?options:TermOptions);
	TIndexStatus(args:TermArgs, ?options:TermOptions);
	TIndexWait(args:TermArgs, ?options:TermOptions);
	TIndexRename(args:TermArgs, ?options:TermOptions);
	TSetWriteHook(args:TermArgs, ?options:TermOptions);
	TGetWriteHook(args:TermArgs, ?options:TermOptions);
	TFuncall(args:TermArgs, ?options:TermOptions);
	TBranch(args:TermArgs, ?options:TermOptions);
	TOr(args:TermArgs, ?options:TermOptions);
	TAnd(args:TermArgs, ?options:TermOptions);
	TForEach(args:TermArgs, ?options:TermOptions);
	TFunc(args:TermArgs, ?options:TermOptions);
	TAsc(args:TermArgs, ?options:TermOptions);
	TDesc(args:TermArgs, ?options:TermOptions);
	TInfo(args:TermArgs, ?options:TermOptions);
	TMatch(args:TermArgs, ?options:TermOptions);
	TUpcase(args:TermArgs, ?options:TermOptions);
	TDowncase(args:TermArgs, ?options:TermOptions);
	TSample(args:TermArgs, ?options:TermOptions);
	TDefault(args:TermArgs, ?options:TermOptions);
	TJson(args:TermArgs, ?options:TermOptions);
	TToJsonString(args:TermArgs, ?options:TermOptions);
	TIso8601(args:TermArgs, ?options:TermOptions);
	TToIso8601(args:TermArgs, ?options:TermOptions);
	TEpochTime(args:TermArgs, ?options:TermOptions);
	TToEpochTime(args:TermArgs, ?options:TermOptions);
	TNow(args:TermArgs, ?options:TermOptions);
	TInTimezone(args:TermArgs, ?options:TermOptions);
	TDuring(args:TermArgs, ?options:TermOptions);
	TDate(args:TermArgs, ?options:TermOptions);
	TTimeOfDay(args:TermArgs, ?options:TermOptions);
	TTimezone(args:TermArgs, ?options:TermOptions);
	TYear(args:TermArgs, ?options:TermOptions);
	TMonth(args:TermArgs, ?options:TermOptions);
	TDay(args:TermArgs, ?options:TermOptions);
	TDayOfWeek(args:TermArgs, ?options:TermOptions);
	TDayOfYear(args:TermArgs, ?options:TermOptions);
	THours(args:TermArgs, ?options:TermOptions);
	TMinutes(args:TermArgs, ?options:TermOptions);
	TSeconds(args:TermArgs, ?options:TermOptions);
	TTime(args:TermArgs, ?options:TermOptions);
	TMonday(args:TermArgs, ?options:TermOptions);
	TTuesday(args:TermArgs, ?options:TermOptions);
	TWednesday(args:TermArgs, ?options:TermOptions);
	TThursday(args:TermArgs, ?options:TermOptions);
	TFriday(args:TermArgs, ?options:TermOptions);
	TSaturday(args:TermArgs, ?options:TermOptions);
	TSunday(args:TermArgs, ?options:TermOptions);
	TJanuary(args:TermArgs, ?options:TermOptions);
	TFebruary(args:TermArgs, ?options:TermOptions);
	TMarch(args:TermArgs, ?options:TermOptions);
	TApril(args:TermArgs, ?options:TermOptions);
	TMay(args:TermArgs, ?options:TermOptions);
	TJune(args:TermArgs, ?options:TermOptions);
	TJuly(args:TermArgs, ?options:TermOptions);
	TAugust(args:TermArgs, ?options:TermOptions);
	TSeptember(args:TermArgs, ?options:TermOptions);
	TOctober(args:TermArgs, ?options:TermOptions);
	TNovember(args:TermArgs, ?options:TermOptions);
	TDecember(args:TermArgs, ?options:TermOptions);
	TLiteral(args:TermArgs, ?options:TermOptions);
	TGroup(args:TermArgs, ?options:TermOptions);
	TSum(args:TermArgs, ?options:TermOptions);
	TAvg(args:TermArgs, ?options:TermOptions);
	TMin(args:TermArgs, ?options:TermOptions);
	TMax(args:TermArgs, ?options:TermOptions);
	TSplit(args:TermArgs, ?options:TermOptions);
	TUngroup(args:TermArgs, ?options:TermOptions);
	TRandom(args:TermArgs, ?options:TermOptions);
	TChanges(args:TermArgs, ?options:TermOptions);
	TArgs(args:TermArgs, ?options:TermOptions);
	TBinary(args:TermArgs, ?options:TermOptions);
	TGeojson(args:TermArgs, ?options:TermOptions);
	TToGeojson(args:TermArgs, ?options:TermOptions);
	TPoint(args:TermArgs, ?options:TermOptions);
	TLine(args:TermArgs, ?options:TermOptions);
	TPolygon(args:TermArgs, ?options:TermOptions);
	TDistance(args:TermArgs, ?options:TermOptions);
	TIntersects(args:TermArgs, ?options:TermOptions);
	TIncludes(args:TermArgs, ?options:TermOptions);
	TCircle(args:TermArgs, ?options:TermOptions);
	TGetIntersecting(args:TermArgs, ?options:TermOptions);
	TFill(args:TermArgs, ?options:TermOptions);
	TGetNearest(args:TermArgs, ?options:TermOptions);
	TPolygonSub(args:TermArgs, ?options:TermOptions);
	TMinval(args:TermArgs, ?options:TermOptions);
	TMaxval(args:TermArgs, ?options:TermOptions);
}