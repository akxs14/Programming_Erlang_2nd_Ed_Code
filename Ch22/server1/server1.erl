-module(server1).
-export([start/2,rpc/2]).

%%%===============================================================
%%% A simple server parameterized with a callback module
%%%===============================================================
%%% The server doesn't have any predefined behaviour on its
%%% own besides starting and accepting a module that contains
%%% callbacks that define its behavior.
%%%===============================================================
%%% Exports
%%%===============================================================
%%% start(Name, Mod)
%%%   Starts the server and spawns a new process that calls
%%%   the module's init function and call the event handling
%%%   loop().
%%%===============================================================
%%% rpc(Name, Request)
%%%   Invokes a call to the given module and function with
%%%   a tuple containing the state.
%%%===============================================================

%%%===============================================================
%%% Server callbacks
%%%===============================================================
start(Name, Mod) ->
  register(Name, spawn(fun() -> loop(Name, Mod, Mod:init()) end)).

rpc(Name, Request) ->
  Name ! {self(), Request},
  receive
    {Name, Response} -> Response
  end.

%%%===============================================================
%%% Private / Internal functions
%%%===============================================================
loop(Name, Mod, State) ->
  receive
    {From, Request} ->
      {Response, State1} = Mod:handle(Request, State),
      From ! {Name, Response},
      loop(Name, Mod, State1)
  end.
