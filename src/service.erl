%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Manage Computers
%%% Install Cluster
%%% Install cluster
%%% Data-{HostId,Ip,SshPort,Uid,Pwd}
%%% available_hosts()-> [{HostId,Ip,SshPort,Uid,Pwd},..]
%%% install_leader_host({HostId,Ip,SshPort,Uid,Pwd})->ok|{error,Err}
%%% cluster_status()->[{running,WorkingNodes},{not_running,NotRunningNodes}]

%%% Created : 
%%% -------------------------------------------------------------------
-module(service).   
-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("timeout.hrl").
%-include("log.hrl").

%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------
-record(state, {running,missing,obsolete}).



%% --------------------------------------------------------------------
%% Definitions 
%% --------------------------------------------------------------------
-define(GitCatalogCmd,"git clone https://github.com/joq62/catalog.git").
-define(CatalogFile,"catalog/application.catalog").
-define(CatalogDir,"catalog").
-define(GitDeploymentCmd,"git clone https://github.com/joq62/deployment.git").
-define(DeploymentDir,"deployment").
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------





% OaM related
-export([
	 load_catalog/0,
	 read_catalog/0,
	 load_deployment/0,
	 read_deployment/1,
	 status/0,
	 load/3,
	 start_app/2,
	 start/1,
	 stop/2,
	 unload/2,
	 running/0,
	 missing/0,
	 obsolete/0
	]).


-export([start/0,
	 stop/0,
	 ping/0
	]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================

%% Gen server functions

start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).



running()->
       gen_server:call(?MODULE, {running},infinity).
missing()->
       gen_server:call(?MODULE, {missing},infinity).
obsolete()->
       gen_server:call(?MODULE, {obsolete},infinity).


load(ServiceId,Vsn,Node)->
    gen_server:call(?MODULE, {load,ServiceId,Vsn,Node},infinity).
unload(ServiceId,Node)->
    gen_server:call(?MODULE, {unload,ServiceId,Node},infinity).
start_app(ServiceId,Node)->
    gen_server:call(?MODULE, {start_app,ServiceId,Node},infinity).
start(DeploymentFileName)->
    gen_server:call(?MODULE, {start,DeploymentFileName},infinity).
stop(ServiceId,Node)->
    gen_server:call(?MODULE, {stop,ServiceId,Node},infinity). 

load_catalog()-> 
    gen_server:call(?MODULE, {load_catalog},infinity).
read_catalog()-> 
    gen_server:call(?MODULE, {read_catalog},infinity).
load_deployment()-> 
    gen_server:call(?MODULE, {load_deployment},infinity).
read_deployment(DeploymentFileName)-> 
    gen_server:call(?MODULE, {read_deployment,DeploymentFileName},infinity).
status()-> 
    gen_server:call(?MODULE, {status},infinity).


ping()-> 
    gen_server:call(?MODULE, {ping},infinity).

%%-----------------------------------------------------------------------

%%----------------------------------------------------------------------


%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: 
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------
init([]) ->

    {ok, #state{running=[],missing=[],obsolete=[]}}.
    
%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (aterminate/2 is called)
%% --------------------------------------------------------------------

handle_call({running},_From,State) ->
    Reply=State#state.running,
    {reply, Reply, State};
handle_call({missing},_From,State) ->
    Reply=State#state.missing,
    {reply, Reply, State};
handle_call({obsolete},_From,State) ->
    Reply=State#state.obsolete,
    {reply, Reply, State};

handle_call({load,ServiceId,Vsn,Node},_From,State) ->
    Reply=rpc:call(node(),service_lib,load,[ServiceId,Vsn,Node,?CatalogFile],2*5000),
    {reply, Reply, State};

handle_call({start_app,ServiceId,Node},_From,State) ->
    Reply=rpc:call(Node,application,start,[list_to_atom(ServiceId)],2*5000),
    {reply, Reply, State};

handle_call({start,DeploymentFileName},_From,State) ->
  %  Reply=rpc:call(node(),service_lib,start,[DeploymentFileName],2*5000),
    Reply={glurk,{start,DeploymentFileName},?FUNCTION_NAME},
    {reply, Reply, State};

handle_call({unload,ServiceId,Slave},_From,State) ->
    Reply=rpc:call(node(),service_lib,unload,[ServiceId,Slave],2*5000),
    {reply, Reply, State};

handle_call({stop,ServiceId,Slave},_From,State) ->
  %  Reply=rpc:call(node(),service_lib,start,[DeploymentFileName],2*5000),
    Reply={glurk,{stop,ServiceId,Slave},?FUNCTION_NAME},
    {reply, Reply, State};

handle_call({load_catalog},_From,State) ->
    Reply=rpc:call(node(),service_lib,load_catalog,
		   [?CatalogDir,?CatalogFile,?GitCatalogCmd],2*5000),
%    Reply={glurk,{load_catalog},?FUNCTION_NAME},
    {reply, Reply, State};

handle_call({read_catalog},_From,State)->
    Reply=rpc:call(node(),service_lib,read_catalog,
		   [?CatalogFile],5000),
  %  Reply={glurk,{read_catalog},?FUNCTION_NAME},
    {reply, Reply, State};

handle_call({load_deployment},_From,State) ->
  %  Reply=rpc:call(node(),service_lib,start,[DeploymentFileName],2*5000),
    Reply={glurk,{load_deployment},?FUNCTION_NAME},
    {reply, Reply, State};

handle_call({read_deployment,DeploymentFileName},_From,State) ->
    Reply=rpc:call(node(),service_lib,start,[DeploymentFileName],2*5000),
%    Reply={glurk,{read_deployment,DeploymentFileName},?FUNCTION_NAME},
    {reply, Reply, State};

handle_call({status},_From,State) ->
  %  Reply=rpc:call(node(),service_lib,start,[DeploymentFileName],2*5000),
    Reply={glurk,{status},?FUNCTION_NAME},
    {reply, Reply, State};


handle_call({ping},_From,State) ->
    Reply={pong,node(),?MODULE},
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% -------------------------------------------------------------------
    
handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
    {noreply, State}.


%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
