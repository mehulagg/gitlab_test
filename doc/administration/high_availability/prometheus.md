# Configuring Prometheus for GitLab High Availability

Since GitLab 9.0, Prometheus and its exporters are on by default. By default
Prometheus is only accessible from the GitLab node itself. If you're trying
to collect metrics from all your nodes you will need to set up an external
prometheus instance and configure each node to allow prometheus to collect
metrics.

### Standalone Prometheus using GitLab Omnibus

#### Installing Omnibus GitLab

#### Disable other services

#### Configuring the Application nodes

## Provide your own Prometheus instance

If you're hosting GitLab on a cloud provider, you can optionally use a
managed service for Prometheus.

## Troubleshooting

---

Read more on high-availability configuration:

1. [Configure Redis](redis.md)
1. [Configure NFS](nfs.md)
1. [Configure the GitLab application servers](gitlab.md)
1. [Configure the load balancers](load_balancer.md)
1. [Manage the bundled Consul cluster](consul.md)

[reconfigure GitLab]: ../restart_gitlab.md#omnibus-gitlab-reconfigure
