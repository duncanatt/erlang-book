-module(scavenge_urls).
-export([gather_links/2, urls2htmlFile/2, bin2urls/1]).
-import (lists, [reverse/1, reverse/2, map/2]).

% Gathers all HTML hyperlinks from the specified URL, and saves them into
% the specified file.
gather_links(Url, File) ->
	inets:start(),
	{ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} = httpc:request(Url),
	inets:stop(),
	Bin = list_to_binary(Body),
	Urls = bin2urls(Bin),
	urls2htmlFile(Urls, File).

% Writes a list of URLs into their HTML representation.
urls2htmlFile(Urls, File) ->
	file:write_file(File, urls2html(Urls)).

% Extracts a list of HTML anchors from the specified binary.
bin2urls(Bin) -> reverse(gather_urls(binary_to_list(Bin), [])).

% Converts a list of URLs into their HTML representation.
urls2html(Urls) -> [h1("Urls"), make_list(Urls)].

% Returns a list made up of an HTML H1 header.
h1(Title) -> ["<h1>", Title, "</h1>\n"].

% Returns a list made up of an HTML UL element containing all the
% specified URLs as LI elements.
make_list(Urls) ->
	["<ul>\n",
	map(fun(X) -> ["\t<li>", X, "</li>\n"] end, Urls),
	"</ul>\n"].

% Produces a list of URL hyperlinks from the specified list of bytes. 
% Gathered URLs are collected in the accumulator list.
% Matches the start of an HTML anchor link.
gather_urls("<a href" ++ Rest, Acc) ->

	% We found the starting part of the URL link. Collect link till
	% its enclosing HTML anchor. We get back the link and the remainder
	% of the processed list till now.
	{Link, Rem} = collect_url_body(Rest, reverse("<a href")),

	% Add the link to the list accumulated list of links, and gather
	% the next URL.
	gather_urls(Rem, [Link | Acc]);

% Matches any byte, and continues looping over the list of bytes in
% search for the next HTML anchor link.
gather_urls([_ | T], Acc) ->
	gather_urls(T, Acc);

% Matches an empty list of bytes. Returns the accumulator as is.
gather_urls([], Acc) ->
	Acc.

% Collects the HTML anchor link and returns the unfinished process list
% of bytes.
% Matches the end of the HTML anchor link.
collect_url_body("</a>" ++ Rest, RevUrlAcc) -> {reverse(RevUrlAcc, "</a>"), Rest};

% Matches any byte, adds it to the accumulator, and continues looping
% to process the next byte.
collect_url_body([H | T], RevUrlAcc) -> collect_url_body(T, [H | RevUrlAcc]);

% Matches an empty list of bytes, and returns the empty list and also
% the empty list of bytes remaining to be processed.
collect_url_body([], _) -> {[], []}.
