module Texts exposing
    ( footerHtml
    , headerHtml
    , installInstructionsHtml
    , installNixCmd
    , packageInstructionsHtml
    , runContainerCmd
    , runInShellCmd
    , runPackageCmd
    )

import ConfigDecoder exposing (Package)
import Html exposing (Html, a, h2, hr, p, pre, span, text)
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
    [ h2 [] [ text "ABOUT" ]
    , p [] [ text "Friendly, self hosted software distribution system." ]
    , h2 [] [ text "QUICK START" ]
    , p [ style "margin-bottom" "0em" ]
        [ text "Install Nix "
        , a [ href "https://zero-to-nix.com/start/install", target "_blank" ]
            [ text "(learn more about this installer)" ]
        ]
    , pre [ class "text-warning" ] [ text installNixCmd ]
    , p [ style "margin-bottom" "0em" ] [ text "and select a package to see how to use it." ]
    ]


runPackageCmd : Package -> String
runPackageCmd pkg =
    format """
  nix run github:imincik/flake-forge#{0}
""" [ pkg.name ]


runInShellCmd : Package -> String
runInShellCmd pkg =
    format """
  nix shell github:imincik/flake-forge#{0}

  {1}
""" [ pkg.name, pkg.mainProgram ]


runContainerCmd : Package -> String
runContainerCmd pkg =
    format """
  nix build github:imincik/flake-forge#{0}.passthru.image

  podman load < ./result
  podman run -it --rm localhost/{0}:{1}
""" [ pkg.name, pkg.version ]


packageInstructionsHtml : Package -> List (Html msg)
packageInstructionsHtml pkg =
    [ h2 [] [ text ("PACKAGE: " ++ pkg.name) ]
    , p
        [ style "margin-bottom" "0em"
        ]
        [ text "1. Run package (main program)" ]
    , pre [ class "text-warning" ] [ text (runPackageCmd pkg) ]
    , p
        [ style "margin-bottom" "0em"
        ]
        [ text "2. Run package in a temporary shell environment" ]
    , pre [ class "text-warning" ] [ text (runInShellCmd pkg) ]
    , p
        [ style "margin-bottom" "0em"
        ]
        [ text "3. Run package in a container" ]
    , pre [ class "text-warning" ] [ text (runContainerCmd pkg) ]
    , hr [] []
    , text "Recipe: "
    , a
        [ href ("https://github.com/imincik/flake-forge/blob/master/outputs/packages/" ++ pkg.name ++ "/recipe.nix")
        , target "_blank"
        ]
        [ text (pkg.name ++ "/recipe.nix") ]
    ]
