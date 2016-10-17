package tink.protocol;

import tink.streams.Stream;

interface Client<T> {
	function connect(send:Stream<T>):Stream<T>;
}