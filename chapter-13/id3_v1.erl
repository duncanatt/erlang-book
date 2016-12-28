-module (id3_v1).
-import (lists, [filter/2, map/2, reverse/1]).
-export ([dir/1, read_id3_tag/1]).

% Returns a list of ID3 tag information from the list of MP3 files found
% in the directory.
dir(Dir) ->

	% Get the list of files from the specified directory, having the
	% extension MP3.
	Files = lib_find:files(Dir, "mp3", true),

	% Extract the ID3 tag for each of the found MP3 file.
	Tags = map(fun(File) -> read_id3_tag(File) end, Files),

	% Remove those entries in the list whose contents are error.
	filter(fun({error, _}) -> false; (_) -> true end, Tags).


% Reads and returns the ID3 tag from the specified file, or error if
% no ID3 tag exists.
read_id3_tag(File) ->

	% Open MP3 file for reading. To parse the file, we need to go
	% to the last 128 btyes of the file to retreive the fixed-length
	% ID3 tag.
	try file:open(File, [read, binary, raw]) of
		{ok, H} ->

			% File opened successfully. Fetch the last 128 bytes.
			Size = filelib:file_size(File),
			{ok, Tag} = file:pread(H, Size - 128, 128),
			file:close(H),
			parse_v1_tag(Tag)
	catch
		_:Error ->

			% An error occurred when opening the file.
			{error, Error}
	end.


% Parses the ID3 v1/v1.1 tag. Note that the unit for binary is 8 bits (i.e. 1 byte),
% while for integers, it is 1 bit (that is the reason that integer fields have
% :8 as size, since the segment is size * unit, 1 * 8 = 8 bits long).
%
% Matches the ID3 v1.1 tag, having the track number in the comment field.
parse_v1_tag(<<$T, $A, $G, Title:30/binary, Artist:30/binary, Album:30/binary,
			   _Year:4/binary, _Comment:28/binary, 0:8/integer,
			   Track:8/integer, _Genre:8/integer>>) ->
	{"ID3v1.1",
		[{track, Track}, {title, trim(Title)}, {artist, trim(Artist)},
		{album, trim(Album)}]
	};

% Matches the ID3 v1, tag, having a full comment field.
parse_v1_tag(<<$T, $A, $G, Title:30/binary, Artist:30/binary, Album:30/binary,
			   _Year:4/binary, _Comment:30/binary, _Genre:8/integer>>) ->
	{"ID3v1",
		[{title, trim(Title)}, {artist, trim(Artist)}, {album, trim(Album)}]
	};

% Matches any other 128 byte segment which is not and ID3 v1/v1.1 tag.
parse_v1_tag(<<_:128/binary>>) -> {error, []}.


% Removes the null bytes from the list of bytes.
trim(Bin) -> list_to_binary(skip_zero(binary_to_list(Bin))).


% Skips the null byte from the string.
skip_zero([0 | T]) -> skip_zero(T);
skip_zero([H | T]) -> [H | skip_zero(T)];
skip_zero([]) -> [].
