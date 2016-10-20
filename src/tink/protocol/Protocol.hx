package tink.protocol;

import haxe.io.Bytes;
import tink.streams.Stream;

interface Protocol {
	function connect(send:Stream<Bytes>):Stream<Bytes>;
}