-module (area_server2).
-export ([loop/0, rpc/2]).

% This process loop waits for messages asking it to compute the area.
% This loop must be started in a Pid = spawn(fun ...).
% Messages are expected to be sent back to the sender. For this to be
% possible, the sender must include the Pid.
% To correct the shortcoming of the previous message sending loop, 
% the Pid of the loop() process is included in the reply message
% so that this is filtered by the received (i.e. the rpc/2) function.
loop() ->
	receive
		{From, {rectangle, Width, Ht}} ->
			From ! {self(), Width * Ht},
			loop();
		{From, {circle, R}} ->
			From ! {self(), 3.14159 * R * R},
			loop();
		{From, Other} ->
			From ! {self(), {error, Other}},
			loop()
	end.

% Convenience function which enables the caller to communicate with the
% remote process running the loop() function above. The message being sent
% contains the Pid of the sender. This will be used by the loop() function
% to send the message back.
% To correct the shorcoming of the rpc function, which was able to accept any
% message from any process, we now equipped the recieve call with selective 
% filtering, so that it only consumes messages coming from the sender matching
% with the Pid. For this to be possible, the loop() process must follow the
% protocol, and send it's Pid in the response message, so that we can identify
% messages originating from it.
rpc(Pid, Request) ->
	Pid ! {self(), Request},
	receive
		{Pid, Response} -> Response;
		Any -> {error_shit, Any}
	end.