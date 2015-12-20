-module (try_test).
-export ([demo1/0, demo2/0, sqrt/1]).

generate_exception(1) -> a;
generate_exception(2) -> throw(a);
generate_exception(3) -> exit(a);
generate_exception(4) -> {'EXIT', a};
generate_exception(5) -> erlang:error(a).

% The first demo generates a list of tuples either by using the 
% normal return message, or else by catching the exeption and
% converting it in a message.
demo1() -> [catcher(I) || I <- [1, 2, 3, 4, 5]].

catcher(N) ->
	try generate_exception(N) of
		Val -> {N, normal, Val}
	catch
		throw: Ex -> {N, caught, thrown, Ex};
		exit: Ex -> {N, caught, exited, Ex};
		error: Ex -> {N, caught, error, Ex}
	end.

% The second demo also generates a list of exeptions but catches
% them using the catch statement. We notice that with the catch 
% statement, a lot of more exception information is provided.
demo2() -> [{I, (catch generate_exception(I))} || I <- [1, 2, 3, 4, 5]].

% In this sqrt function wrapper, we are preventing an actual erlang exception
% from happening using a guard, and then, if we discover some misuse of the 
% arguments (i.e. X < 0), we raise a *custom error* ourselves, to make the
% API more beautiful. 
sqrt(X) when X < 0 -> erlang:error({squareRootNegativeArgument, X});
sqrt(X) -> math:sqrt(X).