<!-- AUTO_GENERATE_START -->
# Test if `regolith-desktop` is Installable

Test that `regolith-desktop` is installable on a target system given public key,
`apt` config line, and package(s) name (e.g. `regolith-session-sway`).
<!-- AUTO_GENERATE_END -->

## Usage

```yaml
- uses: regolith-linux/actions/test-desktop/<distro>/<codename>@main
  with:
    # apt-key-url is URL to public key of repository to import.
    #
    # Required.
    apt-key-url: "..."

    # apt-repo-line is the deb line to add to apt sources.
    #
    # Required.
    apt-repo-line: "..."

    # target-package is the space-separated name of packages to install.
    #
    # Required.
    target-package: "..."
```

## Scenarios

```yaml
- uses: regolith-linux/actions/test-desktop/ubuntu/noble@main
  with:
    apt-key-url: http://archive.regolith-desktop.com/regolith.key
    apt-repo-line: "deb [arch=amd64] http://archive.regolith-desktop.com/ubuntu/unstable noble main"
    target-package: "regolith-desktop regolith-session-sway"
```
