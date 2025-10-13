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


packageDecoder : Decode.Decoder Package
packageDecoder =
    Decode.map5 Package
        (Decode.field "name" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "version" Decode.string)
        (Decode.field "homePage" Decode.string)
        (Decode.field "mainProgram" Decode.string)
