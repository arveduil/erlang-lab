%%%-------------------------------------------------------------------
%%% @author Piotr Boszczyk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. kwi 2018 11:35
%%%-------------------------------------------------------------------
-module(pollution_server_sup).
-author("Piotr Boszczyk").

%% API
-export([]).


-export([start/0, init/0]).


%%start() ->spawn(fun supervisor/0).
%%
%%supervisor() -> pollution_server:start(),
%%                process_flag(trap_exit, true),
%%                receive
%%                  {'EXIT',_,_} -> io:format("restrting"),supervisor()
%%                end.


start() -> spawn(?MODULE, init, []).

init() ->
  process_flag(trap_exit, true),
  loop().

loop() ->
  pollution_server:start(),
  receive
    {'EXIT', _P, _R} -> loop();
    stop -> ok
  end.