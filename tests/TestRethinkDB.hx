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
					var c = 0;
					var n = 4;
					client.connect(sender).forEach(function(bytes) {
						var res:RawResponse = bytes;
						trace(res.json);
						if(++c >= n) done();
						return true;
					});
					
					var db = Db([Datum('rethinkdb')]);
					var table = Table([db, Datum('users')]);
					for(i in 0...n) sender.yield(Data(new Query(START, table).toBytes()));
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