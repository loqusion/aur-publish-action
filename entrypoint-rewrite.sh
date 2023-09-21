#!/bin/bash -l
set -euo pipefail

ls -lA /

echo "$GITHUB_WORKSPACE"

USER=$(whoami)

chown -R "${USER}:${USER}" "$GITHUB_WORKSPACE"

echo "::debug::$(stat /github/workspace)"

HOST_URL="aur.archlinux.org"
REPO_URL="ssh://aur@${HOST_URL}/${INPUT_PACKAGE_NAME}.git"

get_version() {
	local version
	if [[ $GITHUB_REF_TYPE = "tag" ]]; then
		version=$GITHUB_REF
	else
		echo "Attempting to resolve version from ref $GITHUB_REF"
		git -C "$GITHUB_WORKSPACE" fetch --tags
		version=$(git -C "$GITHUB_WORKSPACE" describe --abbr=0 "$GITHUB_REF")
	fi >&2
	echo "$version"
}

VERSION=$(get_version)
PKGVER=${VERSION##*/v}
echo "Version: $VERSION"

export SSH_PATH="$HOME/.ssh"
# shellcheck disable=SC2174
mkdir -p -m 700 "$SSH_PATH"
ssh-keyscan -t ed25519 "$HOST_URL" >>"$SSH_PATH/known_hosts"
echo -e "${INPUT_SSH_PRIVATE_KEY//_/\\n}" >"$SSH_PATH/aur.key"
chmod 600 "$SSH_PATH/aur.key" "$SSH_PATH/known_hosts"
cp /ssh_config "$SSH_PATH/config"
chmod +r "$SSH_PATH/config"
eval "$(ssh-agent -s)"
ssh-add "$SSH_PATH/aur.key"

echo '::group::Cloning repository'
(
	export GIT_SSH_COMMAND="ssh -i $SSH_PATH/aur.key -F $SSH_PATH/config -o UserKnownHostsFile=$SSH_PATH/known_hosts"
	git clone -v "$REPO_URL" "/tmp/aur-repo"
)
cd "/tmp/aur-repo"
echo '::endgroup::'
