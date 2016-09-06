module TestUpdate exposing (testUpdate)

import Test exposing (Test,test,describe)
import Expect exposing (Expectation)

import Helpers.Stubs exposing (..)

import Dict exposing (Dict)

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

  , describe "selecting a matching pair"
      (
      let
          card0 = Card "A" True (0,0)
          card1 = Card "B" False (0,0)
          card2 = Card "A" False (0,0)
          cards =
            Dict.empty
            |> Dict.insert 0 card0
            |> Dict.insert 1 card1
            |> Dict.insert 2 card2
          currentTime = 1000.0
          model = { newGame | cards = cards, currentTime = currentTime }
          action = SelectCard 2
          (model',_) = model |> update action
          expectedCards =
            Dict.empty
            |> Dict.insert 0 { card0 | position = (0.5,0.5) }
            |> Dict.insert 1 card1
            |> Dict.insert 2 { card2 | position = (0.5,0.5), selected = True }
      in
          [ test "moves the pair to the screen center" <| \() ->
              model'.cards
              |> Expect.equal expectedCards

          , test "schedules next round" <| \() ->
              model'.nextRoundDue
              |> Expect.equal (Just (currentTime + 2000))
          ]
      )

  , describe "new round"
      [ test "doesn't start unless scheduled" <| \() ->
          let
              model = { newGame | nextRoundDue = Nothing }
              action = Tick 5000
              (model',_) = model |> update action
          in
              model'.nextRoundDue
              |> Expect.equal model.nextRoundDue

      , test "doesn't start unless due" <| \() ->
          let
              model = { newGame | nextRoundDue = Just 5000 }
              action = Tick 4000
              (model',_) = model |> update action
          in
              model'.nextRoundDue
              |> Expect.equal model.nextRoundDue

      , describe "when due"
          (
            let
                model = { newGame | nextRoundDue = Just 5000 }
                action = Tick 5000
                (model',_) = model |> update action
            in
                [ test "clears the scheduling" <| \() ->
                    model'.nextRoundDue
                    |> Expect.equal Nothing

                , test "changes the cards" <| \() ->
                    model'.cards
                    |> Expect.notEqual model.cards

                , describe "new set of card"
                    [ test "contains at least one matching pair" <| \() ->
                        model'.cards
                        |> Dict.values
                        |> hasMatchingPair
                        |> Expect.true "Expected True"
                    ]
                ]
          )
      ]
  ]


-- Helpers


newGame =
  let
      (model,_) = urlUpdate Play initialModel
  in
      model


hasMatchingPair : List Card -> Bool
hasMatchingPair cards =
  case cards of
    hd::tl ->
      if List.any (\card -> card.content == hd.content) tl then
        True
      else
        hasMatchingPair tl

    _ ->
      False
