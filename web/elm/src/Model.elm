module Model exposing (..)

import Date exposing (Date)

import Model.Page exposing (Page(..))

type alias Model =
  { currentPage : Page
  , cards : List Card }


type alias Card =
  { number : Int }


initialModel : Model
initialModel =
  { currentPage = Home
  , cards = [] }
