-module(calendar_server).
%-compile(export_all).
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2,
        handle_info/2, terminate/2, code_change/3]).

-export([insert/4, retrieve_all/0, retrieve_per_date/1, 
	todays_events/0, bdays/1, edit/4, delete/1]).


-record(state, {}).


% CLIENT CALLS
%-------------------------------
start_link() ->
    gen_server:start_link(
		{global, ?MODULE},
		?MODULE, [], []).

insert(Event,Date,Loc,Desc) ->
	gen_server:call({global, ?MODULE}, {insert,Event,Date,Loc,Desc}).

retrieve_all() ->
        gen_server:call({global, ?MODULE}, {retrieve_all}).

retrieve_per_date(Date) ->
	gen_server:call({global, ?MODULE}, {retrieve_per_date, Date}).

todays_events() ->
        gen_server:call({global, ?MODULE}, {todays_events}).

bdays(Event) ->
	gen_server:call({global, ?MODULE}, {bdays, Event}).

edit(Date, Event, Desc, Loc) ->
        gen_server:call({global, ?MODULE}, {edit,Date,Event,Desc,Loc}).

delete(Date) ->
	gen_server:call({global, ?MODULE}, {delete, Date}).


%% CALL BACK FUNCTIONS
%%--------------------------------------------
init(_Args) ->
    process_flag(trap_exit, true),
    io:format("~p (~p) starting ......~n", [{global, ?MODULE}, self()]),
    cal2:init(),
    {ok, #state{}}.

  
handle_call({insert, Event,Date,Loc,Desc}, _From, State) ->
        cal2:insert_event(Event, Date, Loc, Desc),
        io:format("New Event is added on"),
        {reply,ok, State};

handle_call({retrieve_all}, _From, State) ->
        All_data = cal2:retrieve_all(),
%        lists:foreach((fun({X,Y,Z,A,B}) ->
%             io:format("Receivea....~p ~p ~p ~p ~p~n", [X,Y,Z,A,B])
%	    end, All_data),
%        io:format("Select all the eventres from the table"),
        {reply,All_data, State};

handle_call({retrieve_per_date, Date}, _From, State) ->
        All_data = cal2:retrieve_per_date(Date),
   %     lists:foreach((fun({X,Y}) ->
%             io:format("Receivea....~p on ~p~n", [X,Y])
%            end, All_data),
        {reply,All_data, State};
handle_call({todays_events}, _From, State) ->
        All_data = cal2:todays_events(),
%        lists:foreach((fun({X,Y,Z,A,B}) ->
%             io:format("Receivea....~p~p~p~p~p~n", [X,Y,Z,A,B]}
%            end, All_data),
        {reply,All_data, State};
handle_call({bdays, Event}, _From, State) ->
        All_data = cal2:bdays_only(Event),
%        lists:foreach((fun({X,Y,Z}) ->
%             io:format("Receivea....~p~p~p~n", [X,Y,Z])
%            end, All_data),
        {reply,All_data, State};

handle_call({edit,Date, Event, Desc, Loc}, _From, State) ->
        cal2:edit(Date,Event,Desc,Loc),
        io:format("Table updated on date ~p~n ......", [Date]),
        {reply,ok, State};

handle_call({delete,Date}, _From, State) ->
        cal2:delete(Date),
        io:format("Table deleted on date ~p~n....",[Date]),
        {reply,ok, State};


handle_call(_Request, _From, State) ->

{noreply, State}.

handle_cast(_Request, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

