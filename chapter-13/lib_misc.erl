-module (lib_misc).
-export ([consult/1, unconsult/2, file_size_and_type/1, ls/1]).
-import (file, [open/2, close/1, read_file_info/1, list_dir/1]).
-import (io, [read/2, format/3]).
-import (lists, [foreach/2, map/2, sort/1]).
-include_lib ("kernel/include/file.hrl").

% Emulates the native erlang consult() call, albeit with less error
% reporting.
consult(File) ->
	case open(File, read) of
		{ok, Handle} ->
			Term = consult1(Handle),
			close(Handle),
			{ok, Term};
		{error, Reason} ->
			{error, Reason}
	end.

% Reads all the terms in an erlang file, and returns them as a list.
consult1(Handle) ->
	case read(Handle, '') of
		{ok, Term} -> 
			[Term | consult1(Handle)];
		eof -> 
			[];
		Error ->
			Error
	end.

% Performs the inverse of consult, and writes a list of erlang terms
% to file.
unconsult(File, Term) ->
	{ok, Handle} = open(File, write),
	foreach(fun(X) -> format(Handle, "~p.~n", [X]) end, Term),
	close(Handle).

% Gets the size and type of the specified file.
file_size_and_type(File) ->
	case read_file_info(File) of
		{ok, Facts} ->
			{Facts#file_info.type, Facts#file_info.size};
		_ -> error
	end.

% Lists the files in the specified directory, together with their size
% and type.
ls(Dir) ->
	{ok, Files} = list_dir(Dir),
	map(fun(File) -> {File, file_size_and_type(File)} end, sort(Files)).