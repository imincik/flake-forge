module Texts exposing
    ( aboutText
    , clickOnPackageText
    , installNixCmd
    , installNixText
    , runContainerCmd
    , runInContainerComment
    , runInShellCmd
    , runInShellComment
    )

import Html exposing (Html, a, text)
import Html.Attributes exposing (href, target)


aboutText : String
aboutText =
    """
Friendly, self hosted software build system and repository.
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
and select a package to show usage instructions.
"""


runInShellComment : String
runInShellComment =
    """
1. Run package in a temporary shell environment
"""


runInShellCmd : String -> String
runInShellCmd pkg =
    """
nix shell github:imincik/flake-forge#"""
        ++ pkg
        ++ """

<PROGRAM-TO-RUN>
"""

runInContainerComment : String
runInContainerComment =
    """
2. Run package in a container
"""


runContainerCmd : String -> String
runContainerCmd pkg =
    """
nix build github:imincik/flake-forge#"""
        ++ pkg
        ++ """.passthru.container-image"""
        ++ """

podman load < ./result
"""
        ++ "podman run -it localhost/"
        ++ pkg
        ++ "-image:latest"
