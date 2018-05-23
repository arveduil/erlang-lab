%%%-------------------------------------------------------------------
%%% @author Piotr Boszczyk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. kwi 2018 14:39
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("Piotr Boszczyk").

%% API
-export([start/0,stop/0,init/0]).
-export([addStation/2,addValue/4,removeValue/3,getOneValue/3,getStationMean/2,getDailyMean/2,getMinMaxValue/3, crashed/0]).

start() -> register(server, spawn_link(fun() -> init() end)).

stop() -> server ! stop.

init() ->
  loop(pollution:createMonitor()).

loop(M) ->
  receive
    {request, Pid, addStation, {Name, {N,S}}} ->
      P = pollution:addStation(Name,{N,S},M),
      case P of
        {error, exists} -> Pid ! {reply, exists}, loop(M);
        _ -> Pid ! {reply, ok}, loop(P)
      end;
    {request, Pid, addValue, {Station, Date, Type, Value}} ->
      P = pollution:addValue(Station,Date,Type,Value,M),
       Pid ! {reply, ok}, loop(P);
    {request, Pid, removeValue, {Place, Datetime, Type}} ->
      P = pollution:removeValue(Place, Datetime,Type,M),
       Pid ! {reply, ok}, loop(P);
    {request, Pid, getOneValue, {Station, Datetime, Type}} ->
      P = pollution:getOneValue(Station,Datetime,Type,M),
      Pid ! {reply, P}, loop(M);
    {request, Pid, getStationMean, {Station, Type}} ->
      P = pollution:getStationMean(Station,Type,M),
      Pid ! {reply, P}, loop(M);
    {request, Pid, getDailyMean, {Day, Type}} ->
      P = pollution:getDailyMean(Day,Type,M),
      Pid ! {reply, P}, loop(M);
    {request, Pid, crashed, {}} ->
      Pid ! {reply, error},
      P = 1/0 ;
    {request, Pid, getMinMaxValue, {Day, Type,{N,S}}} ->
      P = pollution:getMinMaxValue(Day,Type,{N,S},M),
      Pid ! {reply, P}, loop(M)
  end.



call(Message, Parameters) ->
  server ! {request, self(), Message, Parameters},
  receive
    {reply, Reply} -> Reply
  end.
addStation(Name, Coords) -> call(addStation,{Name, Coords}).
addValue(Station, Datetime,Type,Value) -> call(addValue, {Station, Datetime, Type, Value}).
removeValue(Station, Datetime, Type) -> call(removeValue, {Station, Datetime, Type}).
getOneValue(Station, Datetime, Type) -> call(getOneValue, {Station, Datetime, Type}).
getStationMean(Station, Type) -> call(getStationMean, {Station, Type}).
getDailyMean(Datetime, Type) -> call(getDailyMean, {Datetime, Type}).
getMinMaxValue(Day,Type,{N,S}) -> call(getMinMaxValue, {Day, Type,{N,S}}).
crashed() -> call(crashed,{}).