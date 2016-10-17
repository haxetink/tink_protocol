package;

import buddy.*;
import bson.*;
import haxe.io.Bytes;
import tink.io.Source;
import tink.tcp.Connection;
import tink.protocol.mongodb.Parser;
import tink.protocol.mongodb.Client;
import tink.protocol.mongodb.Message;

using buddy.Should;

class TestMongoDB extends BuddySuite {
	public function new() {
		
		timeoutMs = 1500;
		describe("MongoDB", {
			describe("Client", {
				it("should list collections in database", function(done) {
					var client = new Client(Connection.establish(27017));
					var sender = Client.sender();
					client.connect(sender).forEach(function(message) {
						switch message {
							case Response(body): done(); // TODO: do some checks
							default: fail('Invalid reponse message type');
						}
						return false;
					});
					
					// send a 'listCollections' command towards the db named 'test'
					sender.send(Query(new QueryMessageBody(0, "test.$cmd", 0, -1, {'listCollections': 1})));
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