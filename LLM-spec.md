# Nix Forge Recipe Generation Specification for LLMs

## Overview

This specification guides LLMs in generating Nix Forge recipes - declarative configuration files for building software packages and applications.

## Recipe File Structure

### Location
- **Packages**: `outputs/packages/<package-name>/recipe.nix`
- **Apps**: `outputs/apps/<app-name>/recipe.nix`

### Basic Template
```nix
{ config, lib, pkgs, mypkgs, ... }:

{
  # Recipe fields go here
}
```

**Note**: The function parameters are REQUIRED and should always be included, even if not used.

### Important: Git Tracking Required

**CRITICAL**: All new recipe files MUST be added to git before they can be used by the Nix flake system.

After creating a new recipe file, you must run:
```bash
git add outputs/packages/<package-name>/recipe.nix
# or for apps:
git add outputs/apps/<app-name>/recipe.nix
```

The flake uses `import-tree` to automatically discover recipes, but it only sees files tracked by git. Without adding the file to git, the package will not be recognized and `nix build .#<package-name>` will fail with an error like:
```
error: flake does not provide attribute 'packages.x86_64-linux.<package-name>'
```

## Package Recipes

### Required Fields
```nix
{
  name = "package-name";           # String, lowercase with hyphens
  version = "1.0.0";               # String, semantic versioning
  description = "Short description of the package.";

  # Source: EXACTLY ONE of these must be defined
  source.git = "github:owner/repo/commit-or-tag";  # OR
  source.url = "https://...";
  source.hash = "sha256-...";      # Required with url, optional with git

  # Builder: EXACTLY ONE must be enabled
  build.plainBuilder.enable = true;      # OR
  build.standardBuilder.enable = true;   # OR
  build.pythonAppBuilder.enable = true;
}
```

### Optional but Recommended Fields
```nix
{
  homePage = "https://project-website.org";
  mainProgram = "executable-name";  # Main binary name for the package
}
```

## Builder Types

### 1. standardBuilder (Most Common)
**When to use**: Standard autotools/cmake/make-based projects

```nix
{
  build.standardBuilder = {
    enable = true;
    requirements = {
      native = [ pkgs.cmake pkgs.pkg-config ];  # Build-time tools
      build = [ pkgs.openssl pkgs.zlib ];       # Runtime dependencies
    };
  };
}
```

**Characteristics**:
- Automatic configure, build, install phases
- Follows standard build conventions
- Use for: C/C++ projects with configure scripts or CMake

### 2. plainBuilder (Custom Build)
**When to use**: Non-standard build processes requiring custom phases

```nix
{
  build.plainBuilder = {
    enable = true;
    requirements = {
      native = [ pkgs.cmake ];
      build = [ pkgs.somelib ];
    };
    configure = ''
      mkdir build && cd build
      cmake -DCMAKE_INSTALL_PREFIX=$out ..
    '';
    build = ''
      make -j $NIX_BUILD_CORES
    '';
    check = ''
      make test
    '';
    install = ''
      make install
    '';
  };
}
```

**When to use**:
- Custom build steps needed
- Non-standard directory structure
- Special environment setup required

### 3. pythonAppBuilder (Python Applications)
**When to use**: Python applications with pyproject.toml

```nix
{
  build.pythonAppBuilder = {
    enable = true;
    requirements = {
      build-system = [ pkgs.python3Packages.setuptools ];
      dependencies = [
        pkgs.python3Packages.flask
        pkgs.python3Packages.requests
      ];
    };
  };
}
```

**Note**: Use pkgs.python3Packages.* for Python dependencies

## Source Configuration

### Git Sources
**Format**: `forge:owner/repository/revision`

```nix
source = {
  git = "github:torvalds/linux/v6.1";  # Tag
  git = "gitlab:group/project/abc123";  # Commit hash
  hash = "sha256-...";  # Optional but recommended
};
```

**Supported forges**: github, gitlab

### URL Sources
```nix
source = {
  url = "https://releases.example.com/package-1.0.0.tar.gz";
  url = "mirror://gnu/hello/hello-2.12.1.tar.gz";  # Nix mirrors
  hash = "sha256-...";  # REQUIRED
};
```

## Test Configuration

```nix
test = {
  requirements = [ pkgs.curl ];  # Additional test dependencies
  script = ''
    # Test commands
    $out/bin/program --version
    $out/bin/program --help
  '';
};
```

**Best practices**:
- Test main functionality
- Verify version output
- Check help/usage works
- Keep tests fast (< 10 seconds)

## Development Environment

```nix
development = {
  requirements = [ pkgs.gdb pkgs.valgrind ];  # Dev tools
  shellHook = ''
    echo "Development environment ready"
    echo "Source code: clone from ${source.git}"
  '';
};
```

## Advanced: extraDrvAttrs

For expert-level customization:

```nix
build.extraDrvAttrs = {
  preConfigure = ''
    export HOME=$(mktemp -d)
  '';
  postInstall = ''
    wrapProgram $out/bin/program \
      --set SOME_VAR value
  '';
  enableParallelBuilding = true;
};
```

**Common use cases**:
- `preConfigure`: Set environment before configure
- `postInstall`: Wrap binaries, add extra files
- `patches`: Apply source patches
- `configureFlags`: Pass flags to configure script

## Application Recipes

### Structure
```nix
{
  name = "app-name";
  version = "1.0.0";
  description = "Application description.";
  usage = "Usage instructions in markdown...";  # Optional but helpful

  # Choose output types:
  programs = { ... };    # Shell bundle
  containers = { ... };  # Docker containers
  vm = { ... };         # NixOS VM
}
```

### Programs (Shell Bundle)
```nix
programs = {
  requirements = [
    mypkgs.my-package  # Reference packages from forge
    pkgs.curl
  ];
};
```

### Containers
```nix
containers = {
  images = [
    {
      name = "api-server";
      requirements = [ mypkgs.my-package ];
      config.CMD = [ "my-package" "--serve" ];
    }
  ];
  composeFile = ./compose.yaml;  # Optional
};
```

### Virtual Machine
```nix
vm = {
  enable = true;
  name = "my-vm";
  requirements = [ mypkgs.my-package ];
  config = {
    ports = [ "8080:8080" ];
    system = {
      services.postgresql.enable = true;
      systemd.services.my-service = {
        script = "${mypkgs.my-package}/bin/my-package";
        wantedBy = [ "multi-user.target" ];
      };
    };
  };
};
```

## LLM Generation Guidelines

### 1. Information Gathering
Before generating a recipe, determine:
- **Software name and version**
- **Programming language/build system**
- **Source location** (GitHub URL, release tarball)
- **Build dependencies** (libraries, tools)
- **Runtime dependencies**
- **Main executable name**

### 2. Builder Selection Logic
```
IF Python project with pyproject.toml:
  → pythonAppBuilder

ELSE IF has configure script OR uses CMake OR standard Makefile:
  → standardBuilder

ELSE IF custom build process:
  → plainBuilder
```

### 3. Dependency Resolution
- **Build tools**: cmake, pkg-config, autoconf → `requirements.native`
- **Libraries**: openssl, zlib, curl → `requirements.build`
- **Python packages**: Use `pkgs.python3Packages.*`
- **Unknown packages**: Use `pkgs.<package-name>`

### 4. Hash Determination
When hash is unknown:
```nix
source.hash = "";  # Leave empty initially
# Nix will error with correct hash, then update recipe
```

### 5. Validation Checklist
- [ ] Exactly one builder enabled
- [ ] Source has git XOR url (not both)
- [ ] Hash present for URL sources
- [ ] name is lowercase-with-hyphens
- [ ] mainProgram matches actual executable
- [ ] Test script tests main functionality
- [ ] No hardcoded /nix/store paths

## Common Patterns

### Pattern 1: Simple GitHub Project
```nix
{ config, lib, pkgs, mypkgs, ... }:

{
  name = "ripgrep";
  version = "14.0.0";
  description = "Fast line-oriented search tool.";
  homePage = "https://github.com/BurntSushi/ripgrep";
  mainProgram = "rg";

  source = {
    git = "github:BurntSushi/ripgrep/14.0.0";
    hash = "sha256-...";
  };

  build.standardBuilder = {
    enable = true;
    requirements = {
      native = [ pkgs.rustc pkgs.cargo ];
      build = [ ];
    };
  };

  test.script = ''
    rg --version | grep "14.0.0"
  '';
}
```

### Pattern 2: C Project with Dependencies
```nix
{ config, lib, pkgs, mypkgs, ... }:

{
  name = "nginx";
  version = "1.24.0";
  description = "HTTP and reverse proxy server.";
  homePage = "https://nginx.org";
  mainProgram = "nginx";

  source = {
    url = "https://nginx.org/download/nginx-1.24.0.tar.gz";
    hash = "sha256-...";
  };

  build.standardBuilder = {
    enable = true;
    requirements = {
      native = [ pkgs.which ];
      build = [ pkgs.openssl pkgs.pcre pkgs.zlib ];
    };
  };

  test.script = ''
    nginx -v 2>&1 | grep "1.24.0"
  '';
}
```

### Pattern 3: Python Application
```nix
{ config, lib, pkgs, mypkgs, ... }:

{
  name = "mypy";
  version = "1.7.0";
  description = "Static type checker for Python.";
  homePage = "https://mypy-lang.org";
  mainProgram = "mypy";

  source = {
    git = "github:python/mypy/v1.7.0";
    hash = "sha256-...";
  };

  build.pythonAppBuilder = {
    enable = true;
    requirements = {
      build-system = [ pkgs.python3Packages.setuptools ];
      dependencies = [
        pkgs.python3Packages.typing-extensions
        pkgs.python3Packages.mypy-extensions
      ];
    };
  };

  test.script = ''
    mypy --version | grep "1.7.0"
  '';
}
```

## Error Handling

### Common Issues and Solutions

**Issue**: "source.git or source.url must be defined"
- **Solution**: Ensure exactly one source method is specified

**Issue**: "Only one builder can be enabled"
- **Solution**: Set only one `build.*.enable = true`

**Issue**: Hash mismatch
- **Solution**: Update hash with value from error message

**Issue**: Missing dependency
- **Solution**: Add to requirements.native or requirements.build

## Naming Conventions

- **Package names**: lowercase-with-hyphens (e.g., `my-package`)
- **Versions**: Semantic versioning (e.g., `1.2.3`, `2024-01-15`)
- **File paths**: Use `./` for relative paths (e.g., `./compose.yaml`)
- **Programs**: Binary name, not display name (e.g., `rg` not `ripgrep`)

## Summary for LLMs

When generating a Nix Forge recipe:
1. **Identify** the software and gather information
2. **Choose** appropriate builder based on build system
3. **Define** source (git or url with hash)
4. **List** all dependencies in correct categories
5. **Write** meaningful test script
6. **Validate** against checklist
7. **Format** consistently with examples

The goal is a **declarative, reproducible, and testable** package definition that abstracts Nix complexity while maintaining flexibility.
