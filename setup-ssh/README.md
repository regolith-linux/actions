# Setup SSH

Setup SSH agen and add server keyscan to the known_host file.

## Usage

```yaml
- uses: regolith-linux/actions/setup-ssh@main
  with:
    # ssh-host is the IP address or FQDN of the server.
    #
    # Required.
    ssh-host: "..."

    # ssh-key is the server SSH private key.
    #
    # Required.
    ssh-key: "..."
```

## Scenarios

```yaml
jobs:
  build:
    runs-on: ubuntu-24.04
    steps:
      - name: Setup SSH
        uses: regolith-linux/actions/setup-ssh@main
        with:
          ssh-host: "${{ secrets.SERVER_IP_ADDRESS }}"
          ssh-key: "${{ secrets.SERVER_SSH_KEY }}"

      - name: Upload Files
        uses: regolith-linux/actions/upload-files@main
        with:
          upload-from: "/path/fo/publish/"
          upload-to-folder: "foo-package"
          server-address: "${{ secrets.SERVER_IP_ADDRESS }}"
          server-username: "${{ secrets.SERVER_SSH_USER }}"
```
