port module OptionsMain exposing (main)

import Browser
import Browser.Navigation as Nav
import Dict
import Html exposing (Html, a, button, code, div, h5, hr, input, p, pre, small, span, text)
import Html.Attributes exposing (class, href, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http
import OptionsDecoder exposing (Option, OptionsData, optionsDecoder)
import Url



-- PORTS


port copyToClipboard : String -> Cmd msg



-- MODEL


type alias Model =
    { options : List Option
    , selectedOption : Maybe Option
    , searchString : String
    , categoryFilter : String
    , error : Maybe String
    , navKey : Nav.Key
    , url : Url.Url
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { options = []
      , selectedOption = Nothing
      , searchString = ""
      , categoryFilter = "packages"
      , error = Nothing
      , navKey = key
      , url = url
      }
    , getOptions
    )



-- UPDATE


type Msg
    = GetOptions (Result Http.Error OptionsData)
    | SelectOption Option
    | Search String
    | FilterCategory String
    | CopyCode String
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetOptions (Ok optionsData) ->
            let
                optionsList =
                    Dict.values optionsData
                        |> List.sortBy .name

                updatedModel =
                    { model | options = optionsList, error = Nothing }
            in
            ( selectFromUrl updatedModel, Cmd.none )

        GetOptions (Err err) ->
            ( { model | error = Just (httpErrorToString err) }, Cmd.none )

        SelectOption option ->
            ( { model | selectedOption = Just option }
            , Nav.pushUrl model.navKey ("#option-" ++ option.name)
            )

        Search string ->
            ( { model | searchString = string }, Cmd.none )

        FilterCategory category ->
            ( { model | categoryFilter = category }, Cmd.none )

        CopyCode code ->
            ( model, copyToClipboard code )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navKey (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( selectFromUrl { model | url = url }, Cmd.none )


selectFromUrl : Model -> Model
selectFromUrl model =
    case model.url.fragment of
        Just fragment ->
            if String.startsWith "option-" fragment then
                case List.filter (\opt -> opt.name == String.dropLeft 7 fragment) model.options |> List.head of
                    Just option ->
                        { model
                            | selectedOption = Just option
                            , categoryFilter = getOptionCategory option
                        }

                    Nothing ->
                        model

            else
                model

        Nothing ->
            model



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ -- content
          div [ class "row" ]
            [ -- options list panel
              div [ class "col-lg-6 border bg-light py-3 my-3" ]
                [ div [ class "name d-flex justify-content-between align-items-center" ]
                    (searchHtml model.searchString)
                , div [ class "d-flex btn-group align-items-center my-2" ]
                    (categoryTabsHtml model.categoryFilter)

                -- separator
                , div [] [ hr [] [] ]

                -- options list
                , div [ class "list-group" ]
                    (optionsHtml model.options model.selectedOption model.searchString model.categoryFilter)

                -- error message
                , case model.error of
                    Just errMsg ->
                        div [ class "alert alert-danger mt-3" ] [ text ("Error: " ++ errMsg) ]

                    Nothing ->
                        text ""
                ]

            -- option details panel
            , div [ class "col-lg-6 bg-dark text-white py-3 my-3" ]
                [ case model.selectedOption of
                    Just option ->
                        optionDetailsHtml option

                    Nothing ->
                        div [ class "p-3" ]
                            [ p [] [ text "Select a configuration option to view its details." ]
                            , hr [] []
                            , p [] [ text "You can search and filter options using the controls on the left." ]
                            ]
                ]
            ]
        ]



-- HTTP


getOptions : Cmd Msg
getOptions =
    Http.get
        { url = "options.json"
        , expect = Http.expectJson GetOptions optionsDecoder
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



-- HTML FUNCTIONS


searchHtml : String -> List (Html Msg)
searchHtml searchString =
    [ input
        [ class "form-control form-control-lg py-2 my-2"
        , placeholder "Search options by name or description..."
        , value searchString
        , onInput Search
        ]
        []
    ]


categoryTabsHtml : String -> List (Html Msg)
categoryTabsHtml activeCategory =
    let
        categories =
            [ ( "packages", "PACKAGES" )
            , ( "apps", "APPLICATIONS" )
            ]

        buttonItem ( value, label ) =
            button
                [ class
                    ("btn btn-lg "
                        ++ (if value == activeCategory then
                                "btn-dark"

                            else
                                "btn-secondary"
                           )
                    )
                , onClick (FilterCategory value)
                ]
                [ text label ]
    in
    List.map buttonItem categories


optionActiveState : Option -> Maybe Option -> String
optionActiveState option selectedOption =
    case selectedOption of
        Just selected ->
            if option.name == selected.name then
                " active"

            else
                " inactive"

        Nothing ->
            " inactive"


getOptionCategory : Option -> String
getOptionCategory option =
    let
        name =
            option.name
    in
    if String.startsWith "packages" name then
        "packages"

    else if String.startsWith "apps" name then
        "apps"

    else
        "other"


cleanOptionName : String -> String
cleanOptionName name =
    name
        |> String.replace "packages.*." ""
        |> String.replace "apps.*." ""


optionHtml : Option -> Maybe Option -> Html Msg
optionHtml option selectedOption =
    let
        shortDesc =
            if String.isEmpty option.description then
                "This option has no description."

            else
                option.description
                    |> String.lines
                    |> List.head
                    |> Maybe.withDefault ""
    in
    a
        [ href ("#option-" ++ option.name)
        , class
            ("list-group-item list-group-item-action flex-column align-items-start" ++ optionActiveState option selectedOption)
        , onClick (SelectOption option)
        ]
        [ div [ class "d-flex w-100 justify-content-between" ]
            [ h5 [ class "mb-1" ] [ text (cleanOptionName option.name) ]
            ]
        , p [ class "mb-1" ] [ text shortDesc ]
        , small [] [ text ("Type: " ++ option.optionType) ]
        ]


optionsHtml : List Option -> Maybe Option -> String -> String -> List (Html Msg)
optionsHtml options selectedOption filter categoryFilter =
    let
        filteredOptions =
            options
                |> List.filter
                    (\option ->
                        (String.contains (String.toLower filter) (String.toLower option.name)
                            || String.contains (String.toLower filter) (String.toLower option.description)
                        )
                            && (getOptionCategory option == categoryFilter)
                            && (option.name /= "packages")
                            && (option.name /= "apps")
                    )

        topLevelOptions =
            filteredOptions
                |> List.filter (\option -> not (String.contains "." (cleanOptionName option.name)))

        specificOptions =
            filteredOptions
                |> List.filter (\option -> String.contains "." (cleanOptionName option.name))

        -- Define sort order for option groups based on category filter
        getGroupSortOrder prefix =
            case categoryFilter of
                "packages" ->
                    case String.toLower prefix of
                        "source" ->
                            1

                        "build" ->
                            2

                        "test" ->
                            3

                        "development" ->
                            4

                        _ ->
                            99

                "apps" ->
                    case String.toLower prefix of
                        "programs" ->
                            1

                        "containers" ->
                            2

                        "vm" ->
                            3

                        _ ->
                            99

                _ ->
                    99

        -- Group specific options by their prefix (before first dot)
        groupedOptions =
            specificOptions
                |> List.foldl
                    (\option acc ->
                        let
                            prefix =
                                cleanOptionName option.name
                                    |> String.split "."
                                    |> List.head
                                    |> Maybe.withDefault ""
                        in
                        Dict.update prefix
                            (\maybeList ->
                                case maybeList of
                                    Just list ->
                                        Just (option :: list)

                                    Nothing ->
                                        Just [ option ]
                            )
                            acc
                    )
                    Dict.empty
                |> Dict.toList
                |> List.sortBy (\( prefix, _ ) -> getGroupSortOrder prefix)

        renderGroup ( prefix, groupOptions ) =
            [ div [ class "fw-bold text-muted small px-3 pt-3 pb-1" ]
                [ text (String.toUpper prefix) ]
            ]
                ++ List.map (\option -> optionHtml option selectedOption) (List.reverse groupOptions)
    in
    if List.isEmpty filteredOptions then
        [ div [ class "p-3 text-center text-muted" ]
            [ text "No options found matching your search criteria." ]
        ]

    else
        List.map (\option -> optionHtml option selectedOption) topLevelOptions
            ++ List.concatMap renderGroup groupedOptions


formatDescription : String -> List (Html Msg)
formatDescription description =
    description
        |> String.lines
        |> List.map (\line -> p [] [ text line ])


optionDetailsHtml : Option -> Html Msg
optionDetailsHtml option =
    div [ class "p-3" ]
        [ h5 [ class "text-warning" ] [ text (cleanOptionName option.name) ]
        , hr [] []
        , p [ class "mb-1 fw-bold" ] [ text "Description:" ]
        , div [] (formatDescription option.description)
        , hr [] []
        , p [ class "mb-1 fw-bold" ] [ text "Type:" ]
        , p [] [ text option.optionType ]
        , case option.default of
            Just defaultVal ->
                div []
                    [ p [ class "mb-1 fw-bold" ] [ text "Default:" ]
                    , codeBlock defaultVal.text
                    ]

            Nothing ->
                text ""
        , case option.example of
            Just exampleVal ->
                div []
                    [ p [ class "mb-1 mt-3 fw-bold" ] [ text "Example:" ]
                    , codeBlock exampleVal.text
                    ]

            Nothing ->
                text ""
        ]


codeBlock : String -> Html Msg
codeBlock content =
    div [ class "position-relative" ]
        [ button
            [ class "btn btn-sm btn-outline-secondary position-absolute top-0 end-0 m-2"
            , onClick (CopyCode content)
            ]
            [ text "Copy" ]
        , pre [ class "bg-dark text-warning p-3 rounded border border-secondary" ]
            [ code [] [ text content ] ]
        ]



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = \model -> { title = "Nix Forge - Options", body = [ view model ] }
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
