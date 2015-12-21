-module (stimer).
-export ([start/2, cancel/1]).

% Cancels the timer by sending a message to the timer process.
cancel(Pid) -> 
	io:format("Cancelling execution of ~p~n", [Pid]),
	Pid ! cancel.

% Starts the timer function in another process.
start(Timeout, Fun) -> 
	spawn(fun() -> timer(Timeout, Fun) end).

% The timer function which executes the specified Fun after
% the Timeout has elapsed. If before that time, a cancel message
% is received, then the function is not executed. Note that this
% function does not loop (i.e. no tail-recursion), and executes
% only once.
timer(Timeout, Fun) ->
	receive
		cancel -> void
	after
		Timeout -> Fun()
	end.