# Ensure Sudo

Ensure `sudo` command is installed and available.

## Usage

```yaml
- uses: regolith-linux/actions/ensure-sudo@main
```

## Scenarios

```yaml
jobs:
  build:
    runs-on: ubuntu-24.04
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Ensure Sudo
        uses: regolith-linux/actions/ensure-sudo@main

      - name: Environment Setup
          run: |
            sudo apt update
            DEBIAN_FRONTEND=noninteractive sudo apt install -y <some_package>
```
