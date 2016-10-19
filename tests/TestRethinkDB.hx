package;

import buddy.*;
import bson.*;
import haxe.io.Bytes;
import tink.io.Source;
import tink.tcp.Connection;
import tink.protocol.rethinkdb.Client;
import tink.protocol.rethinkdb.Parser;
import tink.protocol.rethinkdb.Query;
import tink.protocol.rethinkdb.Term;
import tink.protocol.rethinkdb.Datum;

using tink.CoreApi;
using buddy.Should;

class TestRethinkDB extends BuddySuite {
	public function new() {
		
		timeoutMs = 1000;
		describe("RethinkDB", {
			describe("Client", {
				it("should list collections in database", function(done) {
					var client = new Client(Connection.establish(28015));
					var sender = Client.sender();
					client.connect(sender).forEach(function(res) {
						trace(haxe.Json.stringify(res));
						done();
						return false;
					});
					
					sender.send(new Query(1, new Term(1, Str('foo')), haxe.Int64.make(0, 1)));
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