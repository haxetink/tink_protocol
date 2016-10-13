package tink.protocol;

import haxe.io.Bytes;
import tink.streams.Stream;

interface Client<T> {
	function connect(send:Stream<T>):Stream<T>;
}