module View exposing (view)

import Html exposing (Html,div)
import Html.Attributes exposing (class)

import Model exposing (..)
import Model.Screen exposing (Screen(..))
import View.Screens.Welcome
import View.Screens.Play
import Msg exposing (..)


view : Model -> Html Msg
view ({currentScreen} as model) =
  case currentScreen of
    Welcome ->
      View.Screens.Welcome.view model

    Play ->
      View.Screens.Play.view model
