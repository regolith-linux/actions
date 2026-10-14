<!-- AUTO_GENERATE_START -->
# Build Package

Build a package for speficied distro/codename/stage triplet. It uses package
name, package repo, and package ref to checkout the code. If the package has
autopkgtests (`debian/tests/control`), they run against the built packages.
<!-- AUTO_GENERATE_END -->

## Usage

```yaml
- uses: regolith-linux/actions/build-package@main
  with:
    # only-build the package, if set to false don't sign nor publish the package.
    #
    # Required.
    only-build: "false"

    # name of the package to build.
    #
    # Required.
    name: "..."

    # distro is the target distro to build the package for (debian, ubuntu).
    #
    # Required.
    distro: "..."

    # codename is the target codename to build the package for (e.g. focal, bullseye).
    #
    # Required.
    codename: "..."

    # stage is Regolith release stage (e.g. unstable, testing, stable).
    #
    # Required.
    stage: "..."

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

    # gpg-email is the email ID associated with the GPG Key.
    #
    # Required.
    gpg-email: "regolith.linux@gmail.com"

    # gpg-name is the full name associated with the GPG Key.
    #
    # Required.
    gpg-name: "Regolith Linux"

    # run-autopkgtest runs the package autopkgtests after the build (auto, true,
    # false). auto runs them only if only-build is "true", i.e. on pull requests.
    #
    # Optional.
    run-autopkgtest: "auto"
```

## Outputs

| Name | Description | Example |
|------|-------------|---------|
| `publish-path` | The path on disk that packages are published to | `/build/publish/` |
| `buildlog-path` | The path on disk that buildlogs are saved to | `/build/buildlog/` |
| `autopkgtest-path` | The path on disk that autopkgtest results are saved to, empty if the tests did not run | `/__w/_temp/autopkgtest-foo-package-ubuntu-noble-unstable-amd64` |

## autopkgtests

If the package has a `debian/tests/control` file, its [autopkgtests](https://salsa.debian.org/ci-team/autopkgtest/-/blob/master/doc/README.package-tests.rst)
run right after the build, in the same container, against the binary packages
that were just built:

```sh
sudo autopkgtest --output-dir <dir> --no-built-binaries --user <build user> <built .debs> <package dir> -- null
```

- The container is the testbed (the `null` virtualization server). Test
  dependencies are installed with the container's apt sources, which include
  the Regolith archive of the target stage, distro and codename that the build
  added for internal build dependencies (if that archive exists).
- Packages without `debian/tests/control` skip this step.
- `auto` (the default) runs the tests only if `only-build` is `"true"`, which is
  what `test-pr.yml` uses. Publish workflows (`only-build: "false"`) do not run
  them unless they set `run-autopkgtest: "true"`.
- The job fails if a test fails. Skipped tests (for example a `skippable` test
  exiting with 77) do not fail it.
- The results (`summary`, `log`, and each test's output) are uploaded as the
  `autopkgtest-<name>-<distro>-<codename>-<stage>-<arch>` artifact, and the
  summary is added to the job summary.
- To turn the tests off for a repository, set `run-autopkgtest: "false"`.

Restrictions under the `null` testbed:

| Restriction | Behavior |
|-------------|----------|
| `allow-stderr`, `skippable` | honored (a `skippable` test that exits 77 is reported as skipped) |
| `needs-root` | runs as root; tests without it run as the build user |
| `needs-sudo` | runs as the build user, which has passwordless `sudo` in the CI images |
| `needs-internet` | runs (GitHub-hosted runners have network access) |
| `isolation-container`, `isolation-machine`, `breaks-testbed`, `needs-reboot` | skipped: the job container has no init system and cannot be reverted or rebooted |
| others (`flaky`, `superficial`, `rw-build-tree`, `build-needed`, `skip-not-installable`, ...) | as documented by autopkgtest |

If the test dependencies cannot be installed (for example a dependency missing
from the Regolith archive for that codename), autopkgtest reports `badpkg` and
the job fails, unless the test has the `skip-not-installable` restriction.

The job container has no systemd, system D-Bus, X server or session bus.
Tests that need a display or a session bus start their own (for example with
`xvfb-run` and `dbus-run-session`); tests that need a system bus should skip
(`skippable`, exit 77) when `/run/dbus/system_bus_socket` is missing.

Run the same tests locally on a system with the Regolith archive configured:

```sh
sudo autopkgtest . -- null              # in a clean tree: build the package, then test it
sudo autopkgtest ../*.deb . -- null     # test packages that are already built
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
```
