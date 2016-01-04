-module (lib_misc).
-export ([string2value/1]).

% Evaluates a given string as an erlang term.
string2value(Str) -> 

	% Tokenize the string into erlang tokens. Note that the ending .
	% is automatically added to the Str being evaluated, so that the
	% caller need not add it.
	{ok, Tokens, _} = erl_scan:string(Str ++ "."),

	% Parse the list of erlang tokens into expressions into a suitable
	% parse tree of terms.
	{ok, Exprs} = erl_parse:parse_exprs(Tokens), 

	% Evaluate erlang terms and return the result.
	Bindings = erl_eval:new_bindings(), 
	{value, Value, _} = erl_eval:exprs(Exprs, Bindings), 
	Value.