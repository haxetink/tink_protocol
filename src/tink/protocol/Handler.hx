package tink.protocol;

import tink.streams.IdealStream;
import tink.streams.RealStream;

using tink.CoreApi;

typedef Handler = RealStream<Chunk>->IdealStream<Chunk>;