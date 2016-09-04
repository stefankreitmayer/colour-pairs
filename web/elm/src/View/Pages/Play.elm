module View.Pages.Play exposing (view)

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
    []
    [ h1 [] [ Html.text "TODO: Play" ] ]
