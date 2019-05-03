# Dependency Proxy

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ee/issues/7934) in [GitLab Premium](https://about.gitlab.com/pricing/) 11.11.

To access the dependency proxy, navigate to a group's sidebar and select **Overview > Dependency Proxy**.

![Dependency Proxy group page](img/group_dependency_proxy.png)

Currently, only dependency proxy for containers is supported. See 
[direction page](https://about.gitlab.com/direction/package/dependency_proxy/#top-vision-items)
for further plans.

## Dependency proxy for containers

In order to be used, the feature [must be configured](../../../administration/dependency_proxy.md) by administrator

### How it works

You use your GitLab URL as a source for a docker image. 
You can find the URL on a group page displayed above.

```
docker pull gitlab.example.com/MY_GROUP/dependency_proxy/containers/alpine:latest
```

GitLab will pull a docker image from Docker Hub. Then it will cache blobs on the 
GitLab server. Next time you pull the same image, it will get the latest information about
the image from Docker Hub but will serve existing blobs from the GitLab server.

### Limitations

* Only public groups are supported (authentication is not supported yet).
* Only Docker Hub is supported now.
* The feature requires Docker Hub being available.
