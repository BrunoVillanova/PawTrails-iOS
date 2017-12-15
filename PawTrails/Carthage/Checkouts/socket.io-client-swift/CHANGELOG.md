# v13.1.0

- Allow setting `SocketEngineSpec.extraHeaders` after init.
- Deprecate `SocketEngineSpec.websocket` in favor of just using the `SocketEngineSpec.polling` property.
- Enable bitcode for most platforms.
- Fix [#882](https://github.com/socketio/socket.io-client-swift/issues/882). This adds a new method
`SocketManger.removeSocket(_:)` that should be called if when you no longer wish to use a socket again.
This will cause the engine to no longer keep a strong reference to the socket and no longer track it.

# v13.0.1

- Fix not setting handleQueue on `SocketManager`

# v13.0.0

Checkout out the migration guide in Usage Docs for a more detailed guide on how to migrate to this version.

What's new:
---

- Adds a new `SocketManager` class that multiplexes multiple namespaces through a single engine. 
- Adds `.sentPing` and `.gotPong` client events for tracking ping/pongs.
- watchOS support.

Important API changes
---

- Many properties that were previously on `SocketIOClient` have been moved to the `SocketManager`.
- `SocketIOClientOption.nsp` has been removed. Use `SocketManager.socket(forNamespace:)` to create/get a socket attached to a specific namespace.
- Adds `.sentPing` and `.gotPong` client events for tracking ping/pongs.
- Makes the framework a single target.
- Updates Starscream to 3.0

