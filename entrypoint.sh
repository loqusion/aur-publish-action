#!/bin/bash -l

set -euo pipefail

ls -lA
for x in "${!GITHUB_@}"; do
	echo "$x" "${!x}"
done

export HOME=/home/builder
git config --global --add safe.directory "$GITHUB_WORKSPACE"
VERSION=$(git -C "$GITHUB_WORKSPACE" describe --abbr=0 "$GITHUB_REF")
PKGVER=${VERSION##*/v}
HOST_URL="aur.archlinux.org"
REPO_URL="ssh://aur@${HOST_URL}/${INPUT_PACKAGE_NAME}.git"

echo '::group::Configuring SSH'
export SSH_PATH="$HOME/.ssh"
(
	umask 077
	mkdir -p "$SSH_PATH"
	ssh-keyscan -t ed25519 "$HOST_URL" >>"$SSH_PATH/known_hosts"
	echo -e "${INPUT_SSH_PRIVATE_KEY//_/\\n}" >"$SSH_PATH/aur"
)
cp /ssh_config "$SSH_PATH/config"
chmod +r "$SSH_PATH/config"
eval "$(ssh-agent -s)"
ssh-add "$SSH_PATH/aur"
export GIT_SSH_COMMAND="ssh -i $SSH_PATH/aur -F $SSH_PATH/config -o UserKnownHostsFile=$SSH_PATH/known_hosts"
echo '::endgroup::'

echo '::group::Configuring Git'
git config --global user.name "$INPUT_GIT_USERNAME"
git config --global user.email "$INPUT_GIT_EMAIL"
echo '::endgroup::'

echo "::group::Cloning $REPO_URL"
git clone -v "$REPO_URL" "/tmp/aur-repo"
cd "/tmp/aur-repo"
echo '::endgroup::'

echo "::group::Building PKGBUILD for $INPUT_PACKAGE_NAME $PKGVER"
# Escape for sed
PKGVER_SED=$(printf '%s\n' "$PKGVER" | sed -e 's/[\/&]/\\&/g')
sed -i "s/pkgver=.*$/pkgver=$PKGVER_SED/" PKGBUILD
sed -i "s/pkgrel=.*$/pkgrel=1/" PKGBUILD
sha256sums=$(makepkg -g)
perl -i -0pe "s/sha256sums=[\s\S][^\)]*\)/${sha256sums}/" PKGBUILD
makepkg -c
makepkg --printsrcinfo >.SRCINFO
echo '::endgroup::'

echo '::group::PKGBUILD'
cat PKGBUILD
echo '::endgroup::'

if [[ $INPUT_DEBUG == "true" ]]; then
	echo 'DEBUG is enabled, exiting early.'
	exit 0
fi

echo '::group::Pushing to AUR'
git add PKGBUILD .SRCINFO
git diff-index --exit-code --quiet HEAD || {
	git commit -m "chore: bump version to $PKGVER"
	git push && echo "::warning::Pushed to AUR"
}
echo '::endgroup::'
