-module (clock).
-export ([start/2, stop/0]).

% Starts the clock as a process, and registers it as 'clock'.
start(Millis, Fun) -> 
	register(clock, spawn(fun() -> tick(Millis, Fun) end)).

% Stops the clock process loop by sending a stop message.
stop() ->
	clock ! stop.

% The tick function loop which executes Fun after an interval of 
% Millis. If a stop message is received, the function exits.
tick(Millis, Fun) ->
	receive
		stop -> void
	after
		Millis ->
			Fun(),
			tick(Millis, Fun)
	end.