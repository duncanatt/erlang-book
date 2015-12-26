-module (edemo1).
-export ([start/2]).

% Starts 3 linked processes, A, B and C. A is system process which 
% traps all exit signals. B traps signals depending on the value of Bool
% flag. C dies according to the value of M.
start(Bool, M) ->
	A = spawn(fun() -> a() end),
	B = spawn(fun() -> b(A, Bool) end),
	C = spawn(fun() -> c(B, M) end),
	sleep(1000),
	status(b, B),
	status(c, C).

% The system process which traps all exit signals.
a() ->
	process_flag(trap_exit, true),
	wait(a).

% Depending on the value of Bool, b is created as a system process or not.
% Process b is linked to process a.
b(A, Bool) ->
	process_flag(trap_exit, Bool),
	link(A),
	wait(b).

% Depending on M, c decides how is should itself die. It can die by a user-defined
% reason, an arithmetic error or else, normally. Process c is linked to process b.
c(B, M) ->
	link(B),
	case M of
		{die, Reason} ->
			exit(Reason);
		{divide, N} ->
			_ = 1/N,
			wait(c);
		normal ->
			true
	end.

% A waiting loop which consumes messages from the process mailbox, displaying
% the message contents in the console.
wait(Prog) ->
	receive
		Any ->
			io:format("Process ~p received ~p~n", [Prog, Any]),
			wait(Prog)
	end.

% Suspends the target process for T milliseconds.
sleep(T) ->
	receive
	after T -> true
	end.

% Prints out on the console the status of the specified PID.
status(Name, Pid) ->
	case erlang:is_process_alive(Pid) of
		true ->
			io:format("process ~p (~p) is alive~n", [Name, Pid]);
		false ->
			io:format("process ~p (~p) is dead~n", [Name, Pid])
	end.