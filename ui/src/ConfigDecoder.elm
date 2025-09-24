module ConfigDecoder exposing (Package, packageDecoder, configDecoder)

import Json.Decode as Decode


type alias Package =
    { name : String
    , description : String
    , version : String
    , homePage : String
    , mainProgram: String
    }


configDecoder : Decode.Decoder ( List Package )
configDecoder =
    -- Decode.map Tuple.pair
    --     (Decode.field "config" (Decode.list packageDecoder))
    --     (Decode.field "packages" (Decode.list packageDecoder))
        Decode.field "packages" (Decode.list packageDecoder)


packageDecoder : Decode.Decoder Package
packageDecoder =
    Decode.map5 Package
        (Decode.field "name" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "version" Decode.string)
        (Decode.field "homePage" Decode.string)
        (Decode.field "mainProgram" Decode.string)
