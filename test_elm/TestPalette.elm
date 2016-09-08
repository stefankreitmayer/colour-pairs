module TestPalette exposing (testPalette)

import Test exposing (Test,test,describe)
import Expect

import Color exposing (Color)

import Model.Palette exposing (..)


testPalette : Test
testPalette =
  describe "Palette"
    [
      describe "rgbDistance"
        [ test "zero distance" <| \() ->
            rgbDistance Color.blue Color.blue
            |> Expect.equal 0

        , test "smallest measurable distance" <| \() ->
            rgbDistance Color.black (Color.rgb 0 0 1)
            |> Expect.equal (1.0 / 3.0 / 255.0)

        , test "highest distance" <| \() ->
            rgbDistance Color.black Color.white
            |> Expect.equal 1
        ]

    , describe "randomColor"
        [ test "outputs vary" <| \() ->
            Expect.notEqual (randomColor 0) (randomColor 1)
        ]

    , describe "quality = minimal rgbDistance between any two items"
        [ test "returns 0 if all items are equal" <| \() ->
            [ Color.blue, Color.blue, Color.blue ]
            |> quality
            |> Expect.equal 0

        , test "returns 1 if all items are maximally different" <| \() ->
            [ Color.black, Color.white ]
            |> quality
            |> Expect.equal 1
        ]

    , describe "randomPalette"
        [ test "empty" <| \() ->
            randomPalette 0 0 0
            |> Expect.equal []

        , test "1 color" <| \() ->
            randomPalette 1 0 0
            |> List.length
            |> Expect.equal 1

        , test "several colors" <| \() ->
            randomPalette 3 0 0
            |> List.length
            |> Expect.equal 3

        , test "colors are different" <| \() ->
            randomPalette 2 0 0
            |> quality
            |> Expect.greaterThan 0
        ]
    ]
