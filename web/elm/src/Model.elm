module Model exposing (..)

import Dict exposing (Dict)
import Date exposing (Date)

import Model.Page exposing (Page(..))

type alias Model =
  { currentPage : Page
  , cards : Dict Int Card }


type alias Card =
  { content : String
  , selected : Bool
  , position : Vector }


type alias Vector = (Float,Float)


initialModel : Model
initialModel =
  { currentPage = Home
  , cards = Dict.empty }


isIdenticalPair : Dict Int Card -> Bool
isIdenticalPair cards =
  case cards |> Dict.values of
    [ a, b ] ->
      a.content == b.content

    _ ->
      False
