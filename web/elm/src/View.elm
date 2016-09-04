module View exposing (view)

import Html exposing (Html,div)
import Html.Attributes exposing (class)

import Model exposing (..)
import Model.Page exposing (Page(..))
import View.Pages.Home
import View.Pages.Play
import View.Pages.Instructions
import Msg exposing (..)


view : Model -> Html Msg
view ({currentPage} as model) =
  case currentPage of
    Home ->
      View.Pages.Home.view model

    Instructions ->
      View.Pages.Instructions.view model

    Play ->
      View.Pages.Play.view model
