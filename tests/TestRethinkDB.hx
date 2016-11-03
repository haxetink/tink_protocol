package;

import buddy.*;
import bson.*;
import haxe.io.Bytes;
import tink.io.Source;
import tink.tcp.Connection;
import tink.streams.Accumulator;
import tink.protocol.rethinkdb.Client;
import tink.protocol.rethinkdb.Parser;
import tink.protocol.rethinkdb.Response;

using tink.protocol.rethinkdb.Query;
using tink.protocol.rethinkdb.Term;
using tink.protocol.rethinkdb.Datum;
using tink.CoreApi;
using buddy.Should;

class TestRethinkDB extends BuddySuite {
	public function new() {
		
		timeoutMs = 1000;
		describe("RethinkDB", {
			describe("Client", {
				it("should list users in database", function(done) {
					var client = new Client(Connection.establish(28015));
					var sender = new Accumulator();
					var c = 0;
					var n = 4;
					client.connect(sender).forEach(function(bytes) {
						var res:Response = bytes;
						trace(res.json);
						if(++c >= n+2) done();
						return true;
					});
					
					// run the command: r.db('rethinkdb').table('users')
					var db = TDb([TDatum(DString('rethinkdb'))]);
					var table = TTable([db, TDatum(DString('users'))]);
					for(i in 0...n) { // run a few times....
						var query = new Query(QStart(table)); // generate different token
						sender.yield(Data(query.toBytes()));
					}
					
					// query server info
					var query = new Query(QServerInfo);
					sender.yield(Data(query.toBytes()));
					
					// insert a doc
					var db = TDb([TDatum(DString('test'))]);
					var table = TTable([db, TDatum(DString('tink_protocol'))]);
					var insert = TUpdate([table, TDatum(DObject([
						new NamedWith('nothing', null),
						new NamedWith('null', DNull),
						new NamedWith('bool', DBool(true)),
						new NamedWith('number', DNumber(18)),
						new NamedWith('string', DString('mystring')),
						new NamedWith('array', DArray([for(i in 0...4) DNumber(i)])),
						new NamedWith('object', DObject([
							new NamedWith('bool', DBool(true)),
							new NamedWith('number', DNumber(18)),
						])),
						new NamedWith('date', DDate(Date.now())),
						new NamedWith('binary', DBinary(Bytes.alloc(10))),
					]))]);
					var query = new Query(QStart(insert));
					sender.yield(Data(query.toBytes()));
					
					// insert a doc using json string
					var insert = TInsert([table, TDatum(DJson('{"json":123}'))]);
					var query = new Query(QStart(insert));
					sender.yield(Data(query.toBytes()));
				});
				
			});
		});
	}
	
	function arrayToBytes(a:Array<Int>):Bytes {
		var bytes = Bytes.alloc(a.length);
		for(i in 0...a.length) bytes.set(i, a[i]);
		return bytes;
	}
}