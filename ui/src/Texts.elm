module Texts exposing
    ( aboutText
    , clickOnPackageText
    , installNixTemplate
    , installNixTemplateComment
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
and select a package to show a usage instructions.
"""
