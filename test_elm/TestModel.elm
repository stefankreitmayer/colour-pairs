module TestModel exposing (testModel)

import Test exposing (Test,test,describe)
import Expect

import Dict exposing (Dict)

import Helpers.Stubs exposing (..)

import Model exposing (..)
import Model.Page exposing (Page(..))



testModel : Test
testModel =
  describe "Model"
    [ describe "initialModel"
        [ test "starts on home page" <| \() ->
            initialModel.currentPage |> Expect.equal Home
        ]

    , describe "isIdenticalPair"
        [ test "empty Dict" <| \() ->
            Dict.empty
            |> isIdenticalPair
            |> Expect.false "Two cards expected"
        , test "one Card" <| \() ->
            Dict.empty
            |> Dict.insert 0 (Card "A" False (0,0))
            |> isIdenticalPair
            |> Expect.false "Expected False"
        , test "two Cards with identical content" <| \() ->
            Dict.empty
            |> Dict.insert 0 (Card "A" False (0,0))
            |> Dict.insert 1 (Card "A" True (1,1))
            |> isIdenticalPair
            |> Expect.true "Expected True"
        , test "two Cards with different content" <| \() ->
            Dict.empty
            |> Dict.insert 0 (Card "A" False (0,0))
            |> Dict.insert 1 (Card "B" False (0,0))
            |> isIdenticalPair
            |> Expect.false "Expected False"
        , test "three Cards" <| \() ->
            Dict.empty
            |> Dict.insert 0 (Card "A" False (0,0))
            |> Dict.insert 1 (Card "A" False (0,0))
            |> Dict.insert 2 (Card "A" False (0,0))
            |> isIdenticalPair
            |> Expect.false "Expected False"
        ]
    ]
