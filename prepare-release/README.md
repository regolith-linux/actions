<!-- AUTO_GENERATE_START -->
# Prepeare Release

Extract the version out of `debian/changelog` file and pass it through the tag
generator to determine the actual release version. Update corresponding `testing`
package models with that release version for the provided package.
<!-- AUTO_GENERATE_END -->

## Usage

```yaml
- uses: regolith-linux/actions/prepare-release@main
  env:
    # GITHUB_TOKEN is used to commit and push to Voulage.
    #
    # Required.
    GITHUB_TOKEN: ${{ env.GITHUB_TOKEN }}
  with:
    # name of the package to create a tag and release for.
    #
    # Required.
    name: "..."

    # repo is the public git repository URL of the package
    #
    # Required.
    repo: "..."

    # ref is Git repository ref to tag and release from (e.g. branch, tag, or hash).
    #
    # Required.
    ref: "..."
```

## Outputs

| Name⠀⠀⠀⠀⠀⠀⠀ | Description | Example⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ |
|---------------|-------------|------------------------|
| `release-exists` | A boolean indicating if the release already exists in the GitHub repo or not | `true \| false` |
| `release-version` | The full release version extracted from debian/changelog and additional slugs if required | `v0.3.3-5-debian-bookworm` |
| `voulage-path` | The path voulage is cloned into | `/tmp/voulage-actions-repo` |

## Scenarios

```yaml
jobs:
  release:
    runs-on: ubuntu-24.04
    container: "ubuntu:noble"
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Prepare Release
        id: prepare
        uses: regolith-linux/actions/prepare-release@main
        env:
          GITHUB_TOKEN: ${{ env.GITHUB_TOKEN }}
        with:
          name: "${{ github.event.repository.name }}"
          repo: "${{ github.server_url }}/${{ github.repository }}.git"
          ref: "${{ github.ref_name }}"

      - name: Push Changes to Voulage
        uses: stefanzweifel/git-auto-commit-action@v5
        if: ${{ steps.prepare.outputs.release-exists == false }}
        env:
          GITHUB_TOKEN: ${{ env.GITHUB_TOKEN }}
        with:
          repository: "${{ steps.prepare.outputs.voulage-path }}"
          file_pattern: "stage/testing/**"
          commit_message: "chore: bump ${{ github.event.repository.name }} testing to ${{ steps.prepare.outputs.release-version }}"

      - name: Release Package
        uses: softprops/action-gh-release@v2
        if: ${{ steps.prepare.outputs.release-exists == false }}
        with:
          name: ${{ steps.prepare.outputs.release-version }}
          tag_name: ${{ steps.prepare.outputs.release-version }}
          token: ${{ env.GITHUB_TOKEN }}
          generate_release_notes: true
```
