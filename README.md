# AUR Publish

## Inputs

| Name                | Description                                           | Default                              |
| ------------------- | ----------------------------------------------------- | ------------------------------------ |
| \*`ssh_private_key` | The private SSH key to use to push the changes to AUR |                                      |
| `package_name`      | Name of the AUR package                               | `{{ github.event.repository.name }}` |
| `git_username`      | The username to use when creating the AUR repo commit | `AUR Release Action`                 |
| `git_email`         | The email to use when creating the AUR repo commit    | `github-action-bot@no-reply.com`     |

> \* **Required**

## Example

```yaml
name: AUR Publish

on:
  release:
    types: [published]

concurrency:
  group: "aur"
  cancel-in-progress: true

jobs:
  aur-publish:
    runs-on: ubuntu-latest
    environment: AUR
    steps:
      - uses: loqusion/aur-publish-action@v1
        with:
          ssh_private_key: ${{ secrets.AUR_SSH_PRIVATE_KEY }}
          # the rest are optional
          package_name: my-aur-package
          git_username: me
          git_email: me@me.me
```
