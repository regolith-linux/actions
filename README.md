# actions

A collection of reusable Github Actions workflows.

### Available Actions

<!-- AUTO_GENERATE_START -->
| Name⠀⠀⠀⠀⠀⠀⠀⠀| Description |
|---------------|-------------|
| `build-matrix` | Build a matrix of currently supported distros and codenames in encoded JSON list format. The list is being built out of `stage/unstable` folder of voulage repository at https://github.com/regolith-linux/voulage/.   |
| `build-package` | Build a package for speficied distro/codename/stage triplet. It uses package name, package repo, and package ref to checkout the code.   |
| `ensure-sudo` | Ensure sudo command is installed and available.   |
| `get-voulage` | Clone and fetch https://github.com/regolith-linux/voulage/ repository at given ref.   |
| `import-gpg` | Import given GPG private key with its associated email and full name.   |
| `publish-repo` | Publish packages of supported distro(s), codename(s), and component(s) to a new or existing archive repository.   |
| `test-desktop` | Test that regolith-desktop is installable on a target system given public key, apt config line, and package(s) name (e.g. `regolith-session-sway`).   |
<!-- AUTO_GENERATE_END -->
