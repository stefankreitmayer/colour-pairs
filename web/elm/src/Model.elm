module Model exposing (..)

import Dict exposing (Dict)
import Date exposing (Date)
import Time exposing (Time)
import String

import Model.Page exposing (Page(..))

type alias Model =
  { currentPage : Page
  , currentTime : Time
  , nextRoundDue : Maybe Time
  , roundCounter : Int
  , cards : Dict Int Card }


type alias Card =
  { content : String
  , selected : Bool
  , position : Vector
  , fadeout : Bool }


type alias Vector = (Float,Float)


initialModel : Model
initialModel =
  { currentPage = Home
  , currentTime = 0
  , nextRoundDue = Nothing
  , roundCounter = 0
  , cards = newCards 222 0 }


pauseBetweenRounds : Time
pauseBetweenRounds = 3000


randomColors : Int -> Int -> List String
randomColors seed n =
  if n<=0 then
    []
  else
    (randomColor seed) :: (randomColors ((seed+123456789) % 900719925474099) (n-1))


randomColor : Int -> String
randomColor seed =
  let
      values =
        [ randomInt seed 256
        , randomInt (seed//2) 256
        , randomInt (seed//3) 256 ]
        |> List.map toString
  in
      "rgb(" ++ (String.join "," values) ++ ")"


randomInt : Int -> Int -> Int
randomInt seed upperLimit =
  seed % upperLimit


rotate : Int -> List a -> List a
rotate n input =
  if n<=0 then
    input
  else
    case input of
      hd::tl ->
        rotate (n-1) (tl ++ [ hd ])

      _ ->
        input


newCards : Int -> Int -> Dict Int Card
newCards randomSeed roundCounter =
  let
      nCards = roundCounter // 2 * 2 + 4
      uniqueContents =
        randomColors randomSeed (nCards-1)
      duplicate = List.take 1 uniqueContents
      allContents =
        uniqueContents
        |> rotate (randomInt randomSeed (nCards-1))
        |> List.append duplicate
        |> rotate (randomInt (randomSeed//2) nCards)
  in
        allContents
        |> List.indexedMap (,)
        |> List.foldl
             (\(index, content) result ->
               result
               |> Dict.insert index
                    (Card
                     content
                     False
                     (0.1, 0.1 + 0.8 * (index |> toFloat) / (nCards-1 |> toFloat))
                     False)
             )
             Dict.empty


isMatchingPair : Dict Int Card -> Bool
isMatchingPair cards =
  case cards |> Dict.values of
    [ a, b ] ->
      a.content == b.content

    _ ->
      False
