#!/usr/bin/env python3
import os

import ci.util
import ctx
from model.github import GithubConfig

home = ci.util.check_env('HOME')

config_factory = ctx.cfg_factory()
github_cfg: GithubConfig = config_factory.github('github_com')
user_credentials = github_cfg.credentials()

ssh_dir = os.path.join(home, '.ssh')
os.makedirs(ssh_dir, exist_ok=True)

with open(os.path.join(ssh_dir, 'id_rsa'), 'wt') as key_file:
    key_file.write(user_credentials.private_key())

with open(os.path.join(home, 'github_user'), 'wt') as user_file:
    user_file.write(user_credentials.username())

with open(os.path.join(home, 'github_email'), 'wt') as email_file:
    email_file.write(user_credentials.email_address())

with open(os.path.join(home, 'github_password'), 'wt') as pw_file:
    email_file.write(user_credentials.passwd())
