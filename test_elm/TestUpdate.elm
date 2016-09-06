module TestUpdate exposing (testUpdate)

import Test exposing (Test,test,describe)
import Expect exposing (Expectation)

import Helpers.Stubs exposing (..)

import Dict exposing (Dict)

import Model exposing (..)
import Model.Page exposing (Page(..))
import Msg exposing (Msg(..))
import Update exposing (update,urlUpdate)


newGame =
  let
      (model,_) = urlUpdate Play initialModel
  in
      model


testUpdate : Test
testUpdate =
  describe "update"
    [ test "navigate to Play" <| \() ->
        let
            (model',_) = urlUpdate Play initialModel
        in
            model'.currentPage
            |> Expect.equal Play

    , describe "Game" describeGame
    ]


describeGame : List Test
describeGame =
  [ test "starts with 3 cards, none selected" <| \() ->
      let
          cards = newGame.cards
      in
          (Dict.size cards, Dict.values cards |> List.any .selected)
          |> Expect.equal (3,False)

  , test "select a card" <| \() ->
      let
          model =
            { newGame
            | cards = stubCards [ (0, "A", False), (1, "B", False) ]
            }
          (model',_) =
            model |> update (SelectCard 1)
      in
          model'.cards
          |> Expect.equal (stubCards [ (0, "A", False), (1, "B", True) ])

  , test "unselect a card" <| \() ->
      let
          model =
            { newGame
            | cards = stubCards [ (0, "A", True), (1, "B", True) ]
            }
          (model',_) =
            model |> update (UnselectCard 1)
      in
          model'.cards
          |> Expect.equal (stubCards [ (0, "A", True), (1, "B", False) ])
  ]
