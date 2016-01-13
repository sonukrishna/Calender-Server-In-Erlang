# Calender-Server-In-Erlang
Here i created a server(gen_server) using Erlnag OTP framework, And access the datas from the mnesia database on client side 

##OTP framework - gen_server behaviour
----------------------------------------------
OTP (standing for Open Telecom Platform) is a framework written for erlang.
I go through the OTP behaviours(gen_server), to get some ideas for my calendar_server. Basically there are two modules, the behaviour itself with all the common functions, and the callback module, including the specific functionality that process provides by implementing the behaviour callbacks.
The gen_server behaviour is a very simple server. Clients will ask it to process requests and it will provide the service to these clients.

##CALENDAR SERVER
==============================


This time I change my mnesia database(cal2) to a database server. For that i learned some basics of OTP framework(gen_server behaviours).

In these programs, I did the first one(hello_server.erl) to understand some basics of gen_server.

###otp_basic
-------------------------
#####hello_sever.erl

I started with OTP gen_server. The gen_server behaviour helps to write generic servers.
Assigned a behaviour(gen_server) module which implements the gen_server behaviours and
the compiler will warn as if we do not provide all callback functions the behaviour announces.

I define some api functions(start_link, stop etc.) or the client part. The 'start_link/0'  function spawns and
link to a new process. The parameters we provide are
                1) name to register the process (globaly/ localy).
                2) The module where we find the init/1.
                3) The parameter which pass to init and
                4) the additional options

In the 'stop /0'function, Use a 'cast' to send an asynchronous(we do not expect any reply) message to the registered name.
Then 'say_hello/0'  function also did the same thing, but in 'get_count/0' we expect a response back and so we use a 'call' to
synchronously invoke the server. It blocks untill we get a response.

Then i define the gen_server functions......

        1) init/1 -- is the initialize state and it called in response to the start_link function(gen_server:start_link/4).
        2) handle_call/3 -- Here I synchronously respond with the Count and update the state, which return in the get_count() function in client part
        3) handle_cast/2  --  Here by passing the atom stop, instructs the general server to stop normally and return current state.
                                And  handle say_hello atom by printing "Hello".
        4) handle_info/2  -- It deals with the messages that weren't send via cast or call.
        5) terminate/2  -- invoked by the gen_server container on shutdown
        6) code_change/2 -- to update the internal states
These are the gen_server functions,Both the other two programs also worked like this.

###db_server

#####db_server.erl


Here i expand my first database in mnesia(db.erl) to a database server using OTP  gen_server behaviour.

The database is very simple and only capable of adding events, read  and delete these.So i define gen_server behaviour.
Starts with callback functions(gen_server functions), define a OTP gen_server syntax model and expand it. Mainly the
handle_call to synchronous message passing. The first step it to initialize the db(my first database),so in init/1 function i called 'db:init/1' to initialize.
Next step is a way to start a message, so i call the handle_call function and pass our function name and attributes as tuple, shown below

            >>>>>           handle_call({insert, Name, Desc, Date}, _From, State) ->
            >>>>>            db:insert(Name, Desc, Date),

            >>>>>            {reply,ok, State} 
       When the request is received,  the gen_server  calls handle_call(Request, From, State) , which
is expected to return a tuple {reply,Reply,State} . Reply  is the reply that is to be sent back to the client, 
and State  is a new value for the state of the gen_server. Here ok is the reply and State is new state. Do 
After writing the callback function next step is to writing the client call function. The first function defined here is insert/3 and which call the
'gen_server:call' function, shown below. Do the same thing for the other functions(read, delete etc).

After writing the callback function's next step is to writing the client call function. The first function defined here is insert/3 and which call the
'gen_server:call' function, shown below

            >>>>>           insert(Name, Desc, Date) ->
            >>>>>               gen_server:call({global, ?MODULE}, {insert,Name,Desc,Date}).

Did the exact things for the other functions, compiled and run the program.

### calendr_server
----------------------------

#####calendar_server.erl

It exactly the same, but adding more functions(todays_events, bdays,edit etc..), and it simply an expansion of the above program.

---->I only tried the gen_server behaviour, and trying to make it as a good app.

