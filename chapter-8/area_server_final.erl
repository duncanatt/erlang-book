-module (area_server_final).
-export ([start/0, area/2]).

% Starts the loop function in a spawned process.
start() -> spawn(fun loop/0).

% Computes the area by sending a message to the area server process.
area(Pid, What) -> rpc(Pid, What).

% Performs area calculations by waiting for incoming messages.
loop() ->
	io:format("Started server with PID: ~p~n", [self()]),
	receive
		{From, {rectangle, Width, Height}} -> 
			From ! {self(), Width * Height},
			loop();
		{From, {circle, Radius}} ->
			From ! {self(), 3.14159 * Radius * Radius},
			loop();
		{From, Other} ->
			From ! {self(), {error, Other}},
			loop()
	end.

% Sends area computation requests to the area server process, and 
% retrieves the results.
rpc(Pid, Request) ->
	Pid ! {self(), Request},
	receive
		{Pid, Response} -> Response
	end.