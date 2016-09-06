module View.Pages.Play exposing (view)

import Html exposing (Html,text,div,h1,p,button)
import Html.Attributes exposing (id,class,classList)
import Html.Events exposing (onClick)
import Dict exposing (Dict)

import Model exposing (..)
import Model.Page exposing (Page(..))
import View.Common exposing (..)
import Msg exposing (..)


view : Model -> Html Msg
view model =
  div
    []
    [ renderCards model ]


renderCards : Model -> Html Msg
renderCards model =
  model.cards
  |> Dict.toList
  |> List.map renderCard
  |> div []


renderCard : (Int, Card) -> Html Msg
renderCard (key, card) =
  let
      attrs =
        if card.selected then
          [ class "elm-card elm-card-selected" ]
        else
          [ class "elm-card", onClick (SelectCard key) ]
  in
      div
        attrs
        [ text card.content ]
