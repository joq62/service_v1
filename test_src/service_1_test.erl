%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(service_1_test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]). 


%% ====================================================================
%% External functions
%% ====================================================================
-define(Host,"c0").
-define(Ip,"192.168.0.200").
-define(SshPort,22).
-define(TimeOut,2*5000).
-define(Uid,"joq62").
-define(Pw,"festum01").

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    io:format("~p~n",[{"Start setup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=setup(),
    io:format("~p~n",[{"Stop setup",?MODULE,?FUNCTION_NAME,?LINE}]),

  %  io:format("~p~n",[{"Start pass_0()",?MODULE,?FUNCTION_NAME,?LINE}]),
  %  ok=pass_0(),
  %  io:format("~p~n",[{"Stop pass_0()",?MODULE,?FUNCTION_NAME,?LINE}]),

 %   io:format("~p~n",[{"Start pass_1()",?MODULE,?FUNCTION_NAME,?LINE}]),
 %   ok=pass_1(),
 %   io:format("~p~n",[{"Stop pass_1()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass_2(),
    io:format("~p~n",[{"Stop pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start pass_3()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass_3(),
    io:format("~p~n",[{"Stop pass_3()",?MODULE,?FUNCTION_NAME,?LINE}]),

  %  io:format("~p~n",[{"Start pass_4()",?MODULE,?FUNCTION_NAME,?LINE}]),
  %  ok=pass_4(),
  %  io:format("~p~n",[{"Stop pass_4()",?MODULE,?FUNCTION_NAME,?LINE}]),

  %  io:format("~p~n",[{"Start pass_5()",?MODULE,?FUNCTION_NAME,?LINE}]),
  %  ok=pass_5(),
  %  io:format("~p~n",[{"Stop pass_5()",?MODULE,?FUNCTION_NAME,?LINE}]),
 
    
   
      %% End application tests
    io:format("~p~n",[{"Start cleanup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=cleanup(),
    io:format("~p~n",[{"Stop cleaup",?MODULE,?FUNCTION_NAME,?LINE}]),
   
    io:format("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.





%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_0()->
    {glurk,{load_catalog},handle_call}=service:load_catalog(),
    {glurk,{read_catalog},handle_call}=service:read_catalog(),
    {glurk,{load_deployment},handle_call}=service:load_deployment(),
    {glurk,{read_deployment,dep},handle_call}=service:read_deployment(dep),
    {glurk,{status},handle_call}=service:status(),
    {glurk,{load,a,b},handle_call}=service:load(a,b),
    {glurk,{start,c},handle_call}=service:start(c),
    {glurk,{stop,d,e},handle_call}=service:stop(d,e),
    {glurk,{unload,f,g},handle_call}=service:unload(f,g),
    []=service:running(),
    []=service:missing(),
    []=service:obsolete(),
    
    ok.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_5()->
    {{running,Running},{missing,Missing}}=cluster:status_slaves(),
    10=lists:flatlength(Running),
    10=lists:flatlength(Missing),   
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
%% Load support on slave1@c0
pass_3()->
    Node='slave2@joq62-X550CA',
    ServiceId="support",
    Service=list_to_atom(ServiceId),
    Vsn="1.0.0",
    Path=filename:join(["slave2",ServiceId]),
    pong=net_adm:ping(Node),
    ok=service:unload(ServiceId,Node),
    ok=service:load(ServiceId,Vsn,Node),
    ok=service:start_app(ServiceId,Node),
    true=rpc:call(Node,filelib,is_dir,[Path],5000),
    {pong,Node,Service}=rpc:call(Node,Service,ping,[],5000),
    timer:sleep(2000),
    ok=service:unload(ServiceId,Node),
    false=rpc:call(Node,filelib,is_dir,[Path],5000),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_4()->
    WantedHostIds=["glurk","joq62-X550CA","c0"],   
%    SlaveNames=["slave0","slave1","slave2","slave3","slave4"],
 %   ErlCmd="-setcookie abc",
    L=cluster:start_slaves(WantedHostIds),
    R=[{ok,Slave}||{ok,Slave}<-L],
    10=lists:flatlength(R),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_2()->
    ok=service:load_catalog(),
    {ok,
     [{"support",
       "git clone https://github.com/joq62/support.git"},
      {"master",
       "git clone https://github.com/joq62/master.git"}]}=service:read_catalog(),
    

    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_1()->
    [{running,Running},{missing,Missing}]=cluster:status_slaves(),
    10=lists:flatlength(Running),
    10=lists:flatlength(Missing),   
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_11()->
    [{ok,[[{host_id,"c0"},
	  {ip,"192.168.0.200"},
	  {ssh_port,22},
	  {uid,"joq62"},
	  {pwd,"festum01"}],
	 [{host_id,"joq62-X550CA"},
	  {ip,"192.168.0.100"},
	  {ssh_port,22},
	  {uid,"joq62"},
	  {pwd,"festum01"}]]},
    {error,[[{host_id,"c1"},
	     {ip,"192.168.0.201"},
	     {ssh_port,22},
	     {uid,"joq62"},
	     {pwd,"festum01"}],
	    [{host_id,"c2"},
	     {ip,"192.168.0.202"},
	     {ssh_port,22},
	     {uid,"joq62"},
	     {pwd,"festum01"}]]}]=cluster:install(),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
   ToKill=[	    
	    'master@joq62-X550CA',
	    'master@c2',
	    'master@c1',
	    'master@c0',
	    'slave0@joq62-X550CA',
	    'slave1@joq62-X550CA',
	    'slave2@joq62-X550CA',
	    'slave3@joq62-X550CA',
	    slave1@c0,
	    slave3@c0,
	    slave2@c0,
	    slave4@c0,
	    slave0@c0,
	    slave1@c2,
	    slave3@c2,
	    slave2@c2,
	    slave4@c2,
	    slave0@c2,
	    'slave4@joq62-X550CA'],
    [{rpc:call(Node,init,stop,[]),Node}||Node<-ToKill],

    HostIds=["joq62-X550CA","c0","c2"], 
    [{ok,_},{ok,_}]=cluster:start_masters(HostIds),
    WantedHostIds=["joq62-X550CA","c0","c2"],   
    L=cluster:start_slaves(WantedHostIds),
    R=[{ok,Slave}||{ok,Slave}<-L],
    10=lists:flatlength(R),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
