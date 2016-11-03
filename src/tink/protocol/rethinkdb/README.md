# Protocol for RethinkDB

Requires: https://github.com/kevinresol/scram (The handshake protocol)

Though the handshake part is handled for you,
this is still pretty low-level. You gotta understand the protocol,
like how queries are formatted and what does the (raw) response looks like.
Relevant information can be found here: https://rethinkdb.com/docs/writing-drivers/

There are some helper (classes/enums) to make it slightly easier.
But again, this library is supposed to be low-level.

Basically you construct a query as follow:

```haxe
// we are to construct the ReQL: `r.db('rethinkdb').table('users')`
var db = TDb([TDatum(DString('rethinkdb'))]);
var table = TTable([db, TDatum(DString('users'))]);
var query = new Query(QStart(table));
trace(query.token); // the query token (identifier)

// convert to bytes which can then be sent through the wire
var bytes = QueryTools.toBytes(query);
```

```haxe
// handle the received bytes from server
var res:Response = bytes; // (you get the bytes by iterating the Stream returned by `connect()`)
trace(res.token); // the token for matching the query (see above)
trace(res.json); // the (unparsed) json string
```

References:

- How to construct Query:
  https://rethinkdb.com/docs/writing-drivers/#serializing-queries
- Spec of Terms:
  https://github.com/rethinkdb/rethinkdb/blob/next/src/rdb_protocol/ql2.proto (the "enum TermType" section)
- How to interpret a Response:
  https://rethinkdb.com/docs/writing-drivers/#receive-responses

Check out the test folder for some more query examples.