module View.Screens.Welcome exposing (view)

import Html exposing (Html,text,div,h4,p,button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)

import Model exposing (..)
import Model.Screen exposing (Screen(..))
import View.Common exposing (..)
import Msg exposing (..)


view : Model -> Html Msg
view model =
  div
    [ class "elm-center-text" ]
    [ h4 [] [ text "Goal: Select two matching colours" ]
    , button [ class "elm-btn-large elm-btn-play", onClick StartGame ]
      [ Html.text "Play" ]
    , p [] [ text "(This game never ends. It just gets harder.)" ]
    ]
