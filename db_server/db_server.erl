%% try to create my first db server,
% I study basic of OTP framework
% tries to implement a db_server as gen_server behaviour


-module(db_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2,
        handle_info/2, terminate/2, code_change/3]).

-export([insert/3, read_desc/1, read_all/1, delete/1]).
%-export([stop/0]).
-behaviour(gen_server).

-record(state, {}).

%% Client functions
%-------------------------

start_link() ->
    gen_server:start_link({global, ?MODULE},
		?MODULE, [], []).

insert(Name, Desc, Date) ->
    gen_server:call({global, ?MODULE}, {insert,Name,Desc,Date}).

read_desc(Name) ->
    gen_server:call({global, ?MODULE}, {read_desc, Name}).

read_all(Date) ->
    gen_server:call({global, ?MODULE}, {read_all, Date}).

delete(Date) ->
    gen_server:call({global, ?MODULE}, {delete, Date}).

%stop() ->
%    gen_server:cast({global, ?MODULE}, {stop}).

%% Callback functions
%-------------------------

init(_Args) ->
    process_flag(trap_exit, true),
    io:format("~p (~p) starting........~n" ,[{global, ?MODULE}, self()]),
    db:init(),
    {ok, #state{}}.

handle_call({insert, Name, Desc, Date}, _From, State) ->
    db:insert(Name, Desc, Date),
    io:format("Desc has been saved for ~p", [Name]),
    {reply,ok, State};

handle_call({read_desc, Name}, _From, State) ->
     X = db:read_desc(Name),
    % lists:foreach(fun(D) ->
    %    io:format("Read description ~p~n", [D]),
   % end, All),
    io:format("Read description for the name ~n"),
    {reply,X, State};

handle_call({read_all, Date}, _From, State) ->
     X = db:read_desc(Date),
%    lists:foreach(fun({N,D}) ->
%        io:format("Read description ~p for event ~p~n", [N,D]),
%    end, Desc),
    io:format("Read names and description ~n"),
    {reply, X , State};

handle_call({delete, Date}, _From, State) ->
    db:delete(Date),
    io:format("Db is deleted on ~p", [Date]),
    {reply,ok, State};

%handle_cast({stop}, State) ->
%    {stop, normal, State};



handle_call(_Request, _From, State) ->
    {nonreply, State}.

handle_cast(_Request, State) ->
    {nonreply, State}.

handle_info(_Info, State) ->
    {nonreply, State}.

terminate(_Reason, _State) ->
    ok.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
