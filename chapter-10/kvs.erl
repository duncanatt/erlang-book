-module (kvs).
-export ([start/0, stop/0, store/2, lookup/1]).

% Starts the KVS server and regisers the process loop with the 
% process registry under the atom 'kvs'.
start() -> register(kvs, spawn(fun() -> 
		io:format("Starting KVS server~n"),
		loop()
	end)).

% Stops the currently active and registered KVS server.
stop() -> rpc(stop).

% Stores the specified key and value in the KVS process dictionary.
store(Key, Value) -> rpc({store, Key, Value}).

% Retrieves the value for the specified key from the KVS process
% dictionary, if exists.
lookup(Key) -> rpc({lookup, Key}).

% Preforms an RPC request to the KVS process.
rpc(Req) ->
	kvs ! {self(), Req},
	io:format("Sending RPC ~p~n", [Req]),
	receive
		{kvs, Resp} -> Resp
	end. 

% The main KVS process loop which handles the storing and lookup of 
% keys and values. It also supports stopping the loop.
loop() ->
	receive
		{From, {store, Key, Value}} ->
			put(Key, {ok, Value}),
			From ! {kvs, true},
			loop();
		{From, {lookup, Key}} ->
			From ! {kvs, get(Key)},
			loop();
		{From, stop} ->
			io:format("Stopping KVS server~n"),
			From ! {kvs, true}
	end.