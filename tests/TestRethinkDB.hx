package;

import buddy.*;
import bson.*;
import haxe.io.Bytes;
import tink.io.Source;
import tink.tcp.Connection;
import tink.streams.Accumulator;
import tink.protocol.rethinkdb.Client;
import tink.protocol.rethinkdb.Parser;
import tink.protocol.rethinkdb.Query;
import tink.protocol.rethinkdb.Term;
import tink.protocol.rethinkdb.Datum;
import tink.protocol.rethinkdb.RawResponse;

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
						var res:RawResponse = bytes;
						trace(res.json);
						if(++c >= n+2) done();
						return true;
					});
					
					// run the command: r.db('rethinkdb').table('users')
					var db = TDb([TDatum('rethinkdb')]);
					var table = TTable([db, TDatum('users')]);
					var query:Query = QStart(table);
					for(i in 0...n) sender.yield(Data(query.toBytes())); // run a few times....
					
					// query server info
					var query:Query = QServerInfo;
					sender.yield(Data(query.toBytes()));
					
					// insert a doc
					var db = TDb([TDatum('test')]);
					var table = TTable([db, TDatum('tink_protocol')]);
					var insert = TInsert([table, TDatum([
						new NamedWith('null', DNull),
						new NamedWith('bool', DBool(true)),
						new NamedWith('number', DNumber(18)),
						new NamedWith('string', DString('mystring')),
						new NamedWith('array', DArray([1,2,3,4])),
						new NamedWith('object', DObject([
							new NamedWith('bool', DBool(true)),
							new NamedWith('number', DNumber(18)),
						])),
						new NamedWith('date', DDate(Date.now())),
						new NamedWith('binary', DBinary(Bytes.alloc(10))),
					])]);
					var query:Query = QStart(insert);
					sender.yield(Data(query.toBytes()));
					
					// insert a doc using json string
					var insert = TInsert([table, TDatum(DJson('{"json":123}'))]);
					var query:Query = QStart(insert);
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