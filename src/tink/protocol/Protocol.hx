package tink.protocol;

import tink.Chunk;
import tink.streams.RealStream;

interface Protocol<In, Out> {
	function raw(send:RealStream<Chunk>):RealStream<Chunk>;
	function connect(send:RealStream<Out>):RealStream<In>;
}