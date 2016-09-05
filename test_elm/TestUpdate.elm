module TestUpdate exposing (testUpdate)

import Test exposing (Test,test,describe)
import Expect exposing (Expectation)

import Helpers.Stubs exposing (..)

import Model exposing (..)
import Model.Page exposing (Page(..))
import Msg exposing (Msg(..))
import Update exposing (update,urlUpdate)


testUpdate : Test
testUpdate =
  describe "update"
    [ test "navigate to Play" <| \() ->
        let
            (model',_) = urlUpdate Play initialModel
        in
            model'.currentPage
            |> Expect.equal Play
    , describe "new game" describeNewGame
    ]


describeNewGame : List Test
describeNewGame =
  let
      newGame = urlUpdate Play initialModel
  in
      [ test "starts with three cards" <| \() ->
          let
              (model',_) = newGame
          in
              model'.cards
              |> List.length
              |> Expect.equal 3
      ]
