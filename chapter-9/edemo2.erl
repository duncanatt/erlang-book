-module (edemo2).
-export ([start/2]).

% Starts 3 linked processes, A, B and C. A is system process which 
% traps all exit signals. B traps signals depending on the value of Bool
% flag. C dies according to the value of M.
start(Bool, M) ->
	A = spawn(fun() -> a() end),
	B = spawn(fun() -> b(A, Bool, M) end),
	C = spawn(fun() -> c(B, M) end),
	sleep(2000),
	status(a, A),
	status(b, B),
	status(c, C).

% The system process which traps all exit signals.
a() ->
	process_flag(trap_exit, true),
	wait(a).

% Depending on the value of Bool, b is created as a system process or not.
% Process b is linked to process a.
b(A, Bool, M) ->
	process_flag(trap_exit, Bool),
	link(A),
	sleep(1000),
	exit(M),
	wait(b).

% C is a system process which is linked to be an sends exit signals directly
% to process b, without C itself dying.
c(B, M) ->
	process_flag(trap_exit, true),
	link(B),
	% exit(B, M),
	wait(c).
	

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