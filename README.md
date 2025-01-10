# actions

A collection of reusable Github Actions workflows.

### Available Actions

<!-- AUTO_GENERATE_START -->
| Name⠀⠀⠀⠀⠀⠀⠀⠀⠀| Description |
|----------------|-------------|
| `build-matrix` | Build a matrix of currently supported distros and codenames in encoded JSON list format. The list is being built out of `stage/unstable` folder of [voulage](https://github.com/regolith-linux/voulage/).  |
| `build-package` | Build a package for speficied distro/codename/stage triplet. It uses package name, package repo, and package ref to checkout the code.  |
| `ensure-sudo` | Ensure `sudo` command is installed and available.  |
| `get-voulage` | Clone and fetch [voulage](https://github.com/regolith-linux/voulage/) repository at given ref.  |
| `import-gpg` | Import given GPG private key with its associated email and full name.  |
| `publish-repo` | Publish packages of supported distro(s), codename(s), and component(s) to a new or existing archive repository.  |
| `rebuild-sources` | Rebuild the source files.  The `.dsc` and `.debian.tar.xz` files will be rebuilt out of exisiting `.orig.tar.gz` file which previously was repacked without `/debian` folder in it.  This will ensure one single .orig.tar.gz file can be used for all the packages of the same version and same component of different codenames.  |
| `setup-ssh` | Setup SSH agent and add server keyscan to the known_hosts file.  |
| `test-desktop` | Test that `regolith-desktop` is installable on a target system given public key, `apt` config line, and package(s) name (e.g. `regolith-session-sway`).  |
| `upload-files` | Upload files with given pattern from a path to the server. The target to upload files to is defined with a combination of `base` and `folder` which will be the format of `<upload-to-base>/<upload-to-folder>`.  |
<!-- AUTO_GENERATE_END -->
