package tink.protocol.websocket;

import tink.streams.Accumulator;
import tink.streams.Stream;
import tink.streams.IdealStream;
import tink.streams.RealStream;
import tink.io.StreamParser;
import tink.Url;
import tink.Chunk;

using tink.CoreApi;
using tink.io.Source;

class Connector {
	public static function wrap(url:Url, handler:tink.protocol.Handler, ?onError:Error->Void):tink.tcp.Handler {
		if(onError == null) onError = function(_) {}
		
		return function(i:tink.tcp.Incoming):Future<tink.tcp.Outgoing> {
			var trigger:SignalTrigger<Yield<Chunk, Noise>> = Signal.trigger();
			var outgoing = {
				stream: new SignalStream(trigger.asSignal()),
				allowHalfOpen: true,
			}
			
			var header = new OutgoingHandshakeRequestHeader(url);
			var accept = header.accept;
			trigger.trigger(Data(@:privateAccess Chunk.ofString(header.toString())));
			
			i.stream.parse(IncomingHandshakeResponseHeader.parser())
				.handle(function(o) switch o {
					case Success({a: header, b: rest}):
						switch header.validate(accept) {
							case Success(_): // ok
							case Failure(e): onError(e);
						}
						
						// outgoing
						var send = handler(rest.parseStream(new Parser()));
						send.forEach(function(chunk) {
							trigger.trigger(Data(chunk));
							return Resume;
						}).handle(function(_) trigger.trigger(End));
					case Failure(e):
						onError(e);
				});
			return Future.sync(outgoing);
		}
	}
}

