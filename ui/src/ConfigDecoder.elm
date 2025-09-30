module ConfigDecoder exposing (App, Config, Package, configDecoder, packageDecoder)

import Json.Decode as Decode


type alias Config =
    { apps : List App
    , packages : List Package
    }


type alias App =
    { name : String
    , description : String
    , version : String
    }


type alias Package =
    { name : String
    , description : String
    , version : String
    , homePage : String
    , mainProgram : String
    }


configDecoder : Decode.Decoder Config
configDecoder =
    Decode.map2 Config
        (Decode.field "apps" (Decode.list appDecoder))
        (Decode.field "packages" (Decode.list packageDecoder))


appDecoder : Decode.Decoder App
appDecoder =
    Decode.map3 App
        (Decode.field "name" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "version" Decode.string)


packageDecoder : Decode.Decoder Package
packageDecoder =
    Decode.map5 Package
        (Decode.field "name" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "version" Decode.string)
        (Decode.field "homePage" Decode.string)
        (Decode.field "mainProgram" Decode.string)
