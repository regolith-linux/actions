<!-- AUTO_GENERATE_START -->
# Rebuild Sources

Rebuild the source files.

The `.dsc` and `.debian.tar.xz` files will be rebuilt out of exisiting `.orig.tar.gz`
file which previously was repacked without `/debian` folder in it.

This will ensure one single .orig.tar.gz file can be used for all the packages of the
same version and same component of different codenames.
<!-- AUTO_GENERATE_END -->

## Usage

```yaml
- uses: regolith-linux/actions/rebuild-sources@main
  with:
    # pull-from-base is the base path on the server to pull packages from.
    #
    # Required.
    pull-from-base: "/opt/archives/workspace/"

    # push-to-base is the base path on the server to push rebuils sources to.
    #
    # Required.
    push-to-base: "/opt/archives/packages/"

    # workspace-subfolder is the name of the folder to use inside 'pull-from-base' and 'push-to-base'.
    #
    # Required.
    workspace-subfolder: "..."
    
    # only-distro is a filter to only publish repository for this distro.
    only-distro: "..."
    
    # only-codename is a filter to only publish repository for this codename.
    only-codename: "..."
    
    # only-component is a filter to only publish repository for this component.
    only-component: "..."

    # only-package is a filter to only rebuild sources for this package.
    only-package: "..."

    # gpg-email is the email ID associated with the GPG Key.
    #
    # Required.
    gpg-email: "regolith.linux@gmail.com"

    # gpg-name is the full name associated with the GPG Key.
    #
    # Required.
    gpg-name: "Regolith Linux"

    # server-address is the IP address of the publish server.
    #
    # Required.
    server-address: "..."
    
    # server-user is the server ssh username.
    #
    # Required.
    server-user: "..."
```

## Scenarios

```yaml
jobs:
  build:
    runs-on: ubuntu-24.04
    container: "ubuntu:noble"
    steps:
      - name: Import GPG Key
        uses: regolith-linux/actions/import-gpg@main
        with:
          gpg-key: "${{ secrets.PACKAGE_PRIVATE_KEY2 }}"

      - name: Setup SSH
        uses: regolith-linux/actions/setup-ssh@main
        with:
          ssh-host: "${{ secrets.KAMATERA_HOSTNAME2 }}"
          ssh-key: "${{ secrets.KAMATERA_SSH_KEY }}"

      - name: Rebuild Sources
        uses: regolith-linux/actions/rebuild-sources@main
        with:
          package-name: "foo-package"
          only-component: "unstable"
          only-package: "foo-package"
          server-address: "${{ secrets.SERVER_IP_ADDRESS }}"
          server-username: "${{ secrets.SERVER_SSH_USER }}"
```
