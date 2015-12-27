-module(lib_find).
-export([files/3, files/5, file_type/1]).

-include_lib("kernel/include/file.hrl").

% Find files in the specified directory conveniently using
% the file extension.
files(Dir, Ext, Recurse) ->
	F = fun(File, Acc) -> [File | Acc] end,
	files(Dir, "^.*" ++ Ext ++ "$", Recurse, F, []).

% Find files in the specified directory using the specified
% regex, mapping function and initial accumulator list.
files(Dir, RegExp, Recurse, Fun, Acc) ->
	case file:list_dir(Dir) of
		{ok, Files} ->
			
			% Find files which match the specified regular expression.
			find_files(Files, Dir, RegExp, Recurse, Fun, Acc);
		{error, _} -> 

			% An error occurred, just return the accumulator as is.
			Acc
	end.

% Finds file recursively according to the specified regular expression.
% If the current file being processed matches the regular expression,
% then the function Fun is called on it, and the result is used as
% the new accumulator. Furthermore, if the Recurse flag is true,
% this function recurses through them by calling the files() function
% on the directory being processed.
find_files([File | Rest], Dir, RegExp, Recurse, Fun, Acc) ->
	
	% Find information for the current file, and depending on its
	% type, determine whether to return the file, or recurse through
	% the directory.
	FullName = filename:join([Dir, File]),
	case file_type(FullName) of

		regular ->

			% The current file is a regular file. We need to see whether it
			% matches with the regular expression, and if it does, we call
			% Fun on it with the current value of the accumulator.
			try re:run(FullName, RegExp) of
				{match, _} ->

					% File matches regular expression pattern. Call Fun on the
					% current file and current accumulator. Then process the
					% rest of the list.
					Res = Fun(FullName, Acc),
					find_files(Rest, Dir, RegExp, Recurse, Fun, Res);
				nomatch ->

					% File does not match regular expression. Continue as is
					% but do not call Fun on the current file.
					find_files(Rest, Dir, RegExp, Recurse, Fun, Acc)
			catch
				_:_ -> 

					% An error occurred while evaluating the regular expression match.
					% Continue as is, but do not call Fun on the current file.
					find_files(Rest, Dir, RegExp, Recurse, Fun, Acc)
			end;
		directory ->

			% The current file is a directory. We need to see whether the 
			% recurse flag is set, and if it is, we call the files()
			% function on the current directory as well.
			case Recurse of
				true ->

					% We should recurse on this directory, and that means running
					% the function files() on the current directoy. Once we get the
					% results, which should contain any previous accumulated results
					% in Acc plus the new results found, we continue as is, processing
					% the rest of the list.
					Res = files(FullName, RegExp, Recurse, Fun, Acc),
					find_files(Rest, Dir, RegExp, Recurse, Fun, Res);
				false ->

					% We are not to recurse on this directory, so we skip it.
					% Continue as is.
					find_files(Rest, Dir, RegExp, Recurse, Fun, Acc)	
			end;
		error ->

			% An error occurred while reading the file information.
			% Continue as is, but do not call Fun on the current file.
			find_files(Rest, Dir, RegExp, Recurse, Fun, Acc)
	end;
find_files([], _, _, _, _, Acc) -> Acc.	

% Returns the type of the specified file.
file_type(File) ->
	case file:read_file_info(File) of
		{ok, Info} ->
			
			% Extract the file type from the file information record.
			case Info#file_info.type of
				regular -> regular;
				directory -> directory;
				_ -> error
			end;
		_ -> 

			% Error reading file info.
			error
	end.