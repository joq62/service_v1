%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(service_lib).  
    
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------


%% External exports
-export([
	 load_catalog/3,
	 read_catalog/1,
	 load/4,
	 unload/2

	]).

%% ====================================================================
%% External functions
%% ====================================================================
%load(ServiceId,_Vsn,Node,CatalogFile)->
%    Result=case read_catalog(CatalogFile) of
%	       {error,Reason}->
%		   {error,Reason};
%	       {ok,Info} ->
%		   case lists:keyfind(ServiceId,1,Info) of
%		       false->
%			   {error,[eexists,ServiceId]};  
%		       {ServiceId,GitCmd}->
%			   case rpc:call(Node,filelib,is_dir,[ServiceId]) of
%			       true->
%				  {error,[already_exists,ServiceId]}; 
%			       false->
%				   case rpc:call(Node,os,cmd,[GitCmd],7000) of
%				       b

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
load(ServiceId,_Vsn,Node,CatalogFile)->
    NodeStr=atom_to_list(Node),
    [NodeId,_HostId]=string:lexemes(NodeStr,"@"),
    {ok,Info}=read_catalog(CatalogFile),
    {ServiceId,GitCmd}=lists:keyfind(ServiceId,1,Info),
    false=rpc:call(Node,filelib,is_dir,[filename:join([NodeId,ServiceId])]),
    rpc:call(Node,os,cmd,[GitCmd++" "++NodeId++"/"++ServiceId],7000),
    Path=filename:join([NodeId,ServiceId,"ebin"]),
    true=rpc:call(Node,code,add_patha,[Path]),
    ok.

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
unload(ServiceId,Node)->
    NodeStr=atom_to_list(Node),
    [NodeId,_HostId]=string:lexemes(NodeStr,"@"),
    Path=filename:join([NodeId,ServiceId]),
    rpc:call(Node,os,cmd,["rm -rf "++Path],7000),
    false=rpc:call(Node,filelib,is_dir,[Path]),
    ok.
    
   
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
load_deployment(Dir,File,GitCmd)->
    os:cmd("rm -rf "++Dir),
    os:cmd(GitCmd),
    Reply=case filelib:is_file(File) of
	      true->
		  ok;
	      false->
		  {error,[noexist,File]}
	  end,
    Reply.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
read_deployment(File)->
    Reply=case filelib:is_file(File) of
	      true->
		  file:consult(File);
	      false->
		  {error,[noexist,File]}
	  end,
    Reply.


%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
load_catalog(Dir,File,GitCmd)->
    os:cmd("rm -rf "++Dir),
    os:cmd(GitCmd),
    Reply=case filelib:is_file(File) of
	      true->
		  ok;
	      false->
		  {error,[noexist,File]}
	  end,
    Reply.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
read_catalog(File)->
    Reply=case filelib:is_file(File) of
	      true->
		  file:consult(File);
	      false->
		  {error,[noexist,File]}
	  end,
    Reply.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

node_started(HostId,NodeName)->
    Vm=list_to_atom(NodeName++"@"++HostId),
    check_started(50,Vm,10,false).
    
check_started(_N,_Vm,_SleepTime,true)->
    true;
check_started(0,_Vm,_SleepTime,Result)->
    Result;
check_started(N,Vm,SleepTime,_Result)->
    io:format("N,Vm ~p~n",[{N,Vm,SleepTime,?MODULE,?LINE}]),
    NewResult=case net_adm:ping(Vm) of
		  pong->
		     true;
		  _Err->
		      timer:sleep(SleepTime),
		      false
	      end,
    check_started(N-1,Vm,SleepTime,NewResult).

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
stop_vm(HostId,VmId)->
    Vm=list_to_atom(VmId++"@"++HostId),
    stop_vm(Vm).

stop_vm(Vm)->
    rpc:cast(Vm,init,stop,[]),
    vm_stopped(Vm).

vm_stopped(Vm)->
    check_stopped(50,Vm,100,false).
    
check_stopped(_N,_Vm,_SleepTime,true)->
    ok;
check_stopped(0,_Vm,_SleepTime,Result)->
    Result;
check_stopped(N,Vm,SleepTime,_Result)->
    NewResult=case net_adm:ping(Vm) of
		  pang->
		     true;
		  _Err->
		      timer:sleep(SleepTime),
		      false
	      end,
    check_stopped(N-1,Vm,SleepTime,NewResult).

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
stop_app(ApplicationStr,Application,Dir,Vm)->
    rpc:call(Vm,os,cmd,["rm -rf "++Dir++"/"++ApplicationStr]),
    rpc:call(Vm,application,stop,[Application]),
    rpc:call(Vm,application,unload,[Application]).
    

start_app(ApplicationStr,Application,CloneCmd,Dir,Vm)->
    rpc:call(Vm,os,cmd,[CloneCmd++" "++Dir++"/"++ApplicationStr]),
    true=rpc:call(Vm,code,add_patha,[Dir++"/"++ApplicationStr++"/ebin"]),
    ok=rpc:call(Vm,application,start,[Application]),
    app_status(Vm,Application).

app_status(Vm,Application)->
    Status = case rpc:call(Vm,Application,ping,[]) of   
		 {pong,_,Application}->
		     running;
		 Err ->
		     {error,[Err]}
	     end,
    Status.

%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
