module View.Pages.Play exposing (view)

import Html exposing (Html,text,div,h1,p,button)
import Html.Attributes exposing (id,class,classList)
import Html.Events exposing (onClick)
import Html.Keyed
import Dict exposing (Dict)
import String

import Model exposing (..)
import Model.Page exposing (Page(..))
import View.Common exposing (..)
import Msg exposing (..)


view : Model -> Html Msg
view model =
  let
      htmlKey = model.roundCounter |> toString
      children =
        [ div [ class "elm-fullscreen-background" ] []
        , renderCards model ]
  in
      Html.Keyed.node
        "div"
        []
        [ (htmlKey, div [] children ) ]


renderCards : Model -> Html Msg
renderCards model =
  model.cards
  |> Dict.toList
  |> List.map renderCard
  |> div []


renderCard : (Int, Card) -> Html Msg
renderCard (key, card) =
  let
      (posX, posY) = card.position
      attrs =
        [ classList
            [ ("elm-card", True)
            , ("elm-card-fadeout", card.fadeout)
            , ("elm-card-selected", card.selected) ]
        , Html.Attributes.style
            [ ("top", posY |> toPercent)
            , ("left", posX |> toPercent)
            , ("background", card.content)
            ]
        ] ++ (if card.selected then [] else [ onClick (SelectCard key) ])
  in
      div
        attrs
        []


toPercent : Float -> String
toPercent coordinateBetween0and1 =
  (coordinateBetween0and1 * 100 |> toString) ++ "%"
