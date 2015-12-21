-module (lib_misc).
-export ([sleep/1, flush_buffer/0]).

% Implements a simple timer using an empty receive with a timeout.
sleep(Millis) ->
	receive
		after Millis -> true
	end.

% Implements a process mailbox flusher by consuming all messages. 
% The message mailbox is processed once if the timeout for the
% after is 0. 
flush_buffer() ->
	receive
		_Any -> 
		io:format("Discarding: ~p~n", [_Any]),
		flush_buffer()
	after 0 -> true
	end.