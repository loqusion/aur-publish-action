#!/bin/bash -l

set -euo pipefail

PKGVER=${GITHUB_REF##*/v}
REPO_URL="ssh://aur@aur.archlinux.org/${INPUT_PACKAGE_NAME}.git"

echo '::group::Configuring SSH'
(
	umask 077
	mkdir -p "$HOME/.ssh"
	ssh-keyscan -t ed25519 aur.archlinux.org >>"$HOME/.ssh/known_hosts"
	echo -e "${INPUT_SSH_PRIVATE_KEY//_/\\n}" >"$HOME/.ssh/aur"
	cp /ssh_config "$HOME/.ssh/config"
)
echo '::endgroup::'

echo '::group::Configuring Git'
git config --global user.name "$INPUT_GIT_USERNAME"
git config --global user.email "$INPUT_GIT_EMAIL"
echo '::endgroup::'

echo "::group::Cloning $REPO_URL into /tmp/aur-repo"
git clone "$REPO_URL" "/tmp/aur-repo"
cd "/tmp/aur-repo"
echo '::endgroup::'

echo "::group::Building PKGBUILD for $INPUT_PACKAGE_NAME"
sed -i "s/pkgver=.*$/pkgver=$PKGVER/" PKGBUILD
sed -i "s/pkgrel=.*$/pkgrel=1/" PKGBUILD
perl -i -0pe "s/sha256sums=[\s\S][^\)]*\)/$(makepkg -g 2>/dev/null)/" PKGBUILD
makepkg -c
makepkg --printsrcinfo >.SRCINFO
echo '::endgroup::'

echo '::group::PKGBUILD'
cat PKGBUILD
echo '::endgroup::'

if [[ $INPUT_DEBUG == "true" ]]; then
	exit 0
fi

echo '::group::Pushing to AUR'
git add PKGBUILD .SRCINFO
git diff-index --exit-code --quiet HEAD || {
	git commit -m "chore: bump version to $PKGVER"
	git push && echo "::warning::Pushed to AUR"
}
echo '::endgroup::'
