%%my first erlang db using mnesia
%it simply add an event name and retrieve it.

-module(db).
-compile(export_all).
-include_lib("stdlib/include/qlc.hrl").
-record(events, {event_name, description, date}).

%% initialising the database

init() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
    mnesia:create_table(events,
                        [{disc_copies, [node()]},
                                {type, bag},
                                {attributes, record_info(fields, events)}]).


%inserting to the database 
insert(Name, Desc, Date) ->
    Fun = fun() ->
	mnesia:write(#events{
			event_name = Name,
			description = Desc,
			date = Date})
	end,
    mnesia:transaction(Fun).

%%reading the events descriptions
read_desc(Name) ->
    Fun = fun() ->
	Result = qlc:e(qlc:q([X || X <- mnesia:table(events),
		X#events.event_name =:= Name])),
        lists:map(fun(Item) -> Item#events.description end, Result)
 	end,
    {atomic, Details} = mnesia:transaction(Fun),
    Details.

read_all(Date) ->
    Fun = fun() ->
        Result = qlc:e(qlc:q([X || X <- mnesia:table(events),
                X#events.date =:= Date])),
        lists:map(fun(Item) -> {Item#events.event_name, 
		Item#events.description} end, Result)
        end,
    {atomic, Details} = mnesia:transaction(Fun),
    Details.

delete(Date) ->
     Fun = fun() ->
        Result = qlc:eval(qlc:q([X || X <- mnesia:table(events),
                        X#events.date =:= Date])),
          Fun1 = fun() ->
               lists:foreach(fun(Item) -> 
                   mnesia:delete_object(Item) 
                       end, Result)       
        end,
       mnesia:transaction(Fun1)
    end,
  mnesia:transaction(Fun).


