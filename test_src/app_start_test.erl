%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(app_start_test).    
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------
-define(APP,service).
%% External exports
-export([start/0]).



%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    ?debugMsg("Start setup"),
    ?assertEqual(ok,setup()),
    ?debugMsg("stop setup"),

 %   ?debugMsg("Start testXXX"),
 %   ?assertEqual(ok,single_node()),
 %   ?debugMsg("stop single_node"),
    
      %% End application tests
    ?debugMsg("Start cleanup"),
    ?assertEqual(ok,cleanup()),
    ?debugMsg("Stop cleanup"),

    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->

    %% Test env vars 
   
%    io:format("Line = ~p~n",[{?MODULE,?LINE}]),
    
    rpc:call(node(),application,stop,[support],2*5000),
    timer:sleep(500),
    ok=rpc:call(node(),application,start,[support],10*5000),
    ?assertMatch({pong,_,support},
		 rpc:call(node(),support,ping,[],1*5000)),	

    rpc:call(node(),application,stop,[cluster],10*5000),
    timer:sleep(500),
    ok=rpc:call(node(),application,start,[cluster],10*5000),
    ?assertMatch({pong,_,cluster},
		 rpc:call(node(),cluster,ping,[],1*5000)),	
    % Start a Service application 
      
    rpc:call(node(),application,stop,[?APP],10*5000),
    timer:sleep(500),
    ok=rpc:call(node(),application,start,[?APP],10*5000),
    ?assertMatch({pong,_,?APP},
		 rpc:call(node(),?APP,ping,[],1*5000)),		 

    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
  
  %  init:stop(),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
