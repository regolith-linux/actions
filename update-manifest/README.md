<!-- AUTO_GENERATE_START -->
# Update Manifest

Update and upload the manifest file for the package that is just built with
package name, repo, ref, and sha.
<!-- AUTO_GENERATE_END -->

## Usage

```yaml
- uses: regolith-linux/actions/update-manifest@main
  env:
    # server-address is the IP address of the publish server.
    #
    # Required.
    server-address: "..."

    # server-username is the server SSH username.
    #
    # Required.
    server-username: "..."
  with:
    # name of the package to update the manifest for.
    #
    # Required.
    name: "..."

    # repo is the public git repository URL of the package
    #
    # Required.
    repo: "..."

    # ref is Git repository ref that the package was built at (e.g. branch, tag, or hash).
    #
    # Required.
    ref: "..."

    # sha is the commit SHA of the repository that the package was built at.
    #
    # Required.
    sha: "..."

    # distro is the target distro (debian, ubuntu).
    #
    # Required.
    distro: "..."

    # codename is the target codename (e.g. focal, bullseye).
    #
    # Required.
    codename: "..."

    # suite is Regolith package archive suite (e.g. unstable, testing, stable).
    #
    # Required.
    suite: "..."

    # component is Regolith package archive component (e.g. main, v3.2, v3.1).
    #
    # Required.
    component: "..."

    # arch is Regolith architectures (amd64, arm64)
    #
    # Required.
    arch: "..."
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

      - name: Update Manifest
        uses: regolith-linux/actions/update-manifest@main
        env:
          server-address: "${{ secrets.SERVER_IP_ADDRESS }}"
          server-username: "${{ secrets.SERVER_SSH_USER }}"
        with:
          name: "foo-package"
          repo: "${{ github.server_url }}/${{ github.repository }}.git"
          ref: "${{ github.ref }}"
          sha: "${{ github.sha }}"
          distro: "ubuntu"
          codename: "noble"
          suite: "unstable"
          component: "main"
          arch: "amd64"
```
