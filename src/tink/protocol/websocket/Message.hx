package tink.protocol.websocket;

import tink.Chunk;
import tink.streams.Stream;

using tink.CoreApi;

enum Message {
	Text(v:String);
	Binary(b:Chunk);
	ConnectionClose;
	Ping(b:Chunk);
	Pong(b:Chunk);
}

@:forward
abstract MessageStream<Quality>(Stream<Message, Quality>) from Stream<Message, Quality> to Stream<Message, Quality> {
	@:from
	public static inline function ofChunkStream<Q>(s:Stream<Chunk, Q>):MessageStream<Q>
		return ofFrameStream(s.map(Frame.fromChunk));
	@:from
	public static inline function ofFrameStream<Q>(s:Stream<Frame, Q>):MessageStream<Q>
		return s.regroup(MessageRegrouper.get());
	@:to
	public inline function toChunkStream():Stream<Chunk, Quality>
		return toFrameStream().map(function(f:Frame) return f.toChunk());
	@:to
	public inline function toFrameStream():Stream<Frame, Quality>
		return toFrameStreamWithKey(Random);
	
	public function toFrameStreamWithKey(key:KeyType):Stream<Frame, Quality>
		return this.map(function(message) return Frame.ofMessage(message, switch key {
			case None: null;
			case Fixed(k): k;
			case Random: MaskingKey.random();
		}));
}

enum KeyType {
	None;
	Fixed(key:MaskingKey);
	Random;
}

class MessageRegrouper {
	public static function transform<Q>(s:Stream<Chunk, Q>)
		return s.map(Frame.fromChunk).regroup(get());
		
	public static function get<Q>():Regrouper<Frame, Message, Q>
		return cast inst;
	
	static var inst:Regrouper<Frame, Message, Noise> =
		function(frames:Array<Frame>, s) {
			var last = frames[frames.length - 1];
			if(!last.fin) return Untouched;
			
			function mergeBytes() {
				var out = Chunk.EMPTY;
				for(frame in frames) out = out & frame.unmaskedPayload;
				return out;
			}
			
			return Converted(Stream.single(switch frames[0].opcode {
				case Continuation:
					throw 'Unreachable'; // technically
				case Text:
					Message.Text(mergeBytes().toString());
				case Binary:
					Message.Binary(mergeBytes());
				case ConnectionClose:
					Message.ConnectionClose;
				case Ping:
					Message.Ping(mergeBytes());
				case Pong:
					Message.Pong(mergeBytes());
			}));
		}
}