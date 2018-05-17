#!/bin/bash
cd /etc/jupyterhub
sudo -u jhub jupyterhub\
 --JupyterHub.spawner_class=sudospawner.SudoSpawner\
 --ip 10.0.10.32\
 --port 443\
 --JupyterHub.proxy_auth_token_config='LONGNUMBER'
# --Authenticator.admin_users={'ktaylora','adaniels','schang','mbogaerts'}
