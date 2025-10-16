## perSystem



This option has no description\.



*Type:*
module

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## packages



List of packages\.



*Type:*
list of (submodule)



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.plainBuilder\.enable



Whether to enable Plain builder\.
\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.plainBuilder\.build



This option has no description\.



*Type:*
string



*Default:*
` "echo 'Build phase'" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.plainBuilder\.check



This option has no description\.



*Type:*
string



*Default:*
` "echo 'Check phase'" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.plainBuilder\.configure



This option has no description\.



*Type:*
string



*Default:*
` "echo 'Configure phase'" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.plainBuilder\.debug



Enable interactive package build environment for
debugging\.

Launch environment:

```
mkdir dev && cd dev
nix develop .#<package>
```

and follow instructions\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.plainBuilder\.install



This option has no description\.



*Type:*
string



*Default:*
` "echo 'Install phase'" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.plainBuilder\.requirements\.build



This option has no description\.



*Type:*
list of package



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.plainBuilder\.requirements\.native



This option has no description\.



*Type:*
list of package



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.pythonAppBuilder\.enable



Whether to enable Python application builder\.
\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.pythonAppBuilder\.debug



Enable interactive package build environment for
debugging\.

Launch environment:

```
mkdir dev && cd dev
nix develop .#<package>
```

and follow instructions\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.pythonAppBuilder\.extraDrvAttrs



Expert option\.

Set extra Nix derivation attributes\.



*Type:*
attribute set of anything



*Default:*
` { } `



*Example:*

```
{
  preConfigure = "export HOME=$(mktemp -d)"
  postInstall = "rm $out/somefile.txt"
}

```

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.pythonAppBuilder\.requirements\.build-system



This option has no description\.



*Type:*
list of package



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.pythonAppBuilder\.requirements\.dependencies



This option has no description\.



*Type:*
list of package



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.standardBuilder\.enable



Whether to enable Standard builder\.
\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.standardBuilder\.debug



Enable interactive package build environment for
debugging\.

Launch environment:

```
mkdir dev && cd dev
nix develop .#<package>
```

and follow instructions\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.standardBuilder\.extraDrvAttrs



Expert option\.

Set extra Nix derivation attributes\.



*Type:*
attribute set of anything



*Default:*
` { } `



*Example:*

```
{
  preConfigure = "export HOME=$(mktemp -d)"
  postInstall = "rm $out/somefile.txt"
}

```

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.standardBuilder\.requirements\.build



This option has no description\.



*Type:*
list of package



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.build\.standardBuilder\.requirements\.native



This option has no description\.



*Type:*
list of package



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.description



This option has no description\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.development\.requirements



This option has no description\.



*Type:*
list of package



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.development\.shellHook



This option has no description\.



*Type:*
string



*Default:*

```
''
  echo -e "\nWelcome. This environment contains all dependencies required"
  echo "to build this software from source."
  echo
  echo "Now, navigate to the source code directory and you are all set to"
  echo "start hacking."
''
```

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.homePage



This option has no description\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.mainProgram



This option has no description\.



*Type:*
string



*Default:*
` "my-program" `



*Example:*
` "hello" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.name



This option has no description\.



*Type:*
string



*Default:*
` "my-package" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.source\.git



This option has no description\.



*Type:*
null or string matching the pattern ^\.\*:\.\*/\.\*/\.\*$



*Default:*
` null `



*Example:*
` "my-user/my-repo/v1.0.0" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.source\.hash



This option has no description\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.source\.url



This option has no description\.



*Type:*
null or string matching the pattern ^\.\*://\.\*



*Default:*
` null `



*Example:*
` "https://downloads.my-project/my-package-1.0.0.tar.gz" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.test\.requirements



This option has no description\.



*Type:*
list of package



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.test\.script



This option has no description\.



*Type:*
string



*Default:*

```
''
  echo "Test script"
''
```

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## packages\.\*\.version



This option has no description\.



*Type:*
string



*Default:*
` "1.0.0" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/packages.nix)



## apps

List of apps\.



*Type:*
list of (submodule)



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.containers\.composeFile



Relative path to a container compose file\.



*Type:*
absolute path



*Example:*
` "./compose.yaml" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.containers\.images



This option has no description\.



*Type:*
list of (submodule)

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.containers\.images\.\*\.config\.CMD



This option has no description\.



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.containers\.images\.\*\.name



This option has no description\.



*Type:*
string



*Default:*
` "app-container" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.containers\.images\.\*\.requirements



This option has no description\.



*Type:*
list of package



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.description



This option has no description\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.name



This option has no description\.



*Type:*
string



*Default:*
` "my-package" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.programs\.requirements



This option has no description\.



*Type:*
list of package



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.version



This option has no description\.



*Type:*
string



*Default:*
` "1.0.0" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.vm\.enable



Whether to enable Virtual machine\.
\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.vm\.config\.ports



List of ports to forward from host system to VM\.

Format: HOST_PORT:VM_PORT



*Type:*
list of string matching the pattern ^\[0-9]\*:\[0-9]\*$



*Default:*
` [ ] `



*Example:*

```
[ "10022:22" "5432:5432" "8000:90" ]

```

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.vm\.config\.system



NixOS system configuration\.

See: https://search\.nixos\.org/options



*Type:*
attribute set of anything



*Default:*
` { } `



*Example:*

```
{
  services.postgresql.enabled = true;
}

```

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.vm\.name



This option has no description\.



*Type:*
string



*Default:*
` "nixos-vm" `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)



## apps\.\*\.vm\.requirements



This option has no description\.



*Type:*
list of package



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps\.nix](file:///nix/store/x4pmp3mkhcy6zizla20ffb8a9w99193v-source/forge/modules/apps.nix)


