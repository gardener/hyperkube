#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: SAP SE or an SAP affiliate company and Gardener contributors
#
# SPDX-License-Identifier: Apache-2.0

# The following script downloads Kubernetes binaries from dl.k8s.io
#
# Example usage:
#
#  $ get-k8s-binary.sh kubelet v1.29.1 linux/amd64

set -e

BASE_URL=https://dl.k8s.io/release/

function _main() {
    if [ $# -ne 3 ]; then
        echo "Usage: $0 <binary> <version> <os/arch>"
        exit 64  # EX_USAGE
    fi

    local _binary="${1}"
    local _version="${2}"
    local _os_arch="${3}"
    local _files=(
        "${_binary}"
        "${_binary}.sig"
        "${_binary}.cert"
    )

    # Fetch files
    for _file in ${_files[@]}; do
        local _url="${BASE_URL}/${_version}/bin/${_os_arch}/${_file}"
        wget "${_url}"
    done

    # Verify signature
    cosign verify-blob "${_binary}" \
           --signature "${_binary}.sig" \
           --certificate "${_binary}.cert" \
           --certificate-identity krel-staging@k8s-releng-prod.iam.gserviceaccount.com \
           --certificate-oidc-issuer https://accounts.google.com

    chmod +x "${_binary}"
}

_main $*
