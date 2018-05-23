%%%-------------------------------------------------------------------
%%% @author Piotr Boszczyk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. kwi 2018 13:24
%%%-------------------------------------------------------------------
-module(pollution_tests).
-author("Piotr Boszczyk").

%% API
-include_lib("eunit/include/eunit.hrl").


-record(coordination,{n,s}).
-record(station, {name, coordination}).
-record(time,{year, month, day, hours, minutes, seconds}).
-record(measure, {place,time, type, value}).
-record(monitor,{stations=[], measurements=[]}).

create_monitor_test() ->
  ?assertEqual(#monitor{stations=[],measurements=[]}, pollution:createMonitor()).