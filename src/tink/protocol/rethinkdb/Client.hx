package tink.protocol.rethinkdb;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.Json;
import haxe.crypto.*;
import tink.io.Duplex;
import tink.io.Source;
import tink.streams.Stream;
import tink.streams.Accumulator;
import tink.protocol.Client as TinkClient;

using tink.CoreApi;
using StringTools;

class Client implements TinkClient<Response, Query> {
	
	var protocol:Protocol;
	
	public function new(duplex:Duplex) {
		this.protocol = new Protocol(duplex);
	}
	
	public function connect(send:Stream<Query>):Stream<Response> {
		var out = send.map(function(query) return query.toBytes());
		return protocol.connect(out).map(function(bytes):Response return bytes);
	}
	
	public static function sender()
		return new Sender();
}

class Protocol implements TinkClient<Bytes, Bytes> {
	
	var duplex:Duplex;
	var options:Options;
	
	public function new(duplex:Duplex, ?options:Options) {
		this.duplex = duplex;
		if(options == null) options = {};
		if(options.username == null) options.username = 'admin';
		if(options.password == null) options.password = '';
		this.options = options;
	}
	
	public function connect(send:Stream<Bytes>):Stream<Bytes> {
		
		// write the magic number
		var out = new BytesOutput();
		out.writeInt32(0x34c2bdc3);
		(out.getBytes():Source).pipeTo(duplex.sink).handle(function(){});
		
		function sendJson(obj:{}) {
			var out = new BytesOutput();
			out.writeString(Json.stringify(obj));
			out.writeByte(0);
			return (out.getBytes():Source).pipeTo(duplex.sink);
		}
		
		var scram = new scram.ScramClient(options.username, options.password, SHA256);
		var source = duplex.source;
		var parser = new HandshakeParser();
		return source.parse(parser) >>
			function(o:{data:Bytes, rest:Source}) {
				source = o.rest;
				var str = o.data.toString();
				return try {
					var result = Json.parse(str);
					if(result.success) Success(Noise);
					else Failure(new Error('Unsuccessful operation: $str'));
				} catch(e:Dynamic) {
					Failure(new Error('Server handshake error: $str'));
				}
			} >>
			function(_) return sendJson({
				protocol_version: 0,
				authentication_method: 'SCRAM-SHA-256',
				authentication: scram.clientFirstMessage,
			}) >>
			function(_) return source.parse(parser) >>
			function(o:{data:Bytes, rest:Source}) {
				source = o.rest;
				var str = o.data.toString();
				var result = Json.parse(str);
				return if(result.success) {
					scram.serverFirstMessage = result.authentication;
					Success(Noise);
				}
				else Failure(new Error('Unsuccessful operation: $str'));
			} >>
			function(_) return sendJson({
				authentication: scram.clientFinalMessage,
			}) >>
			function(_) return source.parse(parser) >>
			function(o:{data:Bytes, rest:Source}) {
				source = o.rest;
				var str = o.data.toString();
				var result = Json.parse(str);
				return if(result.success) {
					try {
						scram.serverFinalMessage = result.authentication;
						send.forEachAsync(function(bytes) return (bytes:Source).pipeTo(duplex.sink).map(function(_) return true));
						Success(source.parseStream(new Parser()));
					} catch(e:Dynamic) Failure(new Error(Std.string(e)));
				}
				else Failure(new Error('Unsuccessful operation: $str'));
			}
	}
	
}

class Sender extends Accumulator<Query> {
	public function send(data:Query) yield(Data(data));
}

typedef Options = {
	?username:String,
	?password:String,
}