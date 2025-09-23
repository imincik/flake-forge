module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Texts exposing (..)



-- MODEL


type alias Model =
    { nixpkgs : List String
    , packages : List Package
    , selectedPackage : String
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
    ( { nixpkgs = [], packages = [], selectedPackage = "", error = Nothing }
    , getPackages
    )



-- UPDATE


type Msg
    = GotPackages (Result Http.Error ( List String, List Package ))
    | SelectPackage String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotPackages (Ok ( nixpkgs, pkgs )) ->
            ( { model | nixpkgs = nixpkgs, packages = pkgs, error = Nothing }, Cmd.none )

        GotPackages (Err err) ->
            ( { model | error = Just (httpErrorToString err) }, Cmd.none )

        SelectPackage pkg ->
            ( { model | selectedPackage = pkg }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        -- header
        [ div [ class "row" ]
            [ div [ class "col-lg-12 border fw-bold fs-1 py-2 my-2" ]
                [ p []
                    [ span [ style "margin-right" "10px" ] [ text "[Flake Forge]" ]
                    , span [ class "fs-2 text-secondary" ] [ text "the sofware repository" ]
                    ]
                ]
            ]

        -- content
        , div [ class "row" ]
            [ div [ class "col-lg-6 border bg-light py-3 my-3" ]
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
                            a [ href "#", class "list-group-item list-group-item-action flex-column align-items-start", onClick (SelectPackage pkg.name) ]
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

            -- instructions
            , div [ class "col-lg-6 bg-dark text-white py-3 my-3" ]
                [ if String.isEmpty model.selectedPackage then
                    div []
                        [ h2 [] [ text "ABOUT" ]
                        , p [] [ text aboutText ]
                        , h2 [] [ text "INSTALL NIX" ]
                        , p [ style "margin-bottom" "0em" ] installNixTemplateComment
                        , pre [ class "text-warning" ] [ text installNixTemplate ]
                        , p [ style "margin-bottom" "0em" ] [ text clickOnPackageText ]
                        ]

                  else
                    div []
                        [ h2 [] [ text ("PACKAGE: " ++ model.selectedPackage) ]
                        , p [ style "margin-bottom" "0em" ] [ text runPackageInShellComment ]
                        , pre [ class "text-warning" ] [ text (stringFromTemplate model.selectedPackage runPackageInShellTemplate) ]
                        , p [ style "margin-bottom" "0em" ] [ text runPackageInContainerComment ]
                        , pre [ class "text-warning" ] [ text (stringFromTemplate model.selectedPackage buildContainerImageTemplate) ]
                        , pre [ class "text-warning" ] [ text runContainerTemplate ]
                        , hr [] []
                        , text "Recipe: "
                        , a
                            [ href ("https://github.com/imincik/flake-forge/blob/master/packages/" ++ model.selectedPackage ++ "/recipe.nix")
                            , target "_blank"
                            ]
                            [ text (model.selectedPackage ++ "/recipe.nix") ]
                        ]
                ]
            ]

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


stringFromTemplate : String -> String -> String
stringFromTemplate s template =
    String.replace "<s>" s template



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
