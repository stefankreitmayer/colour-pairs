module Model.Palette exposing (..)

import Color exposing (Color)
import String

import Debug exposing (log)

import MiniRandom


randomColor : Int -> Color
randomColor seed =
  let
      red = seed |> MiniRandom.nextInt 256
      green = red |> MiniRandom.nextInt 256
      blue = green |> MiniRandom.nextInt 256
  in
      Color.rgb red green blue


randomPalette : Int -> Int -> Float -> List Color
randomPalette n seed targetQuality =
  if n <= 0 then
    []
  else
    let
        nextSeed = seed |> MiniRandom.step
        candidate =
          (randomColor seed) :: (randomPalette (n-1) nextSeed targetQuality)
    in
        if quality candidate >= targetQuality then
          candidate
        else
          randomPalette n nextSeed (targetQuality * 0.9)


rgbDistance : Color -> Color -> Float
rgbDistance colorA colorB =
  let
      a = Color.toRgb colorA
      b = Color.toRgb colorB
  in
      ((
        (a.red - b.red |> abs) +
        (a.green - b.green |> abs) +
        (a.blue - b.blue |> abs)
      ) |> toFloat) / (3.0*255.0)


quality : List Color -> Float
quality colors =
  case colors of
    [] ->
      0 -- arbitrary because this function needs at least one color to be useful

    [ color ] ->
      1.0

    hd::tl ->
      tl
      |> List.foldr (\color minimum -> min minimum (rgbDistance color hd)) (quality tl)


colorToString : Color -> String
colorToString color =
  let
      c = Color.toRgb color
      values = [ c.red, c.green, c.blue ]
  in
      "rgb(" ++ (String.join "," (values |> List.map toString)) ++ ")"