module Msg exposing (..)

import Http exposing (..)
import Time exposing (Time)

import Model exposing (..)
import Model.Page exposing (Page(..))
import Touch exposing (..)


type Msg
  = Navigate Page
  | ChangeSelection Int Bool EventOrigin
  | Tick Time


subscriptions : Model -> Sub Msg
subscriptions model =
  [ Time.every 100 Tick
  ]
  |> Sub.batch
