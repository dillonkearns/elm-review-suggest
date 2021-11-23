# elm-review-suggest

Provides [`elm-review`](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) rules to REPLACEME.


## Provided rules

- [`Review.Suggest`](https://package.elm-lang.org/packages/dillonkearns/elm-review-suggest/1.0.0/Review-Suggest) - Reports REPLACEME.


## Configuration

```elm
module ReviewConfig exposing (config)

import Review.Suggest
import Review.Rule exposing (Rule)

config : List Rule
config =
    [ Review.Suggest.rule
    ]
```


## Try it out

You can try the example configuration above out by running the following command:

```bash
elm-review --template dillonkearns/elm-review-suggest/example
```
