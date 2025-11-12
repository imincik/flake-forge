module Instructions exposing
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
import Html exposing (Html, a, br, button, code, div, h2, h3, hr, p, pre, span, text)
import Html.Attributes exposing (class, href, style, target, title)
import Html.Events exposing (onClick)
import Markdown
import Utils exposing (format)


codeBlock : (String -> msg) -> String -> Html msg
codeBlock onCopy content =
    div [ class "position-relative" ]
        [ button
            [ class "btn btn-sm btn-outline-secondary position-absolute top-0 end-0 m-2"
            , onClick (onCopy content)
            ]
            [ text "Copy" ]
        , pre [ class "bg-dark text-warning p-3 rounded border border-secondary" ]
            [ code [] [ text content ] ]
        ]


headerHtml : Html msg
headerHtml =
    p []
        [ span
            [ style "margin-right" "10px" ]
            [ text "[Nix Forge]" ]
        , span
            [ class "fs-2 text-secondary" ]
            [ text "the software distribution system" ]
        ]


footerHtml : Html msg
footerHtml =
    p [ class "text-center" ]
        [ span
            [ class "text-secondary fs-8" ]
            [ text "Powered by "
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
                [ text " and Elm"
                , text " . "
                ]
            , text "Developed by "
            , a
                [ href "https://github.com/imincik"
                , target "_blank"
                ]
                [ text "@imincik" ]
            , text " in "
            , a
                [ href "https://github.com/imincik/nix-forge"
                , target "_blank"
                ]
                [ text "github:imincik/nix-forge" ]
            , text " ."
            ]
        ]


installNixCmd : String
installNixCmd =
    """curl --proto '=https' --tlsv1.2 -sSf \\
    -L https://install.determinate.systems/nix \\
    | sh -s -- install
"""


acceptFlakeConfigCmd : String
acceptFlakeConfigCmd =
    """export NIX_CONFIG="accept-flake-config = true\""""


installInstructionsHtml : (String -> msg) -> List (Html msg)
installInstructionsHtml onCopy =
    [ h2 [] [ text "QUICK START" ]
    , p [ style "margin-bottom" "0em" ]
        [ text "1. Install Nix "
        , a [ href "https://zero-to-nix.com/start/install", target "_blank" ]
            [ text "(learn more about this installer)." ]
        ]
    , codeBlock onCopy installNixCmd
    , text "2. Accept binaries pre-built by Nix Forge (optional, highly recommended) "
    , codeBlock onCopy acceptFlakeConfigCmd
    , p [ style "margin-bottom" "0em" ] [ text "and select a package or application to see the usage instructions." ]
    ]


runPackageShellCmd : Package -> String
runPackageShellCmd pkg =
    format """nix shell github:imincik/nix-forge#{0}
""" [ pkg.name ]


runPackageContainerCmd : Package -> String
runPackageContainerCmd pkg =
    format """nix build github:imincik/nix-forge#{0}.image

podman load < ./result
podman run -it --rm localhost/{0}:{1}
""" [ pkg.name, pkg.version ]


enterPackageDevenvCmd : Package -> String
enterPackageDevenvCmd pkg =
    format """nix develop github:imincik/nix-forge#{0}.devenv
""" [ pkg.name ]


packageInstructionsHtml : (String -> msg) -> Package -> List (Html msg)
packageInstructionsHtml onCopy pkg =
    if not (String.isEmpty pkg.name) then
        [ h2 [] [ text pkg.name ]
        , hr [] []
        , h3 [] [ text "USAGE" ]
        , p
            [ style "margin-bottom" "0em"
            ]
            [ text "A. Run package in a shell environment" ]
        , codeBlock onCopy (runPackageShellCmd pkg)
        , p
            [ style "margin-bottom" "0em"
            ]
            [ text "B. Run package in a container" ]
        , codeBlock onCopy (runPackageContainerCmd pkg)
        , hr [] []
        , h3 [] [ text "DEVELOPMENT" ]
        , p
            [ style "margin-bottom" "0em"
            ]
            [ text "Enter development environment (all dependencies included)" ]
        , codeBlock onCopy (enterPackageDevenvCmd pkg)
        , hr [] []
        , text "Home page: "
        , a
            [ href pkg.homePage
            , target "_blank"
            ]
            [ text pkg.homePage ]
        , br [] []
        , text "Recipe : "
        , a
            [ href ("https://github.com/imincik/nix-forge/blob/master/outputs/packages/" ++ pkg.name ++ "/recipe.nix")
            , target "_blank"
            ]
            [ text ("packages/" ++ pkg.name ++ "/recipe.nix") ]
        ]

    else
        [ text "No package is selected."
        ]


runAppShellCmd : App -> String
runAppShellCmd app =
    format """nix shell github:imincik/nix-forge#{0}
""" [ app.name ]


runAppContainerCmd : App -> String
runAppContainerCmd app =
    format """nix build github:imincik/nix-forge#{0}.containers

for image in ./result/*.tar.gz; do
    podman load < $image
done

podman-compose --profile services --file $(pwd)/result/compose.yaml up
""" [ app.name ]


runAppVmCmd : App -> String
runAppVmCmd app =
    format """nix run github:imincik/nix-forge#{0}.vm
""" [ app.name ]


appInstructionsHtml : (String -> msg) -> App -> List (Html msg)
appInstructionsHtml onCopy app =
    if not (String.isEmpty app.name) then
        [ h2 [] [ text app.name ]
        , hr [] []
        , h3 [] [ text "USAGE" ]
        , if not (String.isEmpty app.usage) then
            div []
                [ Markdown.toHtml [ class "markdown-content" ] (String.trim app.usage)
                , hr [] []
                ]

          else
            text ""
        , p
            [ style "margin-bottom" "0em"
            ]
            [ text "A. Run application programs (CLI, GUI) in a shell environment" ]
        , codeBlock onCopy (runAppShellCmd app)
        , p
            [ style "margin-bottom" "0em"
            ]
            [ text "B. Run application services in containers" ]
        , codeBlock onCopy (runAppContainerCmd app)
        , if app.vm.enable then
            div []
                [ p [ style "margin-bottom" "0em" ] [ text "C. Run application services in VM" ]
                , codeBlock onCopy (runAppVmCmd app)
                ]

          else
            p [] []
        , hr [] []
        , text "Recipe: "
        , a
            [ href ("https://github.com/imincik/nix-forge/blob/master/outputs/apps/" ++ app.name ++ "/recipe.nix")
            , target "_blank"
            ]
            [ text ("apps/" ++ app.name ++ "/recipe.nix") ]
        , a
            [ href "options.html"
            , target "_blank"
            ]
            [ text " (configuration options)" ]
        ]

    else
        [ text "No application is selected."
        ]
