module Update exposing (update, urlUpdate)

import Dict exposing (Dict)
import Task
import Navigation

import Model exposing (..)
import Model.Page exposing (Page(..))
import Msg exposing (..)

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

    SelectCard key ->
      let
          cards' = updateOneCard key (\card -> { card | selected = True } ) model.cards
          selectedCards = cards' |> Dict.filter (\_ card -> card.selected)
          (cards'', nextRoundDue) =
            if isIdenticalPair selectedCards then
              (cards'
               |> Dict.map
                    (\_ card -> { card
                                | position = if card.selected then (0.5, 0.5) else card.position
                                , fadeout = not card.selected })
              , Just (model.currentTime + pauseBetweenRounds))
            else
              (cards', Nothing)
      in
          ({ model
           | cards = cards''
           , nextRoundDue = nextRoundDue }
          , Cmd.none)

    UnselectCard key ->
      ({ model
         | cards = updateOneCard key (\card -> { card | selected = False } ) model.cards }
      , Cmd.none)

    Tick currentTime ->
      let
          isDue =
            case model.nextRoundDue of
              Nothing ->
                False

              Just oldDueTime ->
                currentTime >= oldDueTime
          (nextRoundDue', cards', roundCounter') =
            if isDue then
              (Nothing, createCards [ "C", "D", "D" ], model.roundCounter + 1)
            else
              (model.nextRoundDue, model.cards, model.roundCounter)
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
          model' = { model | currentPage = page
                           , cards = createCards [ "A", "B", "A" ] }
      in
          (model', Cmd.none)

    _ ->
      (model, Cmd.none)


createCards : List String -> Dict Int Card
createCards values =
  values
  |> List.indexedMap (,)
  |> List.foldl
       (\(index,content) dict -> dict |> Dict.insert index
                                           (Card
                                              content
                                              False
                                              (0.1, 0.1 + 0.8 * (index |> toFloat) / ((List.length values)-1 |> toFloat))
                                              False)
       )
       Dict.empty


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
