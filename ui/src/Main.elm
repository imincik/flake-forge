module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode



-- MODEL


type alias Model =
    { nixpkgs : List String
    , packages : List Package
    , error : Maybe String
    }


type alias Package =
    { name : String
    , description : String
    , version : String
    , homePage : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { nixpkgs = [], packages = [], error = Nothing }
    , getPackages
    )



-- UPDATE


type Msg
    = GotPackages (Result Http.Error ( List String, List Package ))


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
        -- header
        [ div [ class "row" ]
            [ div [ class "col-lg-10 border fw-bold fs-1 py-2 my-2" ]
                [ p []
                    [ span [ style "margin-right" "10px" ] [ text "[Flake Forge]" ]
                    , span [ class "fs-2 text-secondary" ] [ text "the sofware repository" ]
                    ]
                ]
            ]

        -- content
        , div [ class "row" ]
            [ div [ class "col-lg-10 border bg-light py-3 my-3" ]
                [ div [ class "name d-flex justify-content-between align-items-center" ]
                    [ -- search
                      input [ class "form-control form-control-lg py-2 my-2", placeholder "Package name ...", value "" ] []
                    , button [ class "btn btn-primary btn-lg" ] [ text "Search" ]
                    ]

                -- separator
                , div [] [ hr [] [] ]

                -- packages
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

                -- footer
                , div [ class "col-sm-12" ]
                    [ hr [] []
                    , p [ class "text-center" ]
                        [ span [ class "text-secondary fs-8" ] [ text "Developed by " ]
                        , a [ href "https://github.com/imincik", target "_blank" ] [ text "@imincik" ]
                        , text " . "
                        , span [ class "text-secondary fs-8" ] [ text "Powered by " ]
                        , a [ href "https://nixos.org", target "_blank" ] [ text "Nix, Nixpkgs" ]
                        , a [ href "https://elm-lang.org", target "_blank" ] [ text " and Elm" ]
                        , text " ."
                        ]
                    ]
                , case model.error of
                    Just errMsg ->
                        div [] [ text ("Error: " ++ errMsg) ]

                    Nothing ->
                        text ""
                ]
            ]
        ]



-- HTTP


getPackages : Cmd Msg
getPackages =
    Http.get
        { url = "forge-config.json"
        , expect = Http.expectJson GotPackages packagesJsonDecoder
        }


packagesJsonDecoder : Decode.Decoder ( List String, List Package )
packagesJsonDecoder =
    Decode.map2 Tuple.pair
        (Decode.field "nixpkgs" (Decode.list Decode.string))
        (Decode.field "packages" (Decode.list packageDecoder))


packageDecoder : Decode.Decoder Package
packageDecoder =
    Decode.map4 Package
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
