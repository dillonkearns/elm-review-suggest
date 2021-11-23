module Review.SuggestTest exposing (all)

import Review.Suggest exposing (rule)
import Review.Test
import Test exposing (Test, describe, only, test)


all : Test
all =
    describe "Review.Suggest"
        [ test "empty config with single suggestion" <|
            \() ->
                """module ReviewConfig exposing (config)

config : List Rule
config =
    []
"""
                    |> Review.Test.run
                        (rule
                            [ ( { author = "jfmengels", package = "elm-review-documentation " }
                              , [ [ "Docs", "NoMissing", "rule" ] ]
                              )
                            ]
                        )
                    |> Review.Test.expectGlobalErrors
                        [ { message = "Suggested Rule `Docs.NoMissing.rule` is not yet used."
                          , details = [ "" ]
                          }
                        ]
        , test "single used suggestion" <|
            \() ->
                """module ReviewConfig exposing (config)
                        
config : List Rule
config =
    [ Docs.NoMissing.rule ]
"""
                    |> Review.Test.run
                        (rule
                            [ ( { author = "jfmengels", package = "elm-review-documentation " }
                              , [ [ "Docs", "NoMissing", "rule" ] ]
                              )
                            ]
                        )
                    |> Review.Test.expectNoErrors
        ]
