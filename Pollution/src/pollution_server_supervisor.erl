%%%-------------------------------------------------------------------
%%% @author Piotr Boszczyk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. maj 2018 11:59
%%%-------------------------------------------------------------------
-module(pollution_server_supervisor).
-author("Piotr Boszczyk").



-export([start_link/1, init/1, start/0]).
%%%-------------------------------------------------------------------

start() -> start_link(empty).

start_link(_) ->
  supervisor:start_link(
    {local, server_supervisor},
    ?MODULE, []
  ).

init(_) ->
  {ok, {
    {one_for_all, 2, 3},
    [ {pgs, {pollution_gen_server, start, []},
      permanent, brutal_kill, worker,
      [pollution_gen_server]}
    ] }
  }.