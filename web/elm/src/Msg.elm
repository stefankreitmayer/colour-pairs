module Msg exposing (..)

import Http exposing (..)
import Time exposing (Time)

import Model exposing (..)
import Model.Page exposing (Page(..))


type Msg
  = Navigate Page
  | SelectCard Int
  | UnselectCard Int
  | Tick Time


subscriptions : Model -> Sub Msg
subscriptions model =
  [ Time.every 100 Tick
  ]
  |> Sub.batch
