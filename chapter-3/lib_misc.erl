-module (lib_misc).
-import (lists, [reverse/1]).
-export ([sum/1, for/3, perms/1, double/2, filter_1/2, filter_2/2, filter_3/2, odds_and_evens_acc/1]).

sum(L) -> sum(L, 0).
sum([], N) -> N;
sum([H|T], N) -> sum(T, H + N).

% Emulates a for loop.
for(Max, Max, F) -> [F(Max)];
for(I, Max, F) -> [F(I)|for(I + 1, Max, F)].

% Returns all the permutations of the specifed word (i.e. list of characters).
perms([]) -> [[]];
perms(L) -> [[H|T] || H <- L, T <- perms(L--[H])].

double([], Result) -> lists:reverse(Result);
double([H|T], Result) ->
	H1 = H * 2,
	double(T, [H1|Result]).


% Filter without using case statement. Since we do not have the ability to
% use case or if statements, we have to decompose filtering into two steps:
% 1. Evaluating Pred(H) on the head.
% 2. Match the boolean pattern accordingly using the filter_bool function.
%    2.1. If true matches (i.e. Pred(H) was true), we add H to the head of the
%         list and evaluate filter on the tail.
%    2.2. If false matches (i.e. Pred(H) was false), we discard H, and evaluate
%         filter on the tail.
filter_1(Pred, [H | T]) -> filter_bool(Pred(H), Pred, H, T);
filter_1(_, []) -> [].

filter_bool(true, Pred, H, T) -> [H | filter_1(Pred, T)];
filter_bool(false, Pred, _H, T) -> filter_1(Pred, T).

% Filter using an if statement. The code is compacted a bit more, and we are able
% to first evaluate Pred(H) and then based on the value, decide whether to add
% H to the filtered list or not.
filter_2(Pred, [H | T]) ->
	X = Pred(H),
	if
		X =:= true -> [H | filter_2(Pred, T)];
		X =:= false -> filter_2(Pred, T)
	end;
filter_2(_Pred, []) -> [].

% Filter using a case statement. The code is also more compact, and evaluation of
% Pred(H) is done in the case statement itself. Depending on the value of Pred(H),
% we add the H accordingly to the list.
filter_3(Pred, [H | T]) ->
	case Pred(H) of
		true -> [H | filter_3(Pred, T)];
		false -> filter_3(Pred, T)
	end;
filter_3(_Pred, []) -> [].

% Divides a list of integers into odds and evens. Note that this function
% makes use of a service function with the same name (i.e. odds_and_evens_acc),
% albeit with a different arity. Since this has a different arity from the
% odds_and_evens_acc below, it must be terminated with a period (.). This reason
% is that a multiple clauses of the *same* functions *must* have the same arity.
% If that is not the case, then the compiler will generate a 'head mismatch' error,
% and the functions would need to be split in different declarations, as the below.
%
% The example shown below makes use of 'accumulators', which are simply lists which
% are initially empty. Results are accumulated to them as we go along. In this case,
% we accumulate an odd number to the list Odds, and evens to the list Evens. Keep
% in mind that since we are adding elements from the head (which is the most
% efficient way of adding elements to a list), we need to reverse them at the end,
% to get an ordered output. Reversing the list at the end is computationally cheaper
% then meddling with the list in mid computation, as list values will have to be
% copied, making the operation inefficient.
%
% Also note that since we are using the 'accumulators' approach, we are only traversing
% the list once. If we were to use *list comprehensions* we would have to traverse the
% list two times, once for the odds, and once for the evens.
%
% Finally note that in order to 'beautify' the API, and not having to force the user
% to supply the extra [], [] accumulator parameters, we wrote the 'odds_and_evens_acc'
% function which takes only the list (i.e. L) parameter, and we supplied the extra
% stuff internally.
odds_and_evens_acc(L) -> odds_and_evens_acc(L, [], []).

odds_and_evens_acc([H | T], Odds, Evens) ->
	case (H rem 2) of
		1 -> odds_and_evens_acc(T, [H | Odds], Evens);
		0 -> odds_and_evens_acc(T, Odds, [H | Evens])
	end;
odds_and_evens_acc([], Odds, Evens) -> {reverse(Odds), reverse(Evens)}.
