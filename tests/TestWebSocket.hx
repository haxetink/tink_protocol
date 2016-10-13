package;

import buddy.*;
import tink.tcp.Connection;
import tink.url.Host;
import tink.protocol.websocket.WebSocket;
import tink.protocol.websocket.Frame;

using buddy.Should;

class TestWebSocket extends BuddySuite {
	public function new() {
		
		timeoutMs = 1500;
		describe("WebSocket", {
			it("should work with the echo server", function(done) {
				var host = 'echo.websocket.org';
				var connection = Connection.establish({host: host, port: 80});
				var ws = new WebSocket(new ProtocolClient(connection.source, connection.sink, new Host(host), '/'));
				
				var c = 0;
				var n = 3; // TODO: won't work when > 3
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