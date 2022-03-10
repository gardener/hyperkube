#!/usr/bin/env python3
import json
import os

import ci.util
import concourse.steps.build_oci_image
import ctx
import dockerutil
from model.container_registry import ContainerRegistryConfig

# also call functions preparing the environment for buildx. Usually this is done in the
# publish step
dockerutil.launch_dockerd_if_not_running()
concourse.steps.build_oci_image.prepare_qemu_and_binfmt_misc()

home = ci.util.check_env('HOME')
docker_cfg_dir = os.path.join(home, '.docker')
docker_cfg_file = os.path.join(docker_cfg_dir,  'config.json')

os.makedirs(docker_cfg_dir, exist_ok=True)

config_factory = ctx.cfg_factory()
container_registry_cfg: ContainerRegistryConfig = config_factory.container_registry(
    'gcr-readwrite',
)
docker_cfg_auths = {'auths': container_registry_cfg.as_docker_auths()}

with open(docker_cfg_file, 'w') as f:
    json.dump(docker_cfg_auths, f)
