module MagicToken.AddToTypes exposing (makeRule)

{-|

@docs rule

-}

import Elm.Syntax.Declaration as Declaration exposing (Declaration)
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node,range)
import Elm.Syntax.Range
import Elm.Syntax.Type
import Review.Rule as Rule exposing (Error, Rule)


{-| Reports... REPLACEME

    config =
        [ MagicToken.AddToTypes.rule
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
elm-review --template undefined/example --rules MagicToken.AddToTypes
```

-}
makeRule : String -> String -> Rule
makeRule typeName_ variantName_ =
    Rule.newModuleRuleSchema "MagicToken.AddToTypes" Nothing
        |> Rule.withDeclarationEnterVisitor (declarationVisitor typeName_ variantName_)
        |> Rule.fromModuleRuleSchema
        |> Debug.log "RULE_OUTPUT"

-- rule = makeRule "FrontendMsg" "Bar"

declarationVisitor : String -> String -> Node Declaration -> Context ->  (List (Error {}) , Context)
declarationVisitor typeName_ variantName_ node _ =

    case Node.value node of
        Declaration.CustomTypeDeclaration type_ ->
            case type_.name of
                Node.Node _ "FrontendMsg" ->
                   checkForVariant variantName_ (Node.range node) type_


                _ ->
                   ( [], Nothing)


        _ ->
            ( [], Nothing)



checkForVariant : String -> Elm.Syntax.Range.Range -> { a | constructors : List (Node Elm.Syntax.Type.ValueConstructor) } -> (List (Error {  }), Maybe b)
checkForVariant variantName_ range type_ =
    if List.member variantName_ (List.map variantName  type_.constructors)
      then ([], Nothing)
      else ([Rule.error
            { message = "FrontendMsg: variant " ++ variantName_ ++ " is missing"
            , details = [ Debug.toString  (List.map variantName type_.constructors),
              "Error location: " ++ Debug.toString range]
            }
           range]
            ,
            Nothing
            )

variantName : Node Elm.Syntax.Type.ValueConstructor  -> String
variantName node =
    Node.value node |> .name |> Node.value



-- Type mismatch
-- Required: (List (Error { }), Context)
-- Found: List (Error { }, Context)

--type Declaration
--    = FunctionDeclaration Function
--    | AliasDeclaration TypeAlias
--    | CustomTypeDeclaration Type
--    | PortDeclaration Signature
--    | InfixDeclaration Infix
--    | Destructuring (Node Pattern) (Node Expression)


contextOfNode : Node Declaration -> Context
contextOfNode node =
    case Node.value node of
        Declaration.CustomTypeDeclaration tipe ->
            --Just { typeInfo =  node.name
            --    , constructors = Node.value node
            --    }
            Nothing

        _ ->
            Nothing


type alias Context =
    Maybe
        { typeInfo : Node String
        , constructors : List (Node Elm.Syntax.Type.ValueConstructor)
        }


type alias ModuleContext =
    { moduleName : String
    }
