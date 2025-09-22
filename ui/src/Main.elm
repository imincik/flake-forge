module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode



-- MODEL


type alias Model =
    { nixpkgs : List String
    , packages : List Pkg
    , error : Maybe String
    }


type alias Pkg =
    { name : String
    , description : String
    , version : String
    , homePage: String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { nixpkgs = [], packages = [], error = Nothing }
    , getPackages
    )



-- UPDATE


type Msg
    = GotPackages (Result Http.Error ( List String, List Pkg ))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotPackages (Ok ( nixpkgs, pkgs )) ->
            ( { model | nixpkgs = nixpkgs, packages = pkgs, error = Nothing }, Cmd.none )

        GotPackages (Err err) ->
            ( { model | error = Just (httpErrorToString err) }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h2 [] [ text "PACKAGES" ]
        , hr [] []

        , div [ class "list-group" ]
            (List.map
                (\pkg ->
                    a [ href "#", class "list-group-item list-group-item-action flex-column align-items-start" ]
                        [ div [ class "d-flex w-100 justify-content-between" ]
                            [ h5 [ class "mb-1" ] [ text pkg.name ]
                            , small [] [ text ("v" ++ pkg.version) ]
                            ]
                        , p [ class "mb-1" ] [ text pkg.description ]
                        , small [] [ text pkg.homePage ]
                        ]
                )
                model.packages
            )

        , case model.error of
            Just errMsg ->
                div [] [ text ("Error: " ++ errMsg) ]

            Nothing ->
                text ""
        ]



-- HTTP


getPackages : Cmd Msg
getPackages =
    Http.get
        { url = "forge-config.json"
        , expect = Http.expectJson GotPackages packagesJsonDecoder
        }


packagesJsonDecoder : Decode.Decoder ( List String, List Pkg )
packagesJsonDecoder =
    Decode.map2 Tuple.pair
        (Decode.field "nixpkgs" (Decode.list Decode.string))
        (Decode.field "packages" (Decode.list packageDecoder))


packageDecoder : Decode.Decoder Pkg
packageDecoder =
    Decode.map4 Pkg
        (Decode.field "name" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "version" Decode.string)
        (Decode.field "homePage" Decode.string)


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        Http.BadUrl s ->
            "Bad URL: " ++ s

        Http.Timeout ->
            "Request timed out"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus s ->
            "Bad response: " ++ String.fromInt s

        Http.BadBody s ->
            "Bad body: " ++ s



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
