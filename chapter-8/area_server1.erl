-module (area_server1).
-export ([loop/0, rpc/2]).

% This process loop waits for messages asking it to compute the area.
% This loop must be started in a Pid = spawn(fun ...).
% Messages are expected to be sent back to the sender. For this to be
% possible, the sender must include the Pid.
loop() ->
	receive
		{From, {rectangle, Width, Ht}} ->
			From ! Width * Ht,
			loop();
		{From, {circle, R}} ->
			From ! 3.14159 * R * R,
			loop();
		{From, Other} ->
			From ! {error, Other},
			loop()
	end.

% Convenience function which enables the caller to communicate with the
% remote process running the loop() function above. The message being sent
% contains the Pid of the sender. This will be used by the loop() function
% to send the message back.
rpc(Pid, Request) ->
	Pid ! {self(), Request},
	receive
		Response -> Response
	end.