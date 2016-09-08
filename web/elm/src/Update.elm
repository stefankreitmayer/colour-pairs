module Update exposing (update, urlUpdate)

import Dict exposing (Dict)
import Task
import Random
import Navigation

import Model exposing (..)
import Model.Page exposing (Page(..))
import Msg exposing (..)
import Touch exposing (..)

import Debug exposing (log)


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    Navigate page ->
      let
          pathname =
            case page of
              Home ->
                "/"

              Instructions ->
                "/instructions"

              Play ->
                "/play"
          model' = { model | currentPage = page }
      in
          (model', Navigation.newUrl pathname)

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


urlUpdate : Page -> Model -> (Model, Cmd Msg)
urlUpdate page model =
  case page of
    Play ->
      let
          model' = { initialModel
                   | currentPage = page }
      in
          (model', Cmd.none)

    _ ->
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
