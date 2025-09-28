module Main exposing (main)

import Browser
import ConfigDecoder exposing (Package, configDecoder)
import Html exposing (Html, a, div, h5, hr, input, p, small, text)
import Html.Attributes exposing (class, href, name, placeholder, value)
import Html.Events exposing (onClick)
import Http
import Texts exposing (footerHtml, headerHtml, installInstructionsHtml, packageInstructionsHtml)



-- MODEL


type alias Model =
    { packages : List Package
    , selectedPackage : Package
    , error : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { packages = []
      , selectedPackage =
            { name = ""
            , description = ""
            , version = ""
            , homePage = ""
            , mainProgram = ""
            }
      , error = Nothing
      }
    , getConfig
    )



-- UPDATE


type Msg
    = GetConfig (Result Http.Error (List Package))
    | SelectPackage Package


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetConfig (Ok pkgs) ->
            ( { model | packages = pkgs, error = Nothing }, Cmd.none )

        GetConfig (Err err) ->
            ( { model | error = Just (httpErrorToString err) }, Cmd.none )

        SelectPackage pkg ->
            ( { model | selectedPackage = pkg }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        -- header
        [ div [ class "row" ]
            [ div
                [ class "col-lg-12 border fw-bold fs-1 py-2 my-2"
                ]
                -- header
                [ headerHtml ]
            ]

        -- content
        , div [ class "row" ]
            -- packages panel
            [ div [ class "col-lg-6 border bg-light py-3 my-3" ]
                [ div
                    [ class "name d-flex justify-content-between align-items-center"
                    ]
                    --search
                    searchHtml

                -- separator
                , div [] [ hr [] [] ]

                -- packages
                , div [ class "list-group" ]
                    (List.map
                        (\pkg -> packageHtml pkg model.selectedPackage)
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


getConfig : Cmd Msg
getConfig =
    Http.get
        { url = "forge-config.json"
        , expect = Http.expectJson GetConfig configDecoder
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



-- HTML functions


searchHtml : List (Html Msg)
searchHtml =
    [ input
        [ class "form-control form-control-lg py-2 my-2"
        , placeholder "Search for package ..."
        , value ""
        ]
        []
    ]


packageHtml : Package -> Package -> Html Msg
packageHtml pkg selectedPkg =
    a
        [ href ("#package-" ++ pkg.name)
        , class
            ("list-group-item list-group-item-action flex-column align-items-start"
                ++ (if pkg.name == selectedPkg.name then
                        " active"

                    else
                        " inactive"
                   )
            )
        , onClick (SelectPackage pkg)
        ]
        [ div
            [ name ("package-" ++ pkg.name)
            , class "d-flex w-100 justify-content-between"
            ]
            [ h5 [ class "mb-1" ] [ text pkg.name ]
            , small [] [ text ("v" ++ pkg.version) ]
            ]
        , p
            [ class "mb-1"
            ]
            [ text pkg.description ]
        , small [] [ text pkg.homePage ]
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
