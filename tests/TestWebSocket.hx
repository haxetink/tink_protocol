package;

import buddy.*;
import tink.tcp.Connection;
import tink.url.Host;
import tink.protocol.websocket.WebSocket;
import tink.protocol.websocket.Frame;

using buddy.Should;

class TestWebSocket extends BuddySuite {
	public function new() {
		
		describe("WebSocket", {
			it("should work with the echo server", function(done) {
				var host = 'echo.websocket.org';
				var connection = Connection.establish({host: host, port: 80});
				var ws = new WebSocket(connection, 'http://$host');
				
				var c = 0;
				var n = 7;
				var sender = WebSocket.sender();
				ws.connect(sender).forEach(function(message) {
					switch message {
						case Text(v): v.should.be('payload' + ++c);
						default: fail('Unexpected message');
					}
					if(c == n) done();
					return c < n;
				});
				
				for(i in 0...n) sender.send(Text('payload' + (i + 1)));
			});
		});
	}
}