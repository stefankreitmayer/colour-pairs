module Main exposing (..)

import Html exposing (Html)

import Navigation

import Model exposing (Model,initialModel)
import Model.Url exposing (Url(..))
import Update exposing (update,urlUpdate)
import View exposing (view)
import Msg exposing (Msg,subscriptions)


main : Program Never
main =
  Navigation.program urlParser
    { init = init
    , update = update
    , urlUpdate = urlUpdate
    , view = view
    , subscriptions = subscriptions }


init : Url -> (Model, Cmd Msg)
init _ =
  urlUpdate Home initialModel


urlParser : Navigation.Parser Url
urlParser =
  Navigation.makeParser fromUrl


fromUrl : Navigation.Location -> Url
fromUrl _ =
  Home
