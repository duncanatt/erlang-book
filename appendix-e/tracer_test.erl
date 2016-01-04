-module (tracer_test).
-export ([trace_module/2, test/0]).

% Traces the function StartFun in the specfied Mod.
trace_module(Mod, StartFun) ->
	
	% Spawn process which will be responsible for the tracing.
	spawn(fun() -> trace_module_proc(Mod, StartFun) end).

% Sets up the function tracing pattern using erlang:trace_pattern
% as well as spawns a new process into which the StartFun function
% is evaluated.
trace_module_proc(Mod, StartFun) ->

	% Configure what things will we trace. For the case below,
	% we will trace all function calls and return values in
	% Mod.
	erlang:trace_pattern({Mod, '_', '_'}, 
						 [{'_', [], [{return_trace}]}],
						 [local]),

	% Get the self() PID of the tracer process (i.e. not the process)
	% that we are supposed to trace. This we use so that after we set
	% up everything, in this tracer process, we start the process we 
	% are supposed to trace with a 'start' message.
	% Note also that we are getting the self() PID now, since if we
	% used self() in the spawn (which follows), the PID of the spawned
	% process will be returned, and not the PID of the tracer process.
	Self = self(),

	% Spawn another process into which the function to be actually 
	% monitored (i.e. StartFun) will be started, through a 'start'
	% message from the parent process (i.e. this tracer process).
	Pid = spawn(fun() -> run_trace(Self, StartFun) end),

	% Setup the trace, and tell the system to start tracing the
	% process having Pid. 
	erlang:trace(Pid, true, [call, procs]),

	% Finally, now that everything is set up, we send a message to
	% start the traced process, which is the process running our
	% StartFun function.
	Pid ! {Self, start},

	% Once started, we can immediately start consuming trace events
	% from the tracer process mailbox.
	trace_loop().

% Invokes the StartFun function once a 'start' message has been received.
run_trace(Parent, StartFun) ->
	
	% Wait for the start message from the parent which created this 
	% trace runner process.
	receive
		{Parent, start} -> StartFun()
	end.

% Consumes trace messages from the tracer process mailbox.
trace_loop() ->
	receive
		% {trace, _, call, X} ->

			% A function call message has been found.
			% io:format("Call: ~p~n", [X]),
			% trace_loop();
		% {trace, _, return_from, Call, Ret} ->

			% A function return message has been found.
			% io:format("Return from: ~p => ~p~n", [Call, Ret]),
			% trace_loop();

		Other ->

			% Any other message which we do not care about.
			io:format("Other: ~p~n", [Other]),
			trace_loop()
	end.

% A test function from which we invoke the tracer.
test() ->
	trace_module(tracer_test, fun() -> fib(4) end).

% A test function which computes fibonacci numbers.
fib(0) -> 1;
fib(1) -> 1;
fib(N) -> fib(N - 1) + fib(N - 2).