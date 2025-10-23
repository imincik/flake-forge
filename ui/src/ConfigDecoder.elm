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
    , usage: String
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
    Decode.map5 App
        (Decode.field "name" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "version" Decode.string)
        (Decode.field "usage" Decode.string)
        (Decode.field "vm" appVmDecoder)


appVmDecoder : Decode.Decoder AppVm
appVmDecoder =
    Decode.map AppVm
        (Decode.field "enable" Decode.bool)


packageBuilder : Decode.Decoder String
packageBuilder =
    Decode.field "build" (Decode.dict (Decode.maybe (Decode.oneOf [ Decode.field "enable" Decode.bool, Decode.bool ])))
        |> Decode.map findEnabledBuilder


findEnabledBuilder : Dict.Dict String (Maybe Bool) -> String
findEnabledBuilder dict =
    dict
        |> Dict.filter (\_ value -> value == Just True)
        |> Dict.keys
        |> List.head
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
