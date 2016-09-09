module Helpers.Factories exposing (..)

import Dict exposing (Dict)

import Model exposing (Card)


cardsFromFactory : List (Int, String, Bool) -> Dict Int Card
cardsFromFactory list =
  list
  |> List.map (\(key, content, selected) -> (key, Card content selected (0, 0) False))
  |> Dict.fromList
