-module (mod_name_server).
-export ([start_me_up/3]).

% The entry function used by the lib_chan:start_server() configuration
% file. Upon a client connecting, the start_server() spawns a new
% process with the start_me_up() function, as specified in the 
% configuration file.
start_me_up(MM, _ArgsC, _ArgsS) ->
	loop(MM).

% The main process loop which recieves store and lookup requests
% from connected clients.
loop(MM) ->
	receive
		{chan, MM, {store, K, V}} ->
			kvs:store(K, V),
			loop(MM);
		{chan, MM, {lookup, K}} ->
			MM ! {send, kvs:lookup(K)},
			loop(MM);
		{chan_closed, MM} ->
			true
	end.