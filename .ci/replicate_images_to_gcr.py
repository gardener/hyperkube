#!/usr/bin/env python3

'''
As of https://github.com/gardener/gardener/pull/8968, Artifact-Registry is used instead of GCR.

However, existing release branches of gardener (e.g. 1.86.x) still expect images to be available
at the previous location (on GCR).

This script replicates any Images from new location on Artifact Registry to old location on GCR.

It will be safe to remove this script after Gardener-v1.86.x branch reaches EOL.
'''

import os

import ccc.oci
import oci
import version

repo_root = os.path.join(os.path.dirname(__file__), os.pardir)


def main():
    with open(os.path.join(repo_root, 'MINIMUM_KUBERNETES_VERSION')) as f:
        min_version = version.parse_to_semver(f.read().strip())

    oci_client = ccc.oci.oci_client()

    src_repository = 'europe-docker.pkg.dev/gardener-project/releases/hyperkube'
    tgt_repository = 'eu.gcr.io/gardener-project/hyperkube'

    src_tags = set(oci_client.tags(src_repository))
    tgt_tags = set(oci_client.tags(tgt_repository))

    missing_tags = src_tags - tgt_tags

    for missing_tag in missing_tags:
        if version.parse_to_semver(missing_tag) < min_version:
            continue

        print(f'will replicate {missing_tag}')
        oci.replicate_artifact(
            f'{src_repository}:{missing_tag}',
            f'{tgt_repository}:{missing_tag}',
            oci_client=oci_client,
            mode=oci.ReplicationMode.PREFER_MULTIARCH,
        )


if __name__ == '__main__':
    main()
