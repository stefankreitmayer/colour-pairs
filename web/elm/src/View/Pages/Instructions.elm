module View.Pages.Instructions exposing (view)

import Html exposing (Html,text,div,h1,p,button)
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
    [ h1 [] [ Html.text "How to play" ]
    , p [] [ text "Two people play together on opposite sides, sharing one device (tablet or smartphone). Cards can be selected by touching. Only one card can be selected per player at a time. When the players select two matching cards simultaneously, new cards appear." ]
    , button [ class "elm-btn-large elm-btn-play", onClick (Navigate Play) ]
      [ Html.text "Play" ] ]
