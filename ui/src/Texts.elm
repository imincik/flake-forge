module Texts exposing
    ( aboutText
    , clickOnPackageText
    , installNixCmd
    , installNixText
    , runContainerCmd
    , runInContainerComment
    , runInShellCmd
    , runInShellComment
    , runPackageCmd
    , runPackageComment
    )

import ConfigDecoder exposing (Package)
import Html exposing (Html, a, text)
import Html.Attributes exposing (href, target)


format : String -> List String -> String
format template replacements =
    let
        replace index replacement result =
            String.replace ("{" ++ String.fromInt index ++ "}") replacement result
    in
    List.indexedMap Tuple.pair replacements
        |> List.foldl (\( i, r ) acc -> replace i r acc) template


aboutText : String
aboutText =
    """
Friendly, self hosted software distribution system.
"""


installNixText : List (Html msg)
installNixText =
    [ text "Install Nix "
    , a [ href "https://zero-to-nix.com/start/install", target "_blank" ]
        [ text "(learn more about this installer)" ]
    ]


installNixCmd : String
installNixCmd =
    """
curl --proto '=https' --tlsv1.2 -sSf \\
    -L https://install.determinate.systems/nix \\
    | sh -s -- install
"""


clickOnPackageText : String
clickOnPackageText =
    """
and select a package to see how to use it.
"""


runPackageComment : String
runPackageComment =
    """
1. Run package (main program)
"""


runPackageCmd : Package -> String
runPackageCmd pkg =
    format """
  nix run github:imincik/flake-forge#{0}
""" [ pkg.name ]


runInShellComment : String
runInShellComment =
    """
2. Run package in a temporary shell environment
"""


runInShellCmd : Package -> String
runInShellCmd pkg =
    format """
  nix shell github:imincik/flake-forge#{0}
  {1}
""" [ pkg.name, pkg.mainProgram ]


runInContainerComment : String
runInContainerComment =
    """
3. Run package in a container
"""


runContainerCmd : Package -> String
runContainerCmd pkg =
    format """
  nix build github:imincik/flake-forge#{0}.passthru.container-image

  podman load < ./result
  podman run -it localhost/{0}-image:latest
""" [ pkg.name ]
