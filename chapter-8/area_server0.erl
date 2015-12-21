-module (area_server0).
-export ([loop/0]).

% This process loop waits for messages asking it to compute the area.
% This loop must be started in a Pid = spawn(fun ...).
loop() ->
	receive
		{rectangle, Width, Ht} ->
			io:format("Area of rectangle is ~p~n", [Width * Ht]),
			loop();
		{circle, R} ->
			io:format("Area of circle is ~p~n", [3.14159 * R * R]),
			loop();
		Other ->
			io:format("I don't know what the area of ~p is ~n", [Other]),
			loop()
	end.