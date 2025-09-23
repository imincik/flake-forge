module Texts exposing
    ( aboutText
    , buildContainerImageCmd
    , clickOnPackageText
    , installNixCmd
    , installNixText
    , runContainerCmd
    , runInContainerComment
    , runInShellComment
    , runInShellCmd
    )

import Html exposing (a, text)
import Html.Attributes exposing (href, target)


aboutText =
    """
Friendly, self hosted software build system and repository.
"""


installNixText =
    [ text "Install Nix "
    , a [ href "https://zero-to-nix.com/start/install", target "_blank" ]
        [ text "(learn more about this installer)" ]
    ]


installNixCmd =
    """
curl --proto '=https' --tlsv1.2 -sSf \\
    -L https://install.determinate.systems/nix \\
    | sh -s -- install
"""


clickOnPackageText =
    """
and select a package to show usage instructions.
"""


runInShellComment =
    """
1. Run package in a temporary shell environment
"""


runInShellCmd =
    """
nix shell github:imincik/flake-forge#<s>

<PROGRAM-TO-RUN>
"""


runInContainerComment =
    """
2. Run package in a container
"""


buildContainerImageCmd =
    """
nix build github:imincik/flake-forge#<s>.passthru.container-image
"""


runContainerCmd =
    """podman load < ./result
podman run -it localhost/<s>-image:latest
"""
