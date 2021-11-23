module Review.Suggest exposing (rule)

{-|

@docs rule

-}

import Dict exposing (Dict)
import Elm.Project
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node)
import Review.ModuleNameLookupTable as ModuleNameLookupTable exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Direction, Error, ModuleKey, Rule)
import Set exposing (Set)


{-| Reports... REPLACEME

    config =
        [ Review.Suggest.rule
        ]


## Fail

    a =
        "REPLACEME example to replace"


## Success

    a =
        "REPLACEME example to replace"


## When (not) to enable this rule

This rule is useful when REPLACEME.
This rule is not useful when REPLACEME.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template dillonkearns/elm-review-suggest/example --rules Review.Suggest
```

-}
rule : List ( Package, List (List String) ) -> Rule
rule suggestions =
    Rule.newProjectRuleSchema "Review.Suggestion" initialProjectContext
        |> Rule.withContextFromImportedModules
        |> Rule.withModuleVisitor moduleVisitor
        |> Rule.withModuleContextUsingContextCreator
            { fromProjectToModule = Rule.initContextCreator fromProjectToModule |> Rule.withModuleNameLookupTable |> Rule.withMetadata
            , fromModuleToProject = Rule.initContextCreator fromModuleToProject |> Rule.withModuleKey |> Rule.withMetadata
            , foldProjectContexts = foldProjectContexts
            }
        |> Rule.withFinalProjectEvaluation (finalProjectEvaluation suggestions)
        |> Rule.fromProjectRuleSchema


foldProjectContexts : ProjectContext -> ProjectContext -> ProjectContext
foldProjectContexts newContext previousContext =
    { moduleKeys = Dict.union newContext.moduleKeys previousContext.moduleKeys
    , referencedSuggestions = newContext.referencedSuggestions |> Set.union previousContext.referencedSuggestions
    }


type alias ModuleContext =
    { lookupTable : ModuleNameLookupTable.ModuleNameLookupTable
    , currentModule : ModuleName
    , referencedSuggestions : Set (List String)
    }


fromProjectToModule : ModuleNameLookupTable -> Rule.Metadata -> ProjectContext -> ModuleContext
fromProjectToModule lookupTable metadata projectContext =
    let
        moduleName =
            Rule.moduleNameFromMetadata metadata
    in
    { lookupTable = lookupTable
    , currentModule = moduleName
    , referencedSuggestions = projectContext.referencedSuggestions
    }


fromModuleToProject : Rule.ModuleKey -> Rule.Metadata -> ModuleContext -> ProjectContext
fromModuleToProject moduleKey metadata moduleContext =
    let
        moduleName : ModuleName
        moduleName =
            Rule.moduleNameFromMetadata metadata
    in
    { moduleKeys = Dict.singleton moduleName moduleKey
    , referencedSuggestions = moduleContext.referencedSuggestions
    }


type alias ProjectContext =
    { moduleKeys : Dict ModuleName ModuleKey
    , referencedSuggestions : Set (List String)
    }


moduleVisitor : Rule.ModuleRuleSchema schemaState ModuleContext -> Rule.ModuleRuleSchema { schemaState | hasAtLeastOneVisitor : () } ModuleContext
moduleVisitor schema =
    schema
        |> Rule.withExpressionVisitor expressionVisitor


initialProjectContext : ProjectContext
initialProjectContext =
    { moduleKeys = Dict.empty
    , referencedSuggestions = Set.empty
    }


type alias Package =
    { author : String, package : String }


expressionVisitor : Node Expression -> Direction -> ModuleContext -> ( List (Error {}), ModuleContext )
expressionVisitor node direction context =
    case Node.value node of
        Expression.FunctionOrValue _ functionOrValueName ->
            case ModuleNameLookupTable.moduleNameFor context.lookupTable node of
                Just moduleName ->
                    ( []
                    , { context
                        | referencedSuggestions =
                            context.referencedSuggestions
                                |> Set.insert (moduleName ++ [ functionOrValueName ])
                      }
                    )

                Nothing ->
                    ( [], context )

        _ ->
            ( [], context )


finalProjectEvaluation : List ( Package, List (List String) ) -> ProjectContext -> List (Error { useErrorForModule : () })
finalProjectEvaluation suggestions projectContext =
    let
        asSet : Set (List String)
        asSet =
            suggestions
                |> List.concatMap
                    (\( package, rules ) ->
                        rules
                            |> List.map
                                (\ruleName ->
                                    ruleName
                                )
                    )
                |> Set.fromList

        unusedSuggestions : List String
        unusedSuggestions =
            projectContext.referencedSuggestions
                |> Set.diff asSet
                |> Set.toList
                |> List.map (String.join ".")
    in
    unusedSuggestions
        |> List.map
            (\unused ->
                Rule.globalError
                    { message =
                        "Suggested Rule `"
                            ++ unused
                            ++ "` is not yet used."
                    , details = [ "" ]
                    }
            )
