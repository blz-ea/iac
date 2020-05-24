# Ansible Roles #

- `vars`
- `pre_flight_check`

## Docker ##

- `docker` - Installs specified Docker version
  - `docker_create_networks`
  - `docker_code_server`
  - `docker_minio`
  - `docker_mongodb`
  - `docker_nginx`
  - `docker_redis`
  - `docker_theia_ide`

## User Environment ##

- `user` - Manage user accounts
  - `mosh`
  - `oh_my_zsh`
  - `tmux`

## OS ##

- `ssh`
- `node_exporter` - Manage Node Exporter Service.
    Installs/Deletes latest release of [Node Exporter](https://github.com/prometheus/node_exporter)
- `ufw`
- `swap`
- `python3`
