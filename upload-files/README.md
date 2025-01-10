<!-- AUTO_GENERATE_START -->
# Upload Files

Upload files with given pattern from a path to the server. The target to upload
files to is defined with a combination of `base` and `folder` which will be the
format of `<upload-to-base>/<upload-to-folder>`.
<!-- AUTO_GENERATE_END -->

## Usage

```yaml
- uses: regolith-linux/actions/upload-files@main
  env:
    # server-address is the IP address or FQDN of the server.
    #
    # Required.
    server-address: "..."

    # server-username is the server ssh username.
    #
    # Required.
    server-username: "..."
  with:
    # upload-from is the path on disk to upload files from.
    #
    # Required.
    upload-from: "/build/publish/"

    # upload-pattern is the file pattern to use to upload from.
    #
    # Required.
    upload-pattern: "*"

    # upload-to-base is the base path on the server to upload to.
    #
    # Required.
    upload-to-base: "/opt/archives/packages/"

    # upload-to-folder is the name of the folder to upload into in 'upload-to-base'.
    #
    # Required.
    upload-to-folder: "..."
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
        id: build
        uses: regolith-linux/actions/build-package@main
        with:
          name: "foo-package"
          distro: "ubuntu"
          codename: "noble"
          stage: "unstable"
          suite: "unstable"
          component: "main"
          arch: "amd64"

      - name: Upload Files
        uses: regolith-linux/actions/upload-files@main
        env:
          server-address: "${{ secrets.SERVER_IP_ADDRESS }}"
          server-username: "${{ secrets.SERVER_SSH_USER }}"
        with:
          upload-from: "${{ steps.build.outputs.publish-path }}"
          upload-to-folder: "foo-package"
```
