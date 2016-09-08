module TestMiniRandom exposing (testMiniRandom)

import Test exposing (Test,test,describe)
import Expect

import MiniRandom exposing (..)


testMiniRandom : Test
testMiniRandom =
  describe "MiniRandom"
    [ describe "step"
        [ test "outputs vary" <| \() ->
            let
                first = 0 |> step
                second = 0 |> step |> step
            in
                Expect.notEqual first second
        ]

    , describe "nextInt"
        [ test "outputs vary" <| \() ->
            let
                first = 0 |> nextInt 1000
                second = 0 |> nextInt 1000 |> nextInt 1000
            in
                Expect.notEqual first second
        ]
    ]
