# AUR Publish

> WARNING: This is very much a work-in-progress.

## Inputs

| Name                | Description                                           | Default                              |
| ------------------- | ----------------------------------------------------- | ------------------------------------ |
| \*`ssh-private-key` | The private SSH key to use to push the changes to AUR |                                      |
| `package-name`      | Name of the AUR package                               | `{{ github.event.repository.name }}` |
| `git-username`      | The username to use when creating the AUR repo commit | `AUR Release Action`                 |
| `git-email`         | The email to use when creating the AUR repo commit    | `github-action-bot@no-reply.com`     |

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
          ssh-private-key: ${{ secrets.AUR_SSH_PRIVATE_KEY }}
          # the rest are optional
          package-name: my-aur-package
          git-username: me
          git-email: me@me.me
```

## Credits

[aur-release-action](https://github.com/0x61nas/aur-release-action)
[aur-publish-action](https://github.com/zu1k/aur-publish-action)
[github-action-push-to-another-repository](https://github.com/cpina/github-action-push-to-another-repository)
