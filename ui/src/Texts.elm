module Texts exposing
    ( appInstructionsHtml
    , footerHtml
    , headerHtml
    , installInstructionsHtml
    , installNixCmd
    , packageInstructionsHtml
    , runPackageContainerCmd
    , runPackageShellCmd
    )

import ConfigDecoder exposing (App, Package)
import Html exposing (Html, a, h2, h3, hr, p, pre, span, text)
import Html.Attributes exposing (class, href, style, target)


format : String -> List String -> String
format template replacements =
    let
        replace index replacement result =
            String.replace ("{" ++ String.fromInt index ++ "}") replacement result
    in
    List.indexedMap Tuple.pair replacements
        |> List.foldl (\( i, r ) acc -> replace i r acc) template


headerHtml : Html msg
headerHtml =
    p []
        [ span
            [ style "margin-right" "10px" ]
            [ text "[Flake Forge]" ]
        , span
            [ class "fs-2 text-secondary" ]
            [ text "the software distribution system" ]
        ]


footerHtml : Html msg
footerHtml =
    p [ class "text-center" ]
        [ span
            [ class "text-secondary fs-8" ]
            [ text "Developed by " ]
        , a
            [ href "https://github.com/imincik"
            , target "_blank"
            ]
            [ text "@imincik" ]
        , text " . "
        , span
            [ class "text-secondary fs-8" ]
            [ text "Powered by " ]
        , a
            [ href "https://nixos.org"
            , target "_blank"
            ]
            [ text "Nix," ]
        , a
            [ href "https://github.com/NixOS/nixpkgs"
            , target "_blank"
            ]
            [ text " Nixpkgs" ]
        , a
            [ href "https://elm-lang.org"
            , target "_blank"
            ]
            [ text " and Elm" ]
        , text " ."
        ]


installNixCmd : String
installNixCmd =
    """
curl --proto '=https' --tlsv1.2 -sSf \\
    -L https://install.determinate.systems/nix \\
    | sh -s -- install
"""


installInstructionsHtml : List (Html msg)
installInstructionsHtml =
    [ h2 [] [ text "QUICK START" ]
    , p [ style "margin-bottom" "0em" ]
        [ text "Install Nix "
        , a [ href "https://zero-to-nix.com/start/install", target "_blank" ]
            [ text "(learn more about this installer)" ]
        ]
    , pre [ class "text-warning" ] [ text installNixCmd ]
    , p [ style "margin-bottom" "0em" ] [ text "and select a package or application to see the usage instructions." ]
    ]


runPackageShellCmd : Package -> String
runPackageShellCmd pkg =
    format """
  nix shell github:imincik/flake-forge#{0}
""" [ pkg.name ]


runPackageContainerCmd : Package -> String
runPackageContainerCmd pkg =
    format """
  nix build github:imincik/flake-forge#{0}.image

  podman load < ./result
  podman run -it --rm localhost/{0}:{1}
""" [ pkg.name, pkg.version ]


enterPackageDevenvCmd : Package -> String
enterPackageDevenvCmd pkg =
    format """
  nix develop github:imincik/flake-forge#{0}.devenv
""" [ pkg.name ]


packageInstructionsHtml : Package -> List (Html msg)
packageInstructionsHtml pkg =
    if not (String.isEmpty pkg.name) then
        [ h2 [] [ text ("PACKAGE: " ++ pkg.name) ]
        , p
            [ style "margin-bottom" "0em"
            ]
            [ text "A. Run package in a shell environment" ]
        , pre [ class "text-warning" ] [ text (runPackageShellCmd pkg) ]
        , p
            [ style "margin-bottom" "0em"
            ]
            [ text "B. Run package in a container" ]
        , pre [ class "text-warning" ] [ text (runPackageContainerCmd pkg) ]
        , hr [] []
        , h3 [] [ text "DEVELOPMENT" ]
        , p
            [ style "margin-bottom" "0em"
            ]
            [ text "Enter package development environment" ]
        , pre [ class "text-warning" ] [ text (enterPackageDevenvCmd pkg) ]
        , hr [] []
        , text "Recipe: "
        , a
            [ href ("https://github.com/imincik/flake-forge/blob/master/outputs/packages/" ++ pkg.name ++ "/recipe.nix")
            , target "_blank"
            ]
            [ text ("packages/" ++ pkg.name ++ "/recipe.nix") ]
        ]

    else
        [ text "No package is selected."
        ]


runAppShellCmd : App -> String
runAppShellCmd app =
    format """
  nix shell github:imincik/flake-forge#{0}.programs
""" [ app.name ]


runAppContainerCmd : App -> String
runAppContainerCmd app =
    format """
  nix build github:imincik/flake-forge#{0}

  for image in ./result/*.tar.gz; do
    podman load < $image
  done

  podman-compose --profile services --file $(pwd)/result/compose.yaml up
""" [ app.name ]


runAppVmCmd : App -> String
runAppVmCmd app =
    format """
  nix run github:imincik/flake-forge#{0}.vm
""" [ app.name ]


appInstructionsHtml : App -> List (Html msg)
appInstructionsHtml app =
    if not (String.isEmpty app.name) then
        [ h2 [] [ text ("APP: " ++ app.name) ]
        , p
            [ style "margin-bottom" "0em"
            ]
            [ text "A. Run application programs (CLI, GUI) in a shell environment", pre [ class "text-warning" ] [ text (runAppShellCmd app) ] ]
        , p
            [ style "margin-bottom" "0em"
            ]
            [ text "B. Run application services in containers", pre [ class "text-warning" ] [ text (runAppContainerCmd app) ] ]
        , if app.vm.enable then
            p
                [ style "margin-bottom" "0em" ]
                [ text "C. Run application services in VM", pre [ class "text-warning" ] [ text (runAppVmCmd app) ] ]

          else
            p [] []
        , hr [] []
        , text "Recipe: "
        , a
            [ href ("https://github.com/imincik/flake-forge/blob/master/outputs/apps/" ++ app.name ++ "/recipe.nix")
            , target "_blank"
            ]
            [ text ("apps/" ++ app.name ++ "/recipe.nix") ]
        ]

    else
        [ text "No application is selected."
        ]
