module Helpers.Stubs exposing (..)

import Dict exposing (Dict)

import Model exposing (Card)


stubCards : List (Int, String, Bool) -> Dict Int Card
stubCards list =
  list
  |> List.map (\(key, content, selected) -> (key, Card content selected (0, 0) False))
  |> Dict.fromList
