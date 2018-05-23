%%%-------------------------------------------------------------------
%%% @author Piotr Boszczyk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. kwi 2018 18:55
%%%-------------------------------------------------------------------
-module(pollution).
-author("Piotr Boszczyk").
%% API
-export([createMonitor/0,addStation/3,addValue/5,compareMeasure/2,
  removeValue/4,getHeadFromSingleton/1 , getOneValue/4 ,getStation/2, avg/1, getStationMean/3, compareMeasureForStationAndType/3,checkStation/3
  ,compareMeasureForTypeAndDay/3,
  getDailyMean/3,
  checkDay/2,
  max/1,
  min/1,
  getMinMaxValue/4,
  max1/2,
  min1/2
]).

-record(coordination,{n,s}).
-record(station, {name, coordination}).
-record(time,{year, month, day, hours, minutes, seconds}).
-record(measure, {place,time, type, value}).
-record(monitor,{stations=[], measurements=[]}).

avg([]) -> undefined;
avg([H])-> H;
avg(List) -> lists:sum(List)/ length(List).

checkDay({{Y1,M1,D1},{_,_,_}}, {{Y2,M2,D2},{_,_,_}}) ->  (  (Y1 == Y2) andalso  M1 == M2 andalso D1 ==D2).

compareMeasureForStationAndType(Station,Type,M2) ->       ( (Type == M2#measure.type) and (Station#station.name== (M2#measure.place)#station.name ) ) .

compareMeasureForTypeAndDay(Type,Date,#measure{time=Time, type = Type1}) -> ((Type =:= Type1 andalso Type1 == Type) and (checkDay(Date, Time) == true)) .

compareMeasure(M1,M2) ->    ( (M1#measure.time == M2#measure.time) and
                             (M1#measure.type == M2#measure.type) and
                             (M1#measure.place == M2#measure.place)  ) .
getHeadFromSingleton([]) -> -1;
getHeadFromSingleton([H]) -> H.
compareStations(S1,S2) -> W= (S1 == S2),W.

getStation({N,S}, M) ->getHeadFromSingleton(
  lists:filter((fun (X) ->  (compareStations(#coordination{n=N,s=S},X#station.coordination)) end) , M#monitor.stations));
getStation(Name, M) ->getHeadFromSingleton(
  lists:filter((fun (X) ->  (compareStations(Name,X#station.name)) end) , M#monitor.stations)).

checkStation(Name,{N,S},M) ->  ( is_integer( getStation(Name,M)) and is_integer( getStation({N,S}, M)) ).

createMonitor() -> #monitor{stations = [],measurements = []}.
addStation(Name,{N,S},M)  -> case checkStation(Name,{N,S},M) of
                               true -> M#monitor{stations =[(#station{name=Name, coordination = #coordination{n=N,s=S}}) | M#monitor.stations]};
                               false -> {error, exists}
                             end .

addValue({N,S},Date,Type,Value,M) ->M#monitor{measurements =
[#measure{place = getStation({N,S},M) ,time = Date, type = Type, value = Value} | M#monitor.measurements]};
addValue(Name,Date,Type,Value,M) ->M#monitor{measurements =
[#measure{place = getStation(Name,M),time = Date, type = Type, value = Value} | M#monitor.measurements]}.

removeValue(Place, Date,Type,M) -> M#monitor{measurements = lists:filter((fun (X) -> not (compareMeasure(#measure{place= getStation(Place,M),time = Date, type = Type},X)) end) , M#monitor.measurements)} .

getOneValue(Station,Date,Type,M) ->(getHeadFromSingleton (lists:filter((fun (X) ->  (compareMeasure(#measure{place= getStation(Station,M) , time = Date, type = Type},X)) end) , M#monitor.measurements)))#measure.value .

getStationMean(Station,Type,M) -> avg(lists:map( fun (X) -> X#measure.value end, (lists:filter((fun (X) ->  (compareMeasureForStationAndType(Station,Type,X)) end) , M#monitor.measurements)))) .


getDailyMean(Day,Type,M) -> avg(lists:map( fun (X) -> X#measure.value end, (lists:filter((fun (X) ->  (compareMeasureForTypeAndDay(Type,Day,X)) end) , M#monitor.measurements)))) .

min([]) ->  {error, empty_list};
min([H|T]) ->  min1(H, T).

min1(M, [H|T]) when M < H ->  min1(M, T);
min1(M, [H|T]) when M >= H ->  min1(H, T);
min1(M, []) ->  M.

max([]) ->  {error, empty_list};
max([H|T]) ->  max1(H, T).

max1(M, [H|T]) when M >= H ->  max1(M, T);
max1(M, [H|T]) when M < H ->  max1(H, [H|T]);
max1(M, []) ->  M.

getMinMaxValue(Day,Type,{N,S},M)  ->      {min(lists:map( fun (X) -> X#measure.value end, (lists:filter((fun (X) ->  (compareMeasureForTypeAndDay(Type,Day,X)== true andalso getStation({N,S},M)== X#measure.place) end) , M#monitor.measurements))))
                                          ,max(lists:map( fun (X) -> X#measure.value end, (lists:filter((fun (X) ->  (compareMeasureForTypeAndDay(Type,Day,X)== true andalso getStation({N,S},M)== X#measure.place) end) , M#monitor.measurements))))}.

