module TestModel exposing (testModel)

import Test exposing (Test,test,describe)
import Expect

import Dict exposing (Dict)

import Helpers.Factories exposing (..)

import Model exposing (..)
import Model.Screen exposing (Screen(..))



testModel : Test
testModel =
  describe "Model"
    [ describe "initialModel"
        [ test "starts on welcome screen" <| \() ->
            initialModel.currentScreen |> Expect.equal Welcome

        , test "starts with 4 cards" <| \() ->
            initialModel.cards
            |> Dict.size
            |> Expect.equal 4
        ]

    , describe "isMatchingPair"
        [ test "empty Dict" <| \() ->
            Dict.empty
            |> isMatchingPair
            |> Expect.false "Two cards expected"
        , test "one Card" <| \() ->
            Dict.empty
            |> Dict.insert 0 (Card "A" False (0,0) False)
            |> isMatchingPair
            |> Expect.false "Expected False"
        , test "two Cards with identical content" <| \() ->
            Dict.empty
            |> Dict.insert 0 (Card "A" False (0,0) False)
            |> Dict.insert 1 (Card "A" True (1,1) False)
            |> isMatchingPair
            |> Expect.true "Expected True"
        , test "two Cards with different content" <| \() ->
            Dict.empty
            |> Dict.insert 0 (Card "A" False (0,0) False)
            |> Dict.insert 1 (Card "B" False (0,0) False)
            |> isMatchingPair
            |> Expect.false "Expected False"
        , test "three Cards" <| \() ->
            Dict.empty
            |> Dict.insert 0 (Card "A" False (0,0) False)
            |> Dict.insert 1 (Card "A" False (0,0) False)
            |> Dict.insert 2 (Card "A" False (0,0) False)
            |> isMatchingPair
            |> Expect.false "Expected False"
        ]

    , describe "newCards"
        [ test "round 0 has 4 cards" <| \() ->
            newCards 0 0
            |> Dict.size
            |> Expect.equal 4

        , test "round 0 has matching pair" <| \() ->
            newCards 0 0
            |> Dict.values
            |> includesMatchingPair
            |> Expect.true "should be True"
        ]

    , describe "helper function includesMatchingPair"
        [ test "negative case" <| \() ->
          cardsFromFactory
            [ (0, "A", False)
            , (1, "B", False)
            , (2, "C", False) ]
          |> Dict.values
          |> includesMatchingPair
          |> Expect.false "should be False"

        , test "positive case" <| \() ->
          cardsFromFactory
            [ (0, "A", False)
            , (1, "B", False)
            , (2, "A", False) ]
          |> Dict.values
          |> includesMatchingPair
          |> Expect.true "should be True"
        ]
    ]


includesMatchingPair : List Card -> Bool
includesMatchingPair cards =
  case cards of
    hd::tl ->
      if List.any (\card -> card.content == hd.content) tl then
        True
      else
        includesMatchingPair tl

    _ ->
      False
