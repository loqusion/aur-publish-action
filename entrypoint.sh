#!/bin/bash

set -euo pipefail

PKGVER=${GITHUB_REF##*/v}
REPO_URL="ssh://aur@aur.archlinux.org/${INPUT_PACKAGE_NAME}.git"

echo "---------------- AUR Package version $INPUT_PACKAGE_NAME/$PKGVER ----------------"

ssh-keyscan -t ed25519 aur.archlinux.org >>"$HOME"/.ssh/known_hosts
echo -e "${INPUT_SSH_PRIVATE_KEY//_/\\n}" >"$HOME"/.ssh/aur
chmod 600 "$HOME"/.ssh/aur*

git config --global user.name "$INPUT_COMMIT_USERNAME"
git config --global user.email "$INPUT_COMMIT_EMAIL"

echo "---------------- CLONING $REPO_URL ----------------"

git clone "$REPO_URL" "/tmp/$INPUT_PACKAGE_NAME"
cd "/tmp/$INPUT_PACKAGE_NAME"

echo "------------- BUILDING PKG $INPUT_PACKAGE_NAME ----------------"

sed -i "s/pkgver=.*$/pkgver=$PKGVER/" PKGBUILD
sed -i "s/pkgrel=.*$/pkgrel=1/" PKGBUILD
perl -i -0pe "s/sha256sums=[\s\S][^\)]*\)/$(makepkg -g 2>/dev/null)/" PKGBUILD

makepkg -c
makepkg --printsrcinfo >.SRCINFO

echo "------------- PUBLISHING ----------------"

git add PKGBUILD .SRCINFO
git diff-index --exit-code --quiet HEAD || {
	git commit -m "chore: bump version to $PKGVER"
	git push && echo "::warning::Pushed to AUR"
}

echo "------------- SYNC DONE ----------------"
