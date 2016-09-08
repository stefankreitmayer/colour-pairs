module Msg exposing (..)

import Http exposing (..)
import Time exposing (Time)

import Model exposing (..)
import Model.Screen exposing (Screen(..))
import Model.Url exposing (Url(..))
import Touch exposing (..)


type Msg
  = Navigate Url
  | StartGame
  | ChangeSelection Int Bool EventOrigin
  | Tick Time


subscriptions : Model -> Sub Msg
subscriptions model =
  [ Time.every 100 Tick
  ]
  |> Sub.batch
