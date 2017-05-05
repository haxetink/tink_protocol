package tink.protocol.websocket;

import tink.streams.Accumulator;
import tink.streams.Stream;
import tink.streams.IdealStream;
import tink.streams.RealStream;
import tink.io.StreamParser;
import tink.http.Request;
import tink.http.Response;
import tink.Url;
import tink.Chunk;

using tink.CoreApi;
using tink.io.Source;

class Acceptor {
	public static function wrap(handler:tink.protocol.Handler, ?onError:Error->Void):tink.tcp.Handler {
		if(onError == null) onError = function(e) trace(e);
		
		return function(i:tink.tcp.Incoming):Future<tink.tcp.Outgoing> {
			return Future.sync({
				stream: Generator.stream(function(step) {
					i.stream.parse(IncomingHandshakeRequestHeader.parser())
						.handle(function(o) switch o {
							case Success({a: header, b: rest}):
								switch header.validate() {
									case Success(_): // ok
									case Failure(e): onError(e);
								}
								var reponseHeader = new OutgoingHandshakeResponseHeader(header.key);
								step(Link((reponseHeader.toString():Chunk), handler(rest.parseStream(new Parser()))));
							case Failure(e):
								onError(e);
						});
				}),
				allowHalfOpen: true,
			});
		}
	}
	
	public static function http(handler:tink.http.Handler, ws:tink.protocol.Handler):tink.http.Handler {
		return function(req:IncomingRequest):Future<OutgoingResponse> {
			var header:IncomingHandshakeRequestHeader = req.header;
			return switch [header.validate(), req.body] {
				case [Success(_), Plain(src)]:
					src.all().handle(function(c) trace('chunk:' + c.sure()));
					Future.sync(new OutgoingResponse(
						new OutgoingHandshakeResponseHeader(header.key),
						(ws(src.parseStream(new Parser())):Stream<Chunk, Noise>)
					));
				default:
					handler.process(req);
			}
		}
	}
}

