module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import Review.Rule exposing (Rule)
import Review.Suggest


config : List Rule
config =
    [ Review.Suggest.rule
        [ ( { author = "jfmengels"
            , package = "elm-review-documentation"
            }
          , [ [ "Docs", "NoMissing", "rule" ]
            ]
          )
        , ( { author = "jfmengels"
            , package = "elm-review-common"
            }
          , [ [ "NoExposingEverything", "rule" ]
            , [ "NoDeprecated", "rule" ]
            , [ "NoMissingTypeAnnotation", "rule" ]
            , [ "NoMissingTypeExpose", "rule" ]
            ]
          )
        ]
    ]
