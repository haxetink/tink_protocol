# Protocol for RethinkDB

Requires: https://github.com/kevinresol/scram (The handshake protocol)

Though the handshake part is handled for you.
This is still pretty low-level. You gotta understand the protocol,
like how queries are formatted and what does the (raw) response looks like.

There are some helper (classes/enums) to make it slightly easier.
But again, this library is supposed to be low-level.

Basically you construct the query as follow:

```haxe
// construct the ReQL: `r.db('rethinkdb').table('users')`
var db = TDb([TDatum('rethinkdb')]);
var table = TTable([db, TDatum('users')]);

// convert to bytes which can then be sent through the wire
var bytes = new Query(START, table).toBytes();
```

Check out the test folder for some more query examples.