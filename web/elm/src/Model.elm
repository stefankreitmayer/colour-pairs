module Model exposing (..)

import Dict exposing (Dict)
import Date exposing (Date)

import Model.Page exposing (Page(..))

type alias Model =
  { currentPage : Page
  , cards : Dict Int Card }


type alias Card =
  { content : String
  , selected : Bool }


initialModel : Model
initialModel =
  { currentPage = Home
  , cards = Dict.empty }
