# Get Voulage

Clone and fetch [voulage] repository at given `ref`.

## Usage

```yaml
- uses: regolith-linux/actions/get-voulage@main
  with:
    # ref is the valid ref in git repository to checkout.
    ref: "main"
```

## Outputs

| Name | Description | Example |
|------|-------------|---------|
| `path` | The path voulage is cloned into | `/tmp/voulage-actions-repo` |

## Scenarios

```yaml
jobs:
  build:
    runs-on: ubuntu-24.04
    container: "ubuntu:noble"
    steps:
      - name: Get Voulage
        id: voulage
        uses: regolith-linux/actions/get-voulage@main

      - name: Build Package
        uses: regolith-linux/actions/build-package@main
        env:
          VOULAGE_PATH: ${{ steps.voulage.outputs.path }}
        with:
          name: "foo-package"
          repo: "https://github.com/${{ github.repository }}"
          ref: "${{ github.ref }}"
          distro: "ubuntu"
          codename: "noble"
```

[voulage]: https://github.com/regolith-linux/voulage/
