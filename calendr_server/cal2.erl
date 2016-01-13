-module(cal2).
-compile(export_all).
-include_lib("stdlib/include/qlc.hrl").
-record(events, {name_of_event, wHen, wHere, wHat}).

init() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
    mnesia:create_table(events,
			[{disc_copies, [node()]},
				{type, bag},
				{attributes, record_info(fields, events)}]).

%inserting the birthdays, meetings, appoinments etc
% Date = {year,month,day}
%-----------------------------------------------
insert_event(Event, Date , Loc, Desc) ->
    Fun = fun() ->
	mnesia:write(#events{
			name_of_event = Event,
			wHen = Date,
			wHere = Loc,
			wHat = Desc})
	end,
    mnesia:transaction(Fun).

% retrieve all the events as a list
%-----------------------------------------
retrieve_all() ->
    Fun = fun() ->
	qlc:eval(qlc:q([X || X <- mnesia:table(events)]))
	end,
    {atomic, Details} = mnesia:transaction(Fun),
    Details.

%retrieve events as per a given date
%----------------------------------------
retrieve_per_date(Date) ->
    Fun = fun() ->
	Result = qlc:eval(qlc:q([X || X <- mnesia:table(events),
			X#events.wHen =:= Date])),
        lists:map(fun(Item) -> {Item#events.wHere, Item#events.wHat} end, Result)
	end,
    {atomic, Details} = mnesia:transaction(Fun),
    Details.

%lists all the events in the current date
%---------------------------------------------
todays_events() ->
    Fun = fun() ->
	qlc:eval(qlc:q([X || X <- mnesia:table(events),
		X#events.wHen =:= erlang:date()]))
	end,
    {atomic, Details} = mnesia:transaction(Fun),
    Details.


% retrieve the bday location, date and details.......
%-----------------------------------------------
bdays_only(Event) ->
    Fun = fun() ->
        Result = qlc:eval(qlc:q([X || X <- mnesia:table(events),
                        X#events.name_of_event =:= Event])),
        lists:map(fun(Item) -> {Item#events.wHat, Item#events.wHere, Item#events.wHen} end, Result)
        end,
    {atomic, Details} = mnesia:transaction(Fun),
    Details.

%add_update(Date) ->
 %   F = fun() ->
%        %% ----first i find the number of car X available in the shop
%        [Rec] = mnesia:wread({events, Date}),
%        When = Rec#events.wHen,
%        Leftcars = Rec#events{wHen = When},
%        %% ---now we update the database
%        mnesia:write(Leftcars)
%    end,
%    mnesia:transaction(F).

%% edit our database 
%--------------------------
edit(Date,Event,Desc,Loc) ->
%    Event = #events.name_of_event,
%    Desc = #events.wHat
%    Loc = #events.wHere,
    Fun = fun() ->
	Result = qlc:eval(qlc:q([X || X <- mnesia:table(events),
                        X#events.wHen =:= Date])),
		delete_fun(Result),
		update_table(Result, Event, Desc, Loc, Date)
        end,
  mnesia:transaction(Fun).

update_table([E|Tail], Event, Desc, Loc, Date) ->
    New = E#events{name_of_event = Event, wHat = Desc, wHere = Loc, wHen = Date},
    mnesia:write(New),
    update_table(Tail, Event, Desc, Loc, Date);
update_table([],_,_,_,_) ->  [].

%% delete dat from our table
%------------------------------------
delete(Date) -> 
     Fun = fun() ->
        Result = qlc:eval(qlc:q([X || X <- mnesia:table(events),
                        X#events.wHen =:= Date])),
		delete_fun(Result)
%        Fun1 = fun() ->
%		lists:foreach(fun(Item) -> 
%		    mnesia:delete_object(Item) 
%			end, Result)       
%        end,
%	mnesia:transaction(Fun1)
    end,
  mnesia:transaction(Fun).

delete_fun(Result) ->
    Fun1 = fun() ->
                lists:foreach(fun(Item) ->
                    mnesia:delete_object(Item)
                        end, Result)
        end,
    mnesia:transaction(Fun1).

%% events for a set of days
%---------------------------------
events_for_set_of_days(Year, Month, Day1, DayN) ->
    Year = 2016,
    Fun = fun() ->
	case DayN >= 31 of
	    true ->
		no_such_day;
	    false ->
		Days = lists:seq(Day1, DayN),
		fun_date(Days, Month, Year)
	    end
	end,
    mnesia:transaction(Fun).


%% events for a set of days
%-------------------------------
fun_date([Day|Tail], Month, Year) ->
    Nw_date = {Year, Month, Day},
    nw_fun(Nw_date),
    fun_date(Tail, Month, Year);
%     qlc:eval(qlc:q([X || X <- mnesia:table(events),
%                        X#events.wHen =:= Nw_date])),
%     fun_date(Tail, Month, Year);
fun_date([],_,_) -> 0.

nw_fun(Nw_date)->
     Fun = fun()->
     Result = qlc:eval(qlc:q([X || X <- mnesia:table(events),
                        X#events.wHen =:= Nw_date])),
        lists:map(fun(Item) -> {Item#events.wHere, Item#events.wHat} end, Result)
     end,
    mnesia:transaction(Fun).
