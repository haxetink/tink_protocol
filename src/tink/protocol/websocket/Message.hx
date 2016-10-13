package tink.protocol.websocket;

import haxe.io.Bytes;

enum Message {
	Text(v:String);
	Binary(b:Bytes);
	ConnectionClose;
	Ping(b:Bytes);
	Pong(b:Bytes);
}