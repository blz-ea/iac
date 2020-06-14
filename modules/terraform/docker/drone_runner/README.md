# Drone CI - Docker Runner #

The Docker runner is a daemon that executes pipelines steps inside ephemeral Docker containers. You can install a single Docker runner, or install the Docker runner on multiple machines to create your own build cluster.

## Usage ##

```terraform
module "<name>" {

  dependencies = [
    <dependency>
  ]
  container_name = "<container_name>"

  env = [
    "DRONE_RPC_PROTO=https",
    "DRONE_RPC_HOST=<drone_server_host>",
    "DRONE_RPC_SECRET=<drone_server_host_secret>",
    "DRONE_RUNNER_CAPACITY=1",
    "DRONE_RUNNER_NAME=<runner_name>",
    "DRONE_MEMORY_LIMIT=500000000",
    "DRONE_MEMORY_SWAP_LIMIT=500000000",
  ]

  # Join specific network
  networks_advanced = [
    "bridge",
  ]

  source = "../../../modules/terraform/docker/drone_runner"
}
```

## More info ##

- [Documentation](https://docs.drone.io/runner/docker/overview/)
- [Environment Reference](https://docker-runner.docs.drone.io/configuration/environment/variables/)
