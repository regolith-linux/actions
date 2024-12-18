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

## Scenarios

```yaml
jobs:
  build:
    runs-on: ubuntu-24.04
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
          repo: "https://github.com/${{ github.repository }}"
          ref: "${{ github.ref }}"
          distro: "${{ matrix.distro }}"
          codename: "${{ matrix.codename }}"
```
