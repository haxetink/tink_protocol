package tink.protocol;

import tink.io.StreamParser;

using tink.CoreApi;
using tink.io.Source;

class Protocol {
	// public static function wrap(parser:StreamParser<Chunk>, handler:Handler):tink.tcp.Handler {
	// 	return function(i:tink.tcp.Incoming):Future<tink.tcp.Outgoing> {
	// 		return Future.sync({
	// 			stream: handler(i.stream.parseStream(parser)),
	// 			allowHalfOpen: true,
	// 		});
	// 	}
	// }
}