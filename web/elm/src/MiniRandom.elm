module MiniRandom exposing (step,nextInt)


step : Int -> Int
step startValue =
  ((startValue * 7621) + 1) % 32768


nextInt : Int -> Int -> Int
nextInt maxExclusive startValue =
  (startValue |> step) % maxExclusive
