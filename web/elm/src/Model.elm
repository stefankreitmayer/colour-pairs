module Model exposing (..)

import Dict exposing (Dict)
import Date exposing (Date)
import Time exposing (Time)

import Model.Url exposing (Url(..))
import Model.Screen exposing (Screen(..))
import Model.Palette as Palette exposing (randomPalette,colorToString)

import MiniRandom exposing (nextInt,step)


type alias Model =
  { currentUrl : Url
  , currentScreen : Screen
  , assumeBrowserIsMobile : Bool
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
  { currentUrl = Home
  , currentScreen = Welcome
  , assumeBrowserIsMobile = False
  , currentTime = 0
  , nextRoundDue = Nothing
  , roundCounter = 0
  , cards = newCards 0 0 }


pauseBetweenRounds : Time
pauseBetweenRounds = 3000


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
        randomPalette (nCards-1) randomSeed (1.0 / (toFloat nCards))
        |> List.map colorToString
      duplicate = List.take 1 uniqueContents
      allContents =
        uniqueContents
        |> rotate (nextInt (nCards-1) randomSeed)
        |> List.append duplicate
        |> rotate (nextInt nCards (randomSeed |> step))
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
                     (if index < nCards//2 then 0.15 else 0.85, 0.15 + 0.7 * (index % (nCards//2) |> toFloat) / (nCards//2-1 |> toFloat))
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
