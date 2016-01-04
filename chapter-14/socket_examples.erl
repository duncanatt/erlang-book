-module (socket_examples).
-export ([nano_get_url/2, start_nano_server/0, nano_client_eval/1]).

% Performs a GET request on the host using the specified port.
nano_get_url(Host, Port) ->
	
	% Open TCP connection with host.
	{ok, Socket} = gen_tcp:connect(Host, Port, [binary, {packet, 0}]),

	% Perform GET request on socket.
	ok = gen_tcp:send(Socket, "GET / HTTP/1.0\r\n\r\n"),

	% Read incoming data from socket.
	receive_data(Socket, []).

% Reads the data from the incoming socket. This is done by waiting for
% data messages from the Socket.
receive_data(Socket, ResponseAcc) ->
	receive
		{tcp, Socket, Bin} ->
			receive_data(Socket, [Bin | ResponseAcc]);
		{tcp_closed, Socket} ->
			list_to_binary(lists:reverse(ResponseAcc))
	end.

start_nano_server() ->

	% Set up listening port and configure application message
	% packaging conventions.
	{ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4}, 
												 {reuseaddr, true},
												 {active, true}]),

	% Listen for new incoming connections.
	{ok, Socket} = gen_tcp:accept(Listen),

	% Close listening port to pevent new clients from connecting. 
	% This does not affect the currently active client connected to
	% Socket.
	gen_tcp:close(Listen),

	% Serve client.
	loop(Socket).

loop(Socket) ->
	receive

		{tcp, Socket, Bin} ->

			% Server is receiving incoming data.
			io:format("Server received binary: ~p~n", [Bin]),

			% Convert the binary packet to an erlang term
			Term = binary_to_term(Bin),
			io:format("Server unpacked term: ~p~n", [Term]),

			% Evaluate erlang term, which is the reply to be sent to
			% the client.
			Reply = lib_misc:string2value(Term),
			io:format("Server replying with: ~p~n", [Reply]),

			% Send reply back to the client.
			gen_tcp:send(Socket, term_to_binary(Reply)),
			loop(Socket);

		{tcp_closed, Socket} ->

			% Client closed connection.
			io:format("Server closed socket~n")
	end.

nano_client_eval(Str) ->

	% Connect to the server hosted on localhost, and configure application
	% message package conventions.
	{ok, Socket} = gen_tcp:connect("localhost", 2345, [binary, {packet, 4}]),

	% Convert the string to send to binary, and send it to the server.
	% The server will do the opposite conversion and evaluate the Str
	% accoringly.
	B = term_to_binary(Str),
	io:format("Sending binary: ~p~n", [B]),
	ok = gen_tcp:send(Socket, B),

	% Await reply from the server.
	receive
		{tcp, Socket, Bin} ->

			% Client is receving incoming data.
			io:format("Client received binary: ~p~n", [Bin]),

			% Convert the binary packet to erlang term.
			Term = binary_to_term(Bin),
			io:format("Client result: ~p~n", [Term]),

			% Finally close client socket.
			gen_tcp:close(Socket);

		{tcp_closed, Socket} ->
			io:format("Connection with server closed~n")
	end.
