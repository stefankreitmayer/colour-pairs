module Touch exposing (EventOrigin(..), onTouchStart)

import Json.Decode as JD
import Html exposing (Attribute)
import Html.Events exposing (on)


type EventOrigin = FromMouse | FromTouch


onTouchStart : msg -> Attribute msg
onTouchStart msg =
  on "touchstart" <| JD.succeed msg
