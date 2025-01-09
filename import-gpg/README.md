# Import GPG Key

Import given GPG private key with its associated email and full name.

## Usage

```yaml
- uses: regolith-linux/actions/import-gpg@main
  with:
    # gpg-key is the GPG private key to import.
    #
    # Required.
    gpg-key: "..."

    # gpg-email is the email ID associated with the GPG Key.
    #
    # Required.
    gpg-email: regolith.linux@gmail.com

    # gpg-name is the full name associated with the GPG Key.
    #
    # Required.
    gpg-name: Regolith Linux
```

## Outputs

| Name | Description | Example |
|------|-------------|---------|
| `gpg-email` | Email ID associated with the GPG Key | `regolith.linux@gmail.com` |
| `gpg-name` | Full Name associated with the GPG Key | `Regolith Linux` |

## Scenarios

```yaml
jobs:
  build:
    runs-on: ubuntu-24.04
    container: "ubuntu:noble"
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Import GPG Key
        uses: regolith-linux/actions/import-gpg@main
        with:
          gpg-key: "${{ secrets.GPG_PRIVATE_KEY }}"

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
```
