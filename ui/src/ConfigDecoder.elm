module ConfigDecoder exposing (App, Config, Package, configDecoder, packageDecoder)

import Dict
import Json.Decode as Decode


type alias Config =
    { apps : List App
    , packages : List Package
    }


type alias App =
    { name : String
    , description : String
    , version : String
    , vm : AppVm
    }


type alias AppVm =
    { enable : Bool
    }


type alias Package =
    { name : String
    , description : String
    , version : String
    , homePage : String
    , mainProgram : String
    , builder : String
    }


configDecoder : Decode.Decoder Config
configDecoder =
    Decode.map2 Config
        (Decode.field "apps" (Decode.list appDecoder))
        (Decode.field "packages" (Decode.list packageDecoder))


appDecoder : Decode.Decoder App
appDecoder =
    Decode.map4 App
        (Decode.field "name" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "version" Decode.string)
        (Decode.field "vm" appVmDecoder)


appVmDecoder : Decode.Decoder AppVm
appVmDecoder =
    Decode.map AppVm
        (Decode.field "enable" Decode.bool)


packageBuilder : Decode.Decoder String
packageBuilder =
    Decode.field "build" (Decode.dict (Decode.field "enable" Decode.bool))
        |> Decode.map findEnabledBuilder


findEnabledBuilder : Dict.Dict String Bool -> String
findEnabledBuilder dict =
    dict
        |> Dict.toList
        |> List.filter (\( _, enabled ) -> enabled)
        |> List.head
        |> Maybe.map Tuple.first
        |> Maybe.withDefault "none"


packageDecoder : Decode.Decoder Package
packageDecoder =
    Decode.map6 Package
        (Decode.field "name" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "version" Decode.string)
        (Decode.field "homePage" Decode.string)
        (Decode.field "mainProgram" Decode.string)
        packageBuilder
