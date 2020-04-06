# Building services

This page describes an architecture of building services. The main purpose
of this document is to have a constant way to for handling health checks,
metrics and have a standard handling for signals for all build services.

When introducing new service into GitLab in order to ensure that
we all know how to manage we follow these rules:

- `health-checks`
- `metrics`
- `signals`
- `shared secret`

## Authentication

Each endpoint documented here should be secured:

- allow to call the endpoints if the requests originate from `localhost`:
  we want to easily debug services when on nodes

- expect that a shared `secret` is configured to access the endpoints:
  we do that as we don't want external requests to sensitive services
  that might increase the pressure on system or leak sensitive data

The shared `secret` is good enough, and easy to implement, but blocks
easily the access unless known.

## Health-check endpoints

We can consider two types of health-check endpoints as described well
by [Kubernetes startup probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/):

1. **Readiness**: Kubernetes uses Readiness Probes to know when a container is ready to start accepting traffic. A Pod is considered ready when all of its containers are ready. One use of this signal is to control which Pods are used as backends for Kubernetes Services (and esp. Ingress).

2. **Liveness**: Kubernetes uses Liveness Probes to know when to restart a container. For example, Liveness Probes could catch a deadlock, where an application is running, but unable to make progress. Restarting a container in such a state can help to make the application more available despite bugs, but restarting can also lead to cascading failures (see below).

We really care about `/readiness` type of `health-check`. 

### Implemenation of `/readiness` (or `/-/readiness`) endpoint

We can consider two different approaches to implementing `health-check` endpoint,
depending on type of service running.

Two general types of services are:

1. `web-based service` the service that implements HTTP endpoint and processes
   requests of clients

2. `background jobs` the service that implements some sort of background processing
   queue, like `sidekiq`

It is pretty much required that the health-check endpoint to be implemented
using a main processing HTTP endpoint if present (like in `web-based services`).
This way we can detect the main processing queue if it can accept new requests,
or it is simply overloaded (like extensive queueing) and cannot process new requests
in a reasonable time.

The `bacgkround jobs` service usually does not have a HTTP endpoint. In such case
the single endpoint can be used for `health-checks` and `metrics`.

The `health-check` endpoints should not check the dependent services, like `database`
whether they are reachable.

The intent of `health-check` is to validate the following aspects:

- application is ready to process
- application is not overloaded
- application is not in a shutdown

The intent is not:

- **do not depend on external dependencies**:
  depending on external dependencies might result in cascading failure,
  it also increases the cost of processing the `health-check` from application side

### Implementation of `/liveness`

You don't really need or should never implement `/liveness`,
but if you do we really want to use `/readiness` always.

TBD: Describe where `/liveness` is useful

## Metrics

Each service deployed should implement `/metrics` endpoint that is used to serve
Prometheus Metrics.

It is pretty much required for `/metrics` to be run on a completely separate endpoint.
The main purpose of that is to ensure that metrics can be scraped always, also when
service is under severe load, or even overload.

TBD: Describe what libraries to use. Document what ports to use.

## Signals

Signal handling is the most important aspect of service lifecycle.
The signals allows us to perform controlled service restart shutdown.

We can consider the following types of operations that we might want to perform:

- `gracefull restart`: SIGHUP?
- `immediate restart`: SIGINT
- `gracefull shutdown`: SIGSTOP
- `immediate shutdown`: SIGINT

TBD:
1. Propose signal names
1. Describe implementation and purpose of Blackout Period during gracefull restart/shutdown
1. Describe all operations and their lifecycle
1. Describe process replacement due to upgrade
1. Describe that we don't want to do a `re-exec` dance: fork to replace itself