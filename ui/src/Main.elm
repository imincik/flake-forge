module Main exposing (main)

import Browser
import ConfigDecoder exposing (Package, configDecoder)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Texts exposing (..)



-- MODEL


type alias Model =
    { nixpkgs : List String
    , packages : List Package
    , selectedPackage : Package
    , error : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { nixpkgs = []
      , packages = []
      , selectedPackage =
            { name = ""
            , description = ""
            , version = ""
            , homePage = ""
            }
      , error = Nothing
      }
    , getPackages
    )



-- UPDATE


type Msg
    = GotPackages (Result Http.Error ( List String, List Package ))
    | SelectPackage Package


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
                -- header
                [ headerHtml ]
            ]

        -- content
        , div [ class "row" ]
            -- packages panel
            [ div [ class "col-lg-6 border bg-light py-3 my-3" ]
                [ div [ class "name d-flex justify-content-between align-items-center" ]
                    --search
                    searchHtml

                -- separator
                , div [] [ hr [] [] ]

                -- packages
                , div [ class "list-group" ]
                    (List.map
                        (\pkg -> packageHtml pkg)
                        model.packages
                    )
                , case model.error of
                    Just errMsg ->
                        div [] [ text ("Error: " ++ errMsg) ]

                    Nothing ->
                        text ""
                ]

            -- instructions panel
            , div [ class "col-lg-6 bg-dark text-white py-3 my-3" ]
                [ if String.isEmpty model.selectedPackage.name then
                    div []
                        -- install instructions
                        installInstructionsHtml

                  else
                    div []
                        -- usage instructions
                        (packageInstructionsHtml model.selectedPackage)
                ]
            ]

        -- footer
        , div [ class "col-sm-12" ]
            [ hr [] []

            -- footer
            , footerHtml
            ]
        ]



-- HTTP


getPackages : Cmd Msg
getPackages =
    Http.get
        { url = "forge-config.json"
        , expect = Http.expectJson GotPackages configDecoder
        }


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



-- html functions


headerHtml : Html Msg
headerHtml =
    p []
        [ span [ style "margin-right" "10px" ] [ text "[Flake Forge]" ]
        , span [ class "fs-2 text-secondary" ] [ text "the software distribution system" ]
        ]


searchHtml : List (Html Msg)
searchHtml =
    [ input [ class "form-control form-control-lg py-2 my-2", placeholder "Package name ...", value "" ] []
    , button [ class "btn btn-primary btn-lg" ] [ text "Search" ]
    ]


packageHtml : Package -> Html Msg
packageHtml pkg =
    a
        [ href "#"
        , class "list-group-item list-group-item-action flex-column align-items-start"
        , onClick (SelectPackage pkg)
        ]
        [ div [ class "d-flex w-100 justify-content-between" ]
            [ h5 [ class "mb-1" ] [ text pkg.name ]
            , small [] [ text ("v" ++ pkg.version) ]
            ]
        , p [ class "mb-1" ] [ text pkg.description ]
        , small [] [ text pkg.homePage ]
        ]


footerHtml : Html Msg
footerHtml =
    p [ class "text-center" ]
        [ span [ class "text-secondary fs-8" ] [ text "Developed by " ]
        , a [ href "https://github.com/imincik", target "_blank" ] [ text "@imincik" ]
        , text " . "
        , span [ class "text-secondary fs-8" ] [ text "Powered by " ]
        , a [ href "https://nixos.org", target "_blank" ] [ text "Nix, Nixpkgs" ]
        , a [ href "https://elm-lang.org", target "_blank" ] [ text " and Elm" ]
        , text " ."
        ]


installInstructionsHtml : List (Html Msg)
installInstructionsHtml =
    [ h2 [] [ text "ABOUT" ]
    , p [] [ text aboutText ]
    , h2 [] [ text "INSTALL NIX" ]
    , p [ style "margin-bottom" "0em" ] installNixText
    , pre [ class "text-warning" ] [ text installNixCmd ]
    , p [ style "margin-bottom" "0em" ] [ text clickOnPackageText ]
    ]


packageInstructionsHtml : Package -> List (Html Msg)
packageInstructionsHtml pkg =
    [ h2 [] [ text ("PACKAGE: " ++ pkg.name) ]
    , p [ style "margin-bottom" "0em" ] [ text runInShellComment ]
    , pre [ class "text-warning" ] [ text (runInShellCmd pkg.name) ]
    , p [ style "margin-bottom" "0em" ] [ text runInContainerComment ]
    , pre [ class "text-warning" ] [ text (runContainerCmd pkg.name) ]
    , hr [] []
    , text "Recipe: "
    , a
        [ href ("https://github.com/imincik/flake-forge/blob/master/packages/" ++ pkg.name ++ "/recipe.nix")
        , target "_blank"
        ]
        [ text (pkg.name ++ "/recipe.nix") ]
    ]



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
