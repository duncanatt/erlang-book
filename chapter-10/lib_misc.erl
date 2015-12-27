-module (lib_misc).
-export ([monitor_start/0, monitor_stop/0]).
-import (net_kernel, [monitor_nodes/1]).

% Starts a monitor which listens to node connection and
% disconnection events.
monitor_start() -> register(node_mon, spawn(fun() -> 
		monitor_nodes(true),
		io:format("Started monitor~n"),
		loop() 
	end)).

% Stops the monitor.
monitor_stop() -> 
	monitor_nodes(false),
	io:format("Stopping monitor~n"),
	node_mon ! stop.

% The main process loop which receives node connection
% and disconnection events.
loop() -> 
	receive
		{nodeup, Node} ->
			io:format("Node ~p is up~n", [Node]),
			loop();
		{nodedown, Node} ->
			io:format("Node ~p is down~n", [Node]),
			loop();
		stop -> 
			void
	end.