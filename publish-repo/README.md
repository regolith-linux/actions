<!-- AUTO_GENERATE_START -->
# Publish Repository

Publish packages of supported distro(s), codename(s), and component(s) to a new
or existing archive repository.
<!-- AUTO_GENERATE_END -->

## Usage

```yaml
- uses: regolith-linux/actions/publish-repo@main
  with:
    # server-address is the IP address of the publish server.
    #
    # Required.
    server-address: "..."
    
    # server-user is the server SSH username.
    #
    # Required.
    server-user: "..."
    
    # packages-path is the path on disk that contains the packages.
    #
    # Required.
    packages-path: "/opt/archives/packages/"
    
    # only-distro is a filter to only publish repository for this distro.
    only-distro: "..."
    
    # only-codename is a filter to only publish repository for this codename.
    only-codename: "..."
    
    # onlt-component is a filter to only publish repository for this component.
    only-component: "..."
```

## Scenarios

```yaml
- uses: regolith-linux/actions/publish-repo@main
  with:
    server-address: "${{ secrets.SERVER_IP_ADDRESS }}"
    server-user: "${{ secrets.SERVER_SSH_USER }}"
    packages-path: "/opt/archives/packages/"
```
