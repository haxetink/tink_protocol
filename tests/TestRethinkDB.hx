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
					client.connect(sender).forEach(function(bytes) {
						var res:RawResponse = bytes;
						trace(res.json);
						done();
						return false;
					});
					
					var db = new Term(DB, [new Term(DATUM, 'rethinkdb')]);
					var table = new Term(TABLE, [db, new Term(DATUM, 'users')]);
					sender.yield(Data(new Query(START, table, haxe.Int64.make(0, 1)).toBytes()));
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