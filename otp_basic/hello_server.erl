-module(hello_server).
-compile(export_all).

-behaviour(gen_server).

-define(SERVER, ?MODULE).

-record(state,{count}).

%API function definitions
%---------------------------

start_link() ->
    gen_server:start_link(
		{local, ?SERVER},
		?MODULE,
		[],
		[]).

stop() ->
    gen_server:cast(?SERVER, stop).

say_hello() ->
    gen_server:cast(?SERVER, say_hello).

get_count()  ->
    gen_server:call(?SERVER,get_count).


%gen_server function definitions
%---------------------------------

init([]) ->
    {ok, #state{count = 0}}.

handle_call(get_count, _From, #state{count = Count}) ->
    {reply,
	Count,
	#state{count = Count + 1}}.

handle_cast(stop, State) ->
	{stop,normal,State};

handle_cast(say_hello, State) ->
        io:format("Hello ~n"),
        {noreply,
	    #state{count = State#state.count+1}}.

terminate(_Reason, _State) ->
    error_logger:info_msg("terminating ~n"),
    ok.

