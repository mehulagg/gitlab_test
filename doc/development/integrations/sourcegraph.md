# Developing Locally with Sourcegraph

This guide walks through setting up a locally running Sourcegraph instance and
enabling the Sourcegraph integration. 

![Set up local Sourcegraph for GDK](https://youtu.be/lOb2qdNKJGs)

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) - This is needed to run the Sourcegraph docker image.
- Use a network IP for the GDK `hostname`.

A good way to setup the network IP is by adding a record to your local `/etc/hosts`. Here's an example with
a network IP of `192.168.1.1` (replace with your own network IP):

```
# <network IPv4> <hostname>
# <network IPv6> <hostname>
192.168.1.1 gitlab.local
ffff:ffff:ffff:ffff:ffff gitlab.local
```

Then in your `gdk.yml`, set the `hostname:` to `gitlab.local` (or whatever hostname you chose).

**NOTE:** On Mac, if you want to use `.local` as a top level domain, you should specify the IPv6
as well as the IPv4 in the `/etc/hosts` (see above example), or else you might
[experience significantly slow requests](https://gitlab.com/gitlab-org/gitlab/-/issues/39081#note_258968112).

## Set up Sourcegraph

### 1 - Add sourcegraph hostname to `/etc/hosts`

Before starting the Sourcegraph service, create a hostname for it that points to your network IP
so that it can be easily accessed across the Docker network.

```
192.168.1.1 sourcegraph.local
ffff:ffff:ffff:ffff:ffff sourcegraph.local
```

### 2 - Create Sourcegraph data directories

So that our configuration and data will persist past the life of the Docker container, create
local directories for the Sourcegraph docker container. These directories will be mounted as volumes for the
container.

```
mkdir -p ~/.sourcegraph/config
mkdir -p ~/.sourcegraph/data
```

### 3 - Start Sourcegraph server

We use the Sourcegraph Docker image to start the service. Press `CTRL-C` to kill the process and stop the server.

```
docker run --publish 7080:7080 --publish 2633:2633 --rm --volume ~/.sourcegraph/config:/etc/sourcegraph --volume ~/.sourcegraph/data:/var/opt/sourcegraph sourcegraph/server:3.10.3
```

### 4 - Sourcegraph Configuration

- Create Sourcegraph admin account
- Set up `externalUrl` in Sourcegraph management console
- Configure Sourcegraph to query GitLab instance
- Set up Sourcegraph with CORS for GitLab instance
- Configure GitLab with Sourcegraph instance
