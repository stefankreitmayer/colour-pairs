module Update exposing (update, urlUpdate)

import Dict exposing (Dict)
import Task
import Random
import Navigation

import Model exposing (..)
import Model.Url exposing (Url(..))
import Model.Screen exposing (Screen(..))
import Msg exposing (..)
import Touch exposing (..)

import Debug exposing (log)


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    Navigate url ->
      let
          pathname =
            case url of
              Home ->
                "/"
          model' = { model | currentUrl = url }
      in
          (model', Navigation.newUrl pathname)

    StartGame ->
      ({ initialModel | currentScreen = Play }, Cmd.none)

    ChangeSelection key state eventOrigin ->
      let
          model' =
            if eventOrigin == FromTouch then
              { model | assumeBrowserIsMobile = True }
            else
              model
      in
          case model'.nextRoundDue of
            Just _ ->
              (model', Cmd.none)

            Nothing ->
              if eventOrigin==FromMouse && model'.assumeBrowserIsMobile then
                (model', Cmd.none)
              else
                (updateSelection key state model', Cmd.none)

    Tick currentTime ->
      let
          isDue =
            case model.nextRoundDue of
              Nothing ->
                False

              Just oldDueTime ->
                currentTime >= oldDueTime

          (nextRoundDue', roundCounter', cards') =
            if isDue then
              (Nothing, model.roundCounter + 1, newCards (currentTime/100 |> floor) model.roundCounter)
            else
              (model.nextRoundDue, model.roundCounter, model.cards)

          model' =
            { model
            | currentTime = currentTime
            , nextRoundDue = nextRoundDue'
            , roundCounter = roundCounter'
            , cards = cards' }
      in
          (model', Cmd.none)


urlUpdate : Url -> Model -> (Model, Cmd Msg)
urlUpdate url model =
  case url of
    Home ->
      (model, Cmd.none)


updateOneCard : Int -> (Card -> Card) -> Dict Int Card -> Dict Int Card
updateOneCard key transformation cards =
  Dict.update
    key
    (\maybeCard ->
      case maybeCard of
        Nothing ->
          Nothing

        Just card ->
          Just (card |> transformation)
    )
    cards


updateSelection : Int -> Bool -> Model -> Model
updateSelection key state model =
  let
      cards' = model.cards |> updateOneCard key (\card -> { card | selected = state } )
      selectedCards = cards' |> Dict.filter (\_ card -> card.selected)
      (cards'', nextRoundDue') =
        if isMatchingPair selectedCards then
          (cards'
           |> Dict.map
                (\_ card -> { card
                            | position = if card.selected then (0.5, 0.5) else card.position
                            , fadeout = not card.selected })
          , Just (model.currentTime + pauseBetweenRounds))
        else
          (cards', Nothing)
  in
      { model
      | cards = cards''
      , nextRoundDue = nextRoundDue' }
