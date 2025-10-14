module Main exposing (main)

import Browser
import ConfigDecoder exposing (App, Config, Package, configDecoder)
import Html exposing (Html, a, button, div, h5, hr, input, p, small, text)
import Html.Attributes exposing (class, href, name, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http
import Texts exposing (appInstructionsHtml, footerHtml, headerHtml, installInstructionsHtml, packageInstructionsHtml)



-- MODEL


type alias Model =
    { apps : List App
    , packages : List Package
    , selectedOutput : String
    , selectedApp : App
    , selectedPackage : Package
    , searchString : String
    , error : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { apps = []
      , packages = []
      , selectedOutput = "packages"
      , selectedApp =
            { name = ""
            , description = ""
            , version = ""
            , vm = { enable = False }
            }
      , selectedPackage =
            { name = ""
            , description = ""
            , version = ""
            , homePage = ""
            , mainProgram = ""
            }
      , searchString = ""
      , error = Nothing
      }
    , getConfig
    )



-- UPDATE


type Msg
    = GetConfig (Result Http.Error Config)
    | SelectOutput String
    | SelectApp App
    | SelectPackage Package
    | Search String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetConfig (Ok config) ->
            ( { model | apps = config.apps, packages = config.packages, error = Nothing }, Cmd.none )

        GetConfig (Err err) ->
            ( { model | error = Just (httpErrorToString err) }, Cmd.none )

        SelectOutput output ->
            ( { model | selectedOutput = output }, Cmd.none )

        SelectApp app ->
            ( { model | selectedApp = app }, Cmd.none )

        SelectPackage pkg ->
            ( { model | selectedPackage = pkg }, Cmd.none )

        Search string ->
            ( { model | searchString = string }, Cmd.none )



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
                    (searchHtml model.searchString)
                , div [ class "d-flex btn-group align-items-center" ]
                    (outputsTabHtml [ "PACKAGES", "APPLICATIONS" ] model.selectedOutput)

                -- separator
                , div [] [ hr [] [] ]

                -- packages
                , optionalDivHtml (model.selectedOutput == "packages")
                    (div [ class "list-group" ]
                        -- packages
                        (packagesHtml model.packages model.selectedPackage model.searchString)
                    )

                -- applications
                , optionalDivHtml (model.selectedOutput == "applications")
                    (div [ class "list-group" ]
                        -- applications
                        (appsHtml model.apps model.selectedApp model.searchString)
                    )

                -- error message
                , case model.error of
                    Just errMsg ->
                        div [] [ text ("Error: " ++ errMsg) ]

                    Nothing ->
                        text ""
                ]

            -- instructions panel
            , div [ class "col-lg-6 bg-dark text-white py-3 my-3" ]
                [ if String.isEmpty model.selectedPackage.name && String.isEmpty model.selectedApp.name then
                    -- install instructions
                    div []
                        installInstructionsHtml

                  else if model.selectedOutput == "packages" then
                    -- usage instructions
                    div []
                        (packageInstructionsHtml model.selectedPackage)

                  else
                    div []
                        (appInstructionsHtml model.selectedApp)
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


searchHtml : String -> List (Html Msg)
searchHtml searchString =
    [ input
        [ class "form-control form-control-lg py-2 my-2"
        , placeholder "Search for package or application ..."
        , value searchString
        , onInput Search
        ]
        []
    ]


outputsTabHtml : List String -> String -> List (Html Msg)
outputsTabHtml buttons activeButton =
    let
        buttonItem =
            \item ->
                button
                    [ class
                        ("btn btn-lg "
                            ++ (if String.toLower item == activeButton then
                                    "btn-dark"

                                else
                                    "btn-secondary"
                               )
                        )
                    , onClick (SelectOutput (String.toLower item))
                    ]
                    [ text item ]
    in
    List.map buttonItem buttons


optionalDivHtml : Bool -> Html Msg -> Html Msg
optionalDivHtml condition divElement =
    if condition then
        divElement

    else
        div [] []


packageActiveState : Package -> Package -> String
packageActiveState pkg selectedPkg =
    if pkg.name == selectedPkg.name then
        " active"

    else
        " inactive"


packageHtml : Package -> Package -> Html Msg
packageHtml pkg selectedPkg =
    a
        [ href ("#package-" ++ pkg.name)
        , class
            ("list-group-item list-group-item-action flex-column align-items-start" ++ packageActiveState pkg selectedPkg)
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
        ]


packagesHtml : List Package -> Package -> String -> List (Html Msg)
packagesHtml pkgs selectedPkg filter =
    let
        filteredPkgs =
            List.filter (\pkg -> String.contains filter pkg.name) pkgs
    in
    List.map
        (\pkg -> packageHtml pkg selectedPkg)
        filteredPkgs


appActiveState : App -> App -> String
appActiveState app selectedApp =
    if app.name == selectedApp.name then
        " active"

    else
        " inactive"


appHtml : App -> App -> Html Msg
appHtml app selectedApp =
    a
        [ href ("#app-" ++ app.name)
        , class
            ("list-group-item list-group-item-action flex-column align-items-start" ++ appActiveState app selectedApp)
        , onClick (SelectApp app)
        ]
        [ div
            [ name ("app-" ++ app.name)
            , class "d-flex w-100 justify-content-between"
            ]
            [ h5 [ class "mb-1" ] [ text app.name ]
            , small [] [ text ("v" ++ app.version) ]
            ]
        , p
            [ class "mb-1"
            ]
            [ text app.description ]
        ]


appsHtml : List App -> App -> String -> List (Html Msg)
appsHtml apps selectedApp filter =
    let
        filteredApps =
            List.filter (\app -> String.contains filter app.name) apps
    in
    List.map
        (\app -> appHtml app selectedApp)
        filteredApps



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
