port module OptionsMain exposing (main)

import Browser
import Dict
import Html exposing (Html, a, button, code, div, h5, hr, input, p, pre, small, span, text)
import Html.Attributes exposing (class, href, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http
import OptionsDecoder exposing (Option, OptionsData, optionsDecoder)



-- PORTS


port copyToClipboard : String -> Cmd msg



-- MODEL


type alias Model =
    { options : List Option
    , selectedOption : Maybe Option
    , searchString : String
    , categoryFilter : String
    , error : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { options = []
      , selectedOption = Nothing
      , searchString = ""
      , categoryFilter = "packages"
      , error = Nothing
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetOptions (Ok optionsData) ->
            let
                optionsList =
                    Dict.values optionsData
                        |> List.sortBy .name
            in
            ( { model | options = optionsList, error = Nothing }, Cmd.none )

        GetOptions (Err err) ->
            ( { model | error = Just (httpErrorToString err) }, Cmd.none )

        SelectOption option ->
            ( { model | selectedOption = Just option }, Cmd.none )

        Search string ->
            ( { model | searchString = string }, Cmd.none )

        FilterCategory category ->
            ( { model | categoryFilter = category }, Cmd.none )

        CopyCode code ->
            ( model, copyToClipboard code )



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


getBadgeText : String -> String
getBadgeText name =
    let
        cleanedName =
            cleanOptionName name
    in
    if String.contains "." cleanedName then
        cleanedName
            |> String.split "."
            |> List.head
            |> Maybe.withDefault ""

    else
        "toplevel"


optionHtml : Option -> Maybe Option -> Html Msg
optionHtml option selectedOption =
    let
        shortDesc =
            if String.length option.description > 100 then
                String.left 100 option.description ++ "..."

            else if String.isEmpty option.description then
                "This option has no description."

            else
                option.description

        badgeText =
            getBadgeText option.name
    in
    a
        [ href ("#option-" ++ option.name)
        , class
            ("list-group-item list-group-item-action flex-column align-items-start" ++ optionActiveState option selectedOption)
        , onClick (SelectOption option)
        ]
        [ div [ class "d-flex w-100 justify-content-between" ]
            [ h5 [ class "mb-1" ] [ text (cleanOptionName option.name) ]
            , small [] [ span [ class "badge bg-secondary" ] [ text badgeText ] ]
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
    in
    if List.isEmpty filteredOptions then
        [ div [ class "p-3 text-center text-muted" ]
            [ text "No options found matching your search criteria." ]
        ]

    else
        (if not (List.isEmpty topLevelOptions) then
            [ div [ class "fw-bold text-muted small px-3 pt-3 pb-1" ] [ text "TOP LEVEL OPTIONS" ] ]
                ++ List.map (\option -> optionHtml option selectedOption) topLevelOptions

         else
            []
        )
            ++ (if not (List.isEmpty specificOptions) then
                    [ div [ class "fw-bold text-muted small px-3 pt-3 pb-1" ] [ text "SPECIFIC OPTIONS" ] ]
                        ++ List.map (\option -> optionHtml option selectedOption) specificOptions

                else
                    []
               )


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
            [ class "btn btn-sm btn-outline-light position-absolute top-0 end-0 m-2"
            , onClick (CopyCode content)
            ]
            [ text "Copy" ]
        , pre [ class "bg-dark text-warning p-3 rounded border" ]
            [ code [] [ text content ] ]
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
