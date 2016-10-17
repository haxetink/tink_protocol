package tink.protocol.websocket;

import tink.http.Response;
import tink.io.StreamParser;

using tink.CoreApi;

abstract IncomingHandshakeResponseHeader(ResponseHeader) from ResponseHeader to ResponseHeader {
	
	public function validate(accept:String) {
		if(this.statusCode != 101) return Failure(new Error('Unexpected response status code'));
		switch this.byName('sec-websocket-accept') {
			case Success(v) if(v == accept):
			default: return Failure(new Error('Invalid accept'));
		}
		return Success(Noise);
	}
	
	public static inline function parser():StreamParser<IncomingHandshakeResponseHeader>
		return ResponseHeader.parser();
}