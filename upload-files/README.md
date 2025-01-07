# Upload Packages

Upload debian package and source files to the publish server.

## Usage

```yaml
- uses: regolith-linux/actions/upload-files@main
  with:
    # server-address is the IP address of the publish server.
    #
    # Required.
    server-address: "..."

    # server-username is the server SSH username.
    #
    # Required.
    server-username: "..."

    # server-ssh-key is the server SSH private key.
    #
    # Required.
    server-ssh-key: "..."

    # source-path is the path on disk to upload packages from.
    #
    # Required.
    source-path: "..."

    # packages-path is the path on disk that contains the packages.
    #
    # Required.
    packages-path: "/opt/archives/packages/"

    # package-name is the name of the folder to be created in 'packages-path'.
    #
    # Required.
    package-name: "..."
```

## Scenarios

```yaml
jobs:
  build:
    runs-on: ubuntu-24.04
    container: "ubuntu:noble"
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Build Package
        uses: regolith-linux/actions/build-package@main
        with:
          name: "foo-package"
          distro: "ubuntu"
          codename: "noble"
          stage: "unstable"
          suite: "unstable"
          component: "main"
          arch: "amd64"
          gpg-key: "${{ secrets.GPG_PRIVATE_KEY }}"

      - name: Upload Files
        uses: regolith-linux/actions/upload-files@main
        with:
          server-address: "${{ secrets.SERVER_IP_ADDRESS }}"
          server-user: "${{ secrets.SERVER_SSH_USER }}"
          package-name: "foo-package"
```
