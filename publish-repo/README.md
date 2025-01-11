<!-- AUTO_GENERATE_START -->
# Publish Repository

Publish packages of supported distro(s), codename(s), and component(s) to a new
or existing archive repository.
<!-- AUTO_GENERATE_END -->

## Usage

```yaml
- uses: regolith-linux/actions/publish-repo@main
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
    # packages-path-base is the base path on the server to publish repository from.
    #
    # Required.
    packages-path-base: "/opt/archives/packages/"

    # packages-path-subfolder is the name of the folder in 'packages-path-base' to publish repository from.
    packages-path-subfolder: ""
    
    # only-distro is a filter to only publish repository for this distro.
    only-distro: "..."
    
    # only-codename is a filter to only publish repository for this codename.
    only-codename: "..."
    
    # onlt-component is a filter to only publish repository for this component.
    only-component: "..."
```

## Scenarios

```yaml
jobs:
  build:
    runs-on: ubuntu-24.04
    container: "ubuntu:noble"
    steps:
      - name: Setup SSH
        uses: regolith-linux/actions/setup-ssh@main
        with:
          ssh-host: "${{ secrets.KAMATERA_HOSTNAME2 }}"
          ssh-key: "${{ secrets.KAMATERA_SSH_KEY }}"

      - name: Publish Repo
        uses: regolith-linux/actions/publish-repo@main
        env:
          server-address: "${{ secrets.SERVER_IP_ADDRESS }}"
          server-username: "${{ secrets.SERVER_SSH_USER }}"
        with:
          packages-path-subfolder: "foo-package"
```
