package tink.protocol.mongodb;

import haxe.io.Bytes;
import tink.io.Duplex;
import tink.io.Source;
import tink.streams.Accumulator;
import tink.streams.Stream;
import tink.protocol.mongodb.Message;
import tink.protocol.Client as TinkClient;

class Client implements TinkClient<Message> {
	
	var protocol:TinkClient<Bytes>;
	
	public function new(duplex:Duplex) {
		this.protocol = new Protocol(duplex);
	}
	
	public function connect(send:Stream<Message>):Stream<Message> {
		var out = send.map(function(message) return message.toBytes());
		return protocol.connect(out).map(function(bytes) return ResponseMessage.fromBytes(bytes).toMessage());
	}
	
	public static function sender()
		return new Sender();
}

class Protocol implements TinkClient<Bytes> {
	
	var duplex:Duplex;
	
	public function new(duplex:Duplex) {
		this.duplex = duplex;
	}
	
	public function connect(send:Stream<Bytes>):Stream<Bytes> {
		// TODO: handle pipe errors, etc
		send.forEachAsync(function(bytes) return (bytes:Source).pipeTo(duplex.sink).map(function(o) return true));
		return duplex.source.parseStream(new Parser());
	}
}

class Sender extends Accumulator<Message> {
	public inline function send(m:Message) yield(Data(m));
}