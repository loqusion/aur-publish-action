# AUR Publish

Publish a package to the Arch User Repository (AUR) on GitHub release.

In total, this action will clone the AUR package repository, update the `PKGBUILD`/`.SRCINFO`,
verify build, and push to AUR.

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
      - uses: actions/checkout@v3
      - uses: loqusion/aur-publish-action@v2
        with:
          ssh-private-key: ${{ secrets.AUR_SSH_PRIVATE_KEY }}
          # the rest are optional
          package-name: my-aur-package
          git-username: me
          git-email: me@me.me
```

## Credits

- [aur-release-action](https://github.com/0x61nas/aur-release-action)
- [aur-publish-action](https://github.com/zu1k/aur-publish-action)
- [github-action-push-to-another-repository](https://github.com/cpina/github-action-push-to-another-repository)
