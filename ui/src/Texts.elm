module Texts exposing
    ( aboutText
    , buildContainerImageTemplate
    , clickOnPackageText
    , installNixTemplate
    , installNixTemplateComment
    , runContainerTemplate
    , runPackageInContainerComment
    , runPackageInShellComment
    , runPackageInShellTemplate
    )

import Html exposing (a, text)
import Html.Attributes exposing (href, target)


aboutText =
    """
Friendly, self hosted software build system and repository.
"""


installNixTemplateComment =
    [ text "Install Nix "
    , a [ href "https://zero-to-nix.com/start/install", target "_blank" ]
        [ text "(learn more about this installer)" ]
    ]


installNixTemplate =
    """
curl --proto '=https' --tlsv1.2 -sSf \\
    -L https://install.determinate.systems/nix \\
    | sh -s -- install
"""


clickOnPackageText =
    """
and select a package to show usage instructions.
"""


runPackageInShellComment =
    """
1. Run package in a temporary shell environment
"""


runPackageInShellTemplate =
    """
nix shell github:imincik/flake-forge#<s>

<PROGRAM-TO-RUN>
"""


runPackageInContainerComment =
    """
2. Run package in a container
"""


buildContainerImageTemplate =
    """
nix build github:imincik/flake-forge#<s>.container.image
"""


runContainerTemplate =
    """podman load < ./result
podman run TODO
"""
