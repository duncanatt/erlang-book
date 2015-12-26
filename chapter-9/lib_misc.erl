-module (lib_misc).
-export ([on_exit/2, keep_alive/2]).

% Provides an error handler process which is started as a system process.
% It is able to capture all error messages (including the normal exit mode),
% but not kill exit signals, as these are untrappable by any process, system
% or otherwise.
on_exit(Pid, Fun) ->
	spawn(fun() -> 
		process_flag(trap_exit, true),
		link(Pid),
		receive
			{'EXIT', Pid, Why} -> Fun(Why)
		end
	end).

% Detects that the process has exited, and restarts it automatically.
keep_alive(Name, Fun) ->
	register(Name, Pid = spawn(Fun)),
	on_exit(Pid, fun(_Why) -> keep_alive(Name, Fun) end).