# K8S configuration shell


## File List
- cluster_infra.sh
- cluster_create.sh
- cluster_config.sh  


## Getting Started

```bash
$ cluster_infra.sh
$ cluster_create.sh test-123213
$ cluster_config.sh test-123123
```

- **test-123123** is a name parameter
- 'cluster_config.sh' should be executed **completly after** cluster created.
- 'cluster_config.sh' and 'cluster_create.sh' **need a same parameter**


## Check Cluster completely created.
```bash
$(magnum cluster-show test-123123 | awk '/ api_address /{print $4}')
```

- If "-" is shown in console, now cluster is creating phase.
- If 192.x.x.x like ip address shown, cluster is created completly.
