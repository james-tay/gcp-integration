#!/bin/bash

# Install any software this script depends on.

if [ `id -u` -ne 0 ] ; then
  sudo apt install -y wget git
  sudo chown `id -u` /usr/local/bin
fi

# Download various utilities we'll need. These are simple as they're
# standalong binaries.

SOPS_SRC="https://github.com/mozilla/sops/releases/download/v3.7.1/sops-v3.7.1.linux"
SOPS_DST="/usr/local/bin/sops"

wget -O $SOPS_DST $SOPS_SRC || exit 1
chmod 755 $SOPS_DST

RKE_SRC="https://github.com/rancher/rke/releases/download/v0.2.4/rke_linux-amd64"
RKE_DST="/usr/local/bin/rke"

wget -O $RKE_DST $RKE_SRC || exit 1
chmod 755 $RKE_DST

KUBE_SRC="https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl"
KUBE_DST="/usr/local/bin/kubectl"

wget -O $KUBE_DST $KUBE_SRC || exit 1
chmod 755 $KUBE_DST

GOMP_SRC="https://github.com/hairyhenderson/gomplate/releases/download/v3.9.0/gomplate_linux-amd64"
GOMP_DST="/usr/local/bin/gomplate"

wget -O $GOMP_DST $GOMP_SRC || exit 1
chmod 755 $GOMP_DST

HELMFILE_SRC="https://github.com/roboll/helmfile/releases/download/v0.134.1/helmfile_linux_amd64"
HELMFILE_DST="/usr/local/bin/helmfile"

wget -O $HELMFILE_DST $HELMFILE_SRC
chmod 755 $HELMFILE_DST

# Setup helm (and its plugins).
# Note that the tiller'less helm plugin needs the "tiller" binary. This is why
# we move the "tiller" binary into that plugin's directory.

HELM_TAR_SRC="https://get.helm.sh/helm-v2.16.5-linux-amd64.tar.gz"
HELM_TAR_DST="/root/helm.tar.gz"
HELM_STABLE_REPO="https://charts.helm.sh/stable"
TILLER_DIR="$HOME/.helm/cache/plugins/https-github.com-rimusz-helm-tiller/bin"

wget -O $HELM_TAR_DST $HELM_TAR_SRC || exit 1
gzip -cd $HELM_TAR_DST | tar -xvpf - || exit 1
mv linux-amd64/helm /usr/local/bin || exit 1

helm init --client-only --stable-repo-url $HELM_STABLE_REPO || exit 1
helm plugin install https://github.com/rimusz/helm-tiller || exit 1
helm plugin install https://github.com/databus23/helm-diff || exit 1

mkdir -p $TILLER_DIR || exit 1
mv linux-amd64/tiller $TILLER_DIR || exit 1

# do a quick test to make sure tiller'less helm works right.

helm tiller run -- helm version || exit 1

# At this point, we're ready to package up everything we've setup.

TOOLS_TAR="/tmp/rke-tools.tar"

tar -cvpf $TOOLS_TAR $HOME/.helm /usr/local/bin || exit 1
gzip -9v $TOOLS_TAR || exit 1

