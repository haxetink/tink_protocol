package tink.protocol;

import tink.streams.Stream;

interface Client<In, Out> {
	function connect(send:Stream<Out>):Stream<In>;
}