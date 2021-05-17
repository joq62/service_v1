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
-record(state, {running,missing,obselete}).



%% --------------------------------------------------------------------
%% Definitions 
%% --------------------------------------------------------------------
-define(GitCatalogCmd,"git clone https://github.com/joq62/catalog.git").
-define(CatalogFile,"catalog/catalog.config").
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
	 load/1,
	 start/1,
	 stop/1,
	 unload/2,
	 running/0,
	 missing/0,
	 obsolite/0
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


load(ServiceId,Vsn)->
    gen_server:call(?MODULE, {load,ServiceId,Vsn},infinity).
unload(ServiceId,Slave)->
    gen_server:call(?MODULE, {load,ServiceId,Vsn},infinity).
start(DeploymentFileName)->
    gen_server:call(?MODULE, {start,DeploymentFileName},infinity).
stop(ServiceId,Slave)->
    gen_server:call(?MODULE, {stop,Deployment},infinity). 

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
    {ok, #state{running=[],missing=[],obselete=[]}}.
    
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

handle_call({start,DeploymentFileName},_From,State) ->
  %  Reply=rpc:call(node(),cluster_lib,start_slaves,[HostIds,?SlaveFile],2*5000),
    Reply=glurk,
    {reply, Reply, State};


handle_call({status_slaves},_From,State) ->
    Reply=rpc:call(node(),cluster_lib,status_slaves,[?SlaveFile],5*5000),
    io:format("Reply ~p~n",[{Reply,?MODULE,?LINE}]),
    NewState=case Reply of 
		 [{running,R},{missing,M}]->
		     State#state{running_slaves=R,missing_slaves=M};
		 _->
		     State
	     end,
    {reply, Reply, NewState};

handle_call({status_hosts},_From,State) ->
    Reply=rpc:call(node(),cluster_lib,status_hosts,[?HostFile],5*5000),
    io:format("Reply ~p~n",[{Reply,?MODULE,?LINE}]),
    NewState=case Reply of 
		 [{running,R},{missing,M}]->
		     State#state{running_hosts=R,missing_hosts=M};
		 _->
		     State
	     end,
    
    {reply, Reply, NewState};

handle_call({read_config},_From,State) ->
    Reply=rpc:call(node(),cluster_lib,read_config,[?HostFile],5000),
    {reply, Reply, State};

handle_call({load_config},_From,State) ->
    Reply=rpc:call(node(),cluster_lib,load_config,[?HostConfigDir,?HostFile,?GitHostConfigCmd],2*5000),
   
    {reply, Reply, State};


handle_call({install},_From,State) ->
    Reply=rpc:call(node(),cluster_lib,install,[],2*5000),
    {reply, Reply, State};


handle_call({start_app,ApplicationStr,Application,CloneCmd,Dir,Vm},_From,State) ->
    Reply=cluster_lib:start_app(ApplicationStr,Application,CloneCmd,Dir,Vm),
    {reply, Reply, State};
handle_call({stop_app,ApplicationStr,Application,Dir,Vm},_From,State) ->
    Reply=cluster_lib:stop_app(ApplicationStr,Application,Dir,Vm),
    {reply, Reply, State};
handle_call({app_status,Vm,Application},_From,State) ->
    Reply=cluster_lib:app_status(Vm,Application),
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
