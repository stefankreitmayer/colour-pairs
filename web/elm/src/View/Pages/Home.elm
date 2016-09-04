module View.Pages.Home exposing (view)

import Html exposing (Html,text,div,p,h3,button)
import Html.Attributes exposing (id,class)
import Html.Events exposing (onClick)

import Model exposing (..)
import Model.Page exposing (Page(..))
import View.Common exposing (..)
import Msg exposing (..)


view : Model -> Html Msg
view model =
  div
    [ class "elm-center-text" ]
    [ h3 [] [ text "Note: This game requires multi-touch!" ]
    , p [] [ text "It works on a tablet or smartphone, but not on a laptop." ]
    , button [ class "elm-btn-large elm-btn-instructions", onClick (Navigate Instructions) ]
      [ Html.text "Instructions" ]
    , button [ class "elm-btn-large elm-btn-play", onClick (Navigate Play) ]
      [ Html.text "Play" ] ]
