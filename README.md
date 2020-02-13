[![Gem Version](https://badge.fury.io/rb/gitlab-qa.svg)](https://rubygems.org/gems/gitlab-qa)
[![build status](https://gitlab.com/gitlab-org/gitlab-qa/badges/master/pipeline.svg)](https://gitlab.com/gitlab-org/gitlab-qa/pipelines)

# GitLab QA orchestrator

## Definitions

- **GitLab QA framework**: A framework that allows developers to write end-to-end
  tests simply and efficiently.
  Located at [`gitlab-org/gitlab-ce@qa/qa/`][qa-framework].
- **GitLab QA instance-level scenarios**: RSpec scenarios that use the
  GitLab QA framework and Capybara to setup and perform individual end-to-end
  tests against a live GitLab instance.
  Located at [`gitlab-org/gitlab-ce@qa/qa/specs/features/`][instance-level-scenarios].
- **GitLab QA orchestrator** (this project): An orchestration tool that enables 
  running various QA test suites in a simple manner.
- **GitLab QA orchestrated scenarios**: Scenarios where containers are started,
  configured, and execute instance-level scenarios against a running GitLab 
  instance.
  Located at [`gitlab-org/gitlab-qa@lib/gitlab/qa/scenario/test/`][orchestrated-scenarios].

[qa-framework]: https://gitlab.com/gitlab-org/gitlab-ce/blob/master/qa/qa/
[instance-level-scenarios]: https://gitlab.com/gitlab-org/gitlab-ce/blob/master/qa/qa/specs/features/
[orchestrated-scenarios]: https://gitlab.com/gitlab-org/gitlab-qa/blob/master/lib/gitlab/qa/scenario/test/

## Goals and objectives

GitLab consists of multiple pieces configured and packaged by
[GitLab Omnibus](https://gitlab.com/gitlab-org/omnibus-gitlab).

The purpose of the QA end-to-end test suite is to verify that all pieces
integrate well together.

### Testing changes in merge requests before the merge

The ultimate goal is to make it possible to run the QA test suite for any
merge request, even before merging code into the `master` branch.

### We can run tests against any instance of GitLab

GitLab QA is a click-driven, black-box testing tool. We also use it to run
tests against the staging environment, and we strive to make it useful for our 
users as well.

### GitLab QA tests running in the CI/CD environment

Manual steps should not be needed to run the QA test suite.
GitLab QA orchestrator is CI/CD environment native, which means that we should
add new features and tests when we are comfortable with running new code in the
CI/CD environment.

### GitLab QA test failures are reproducible locally

Despite the fact that GitLab QA orchestrator has been built to run in the CI/CD
environment, it is really important to make it easy for developers to reproduce
test failures locally. It is much easier to debug things locally, than in the
CI/CD environment.

To make it easier to reproduce test failures locally we have published the
`gitlab-qa` gem [on rubygems.org](https://rubygems.org/gems/gitlab-qa) and we
are using exactly the same approach to run tests in the CI/CD environment.

It means that using the `gitlab-qa` CLI tool, which orchestrates the test 
environment and runs the GitLab QA test suite, is a reproducible way of running 
tests locally and in the CI/CD environment.

It also means that we cannot have custom code in `.gitlab-ci.yml` to, for
example, start new containers / services.

### Test the installation / deployment process too

We distribute GitLab in a package (like a Debian package or a Docker image) so
we want to test the installation process to ensure that our package is not 
broken.

But we are also working on making GitLab be a cloud native product. This means
that, for example, using Helm becomes yet another installation / deployment 
process that we want to test with GitLab QA.

Considering our goal of being able to test all changes in merge requests, it is
especially important to be able to test our Kubernetes deployments, as that is
essential to scaling our test environments to efficiently handle a large number 
of tests.

## Documentation

All the documentation can be found under [`docs/`](/docs/README.md).

## How do we use it

Currently, we execute the test suite against GitLab Docker images created by 
Omnibus nightly via a pipeline in the [nightly](https://gitlab.com/gitlab-org/quality/nightly) 
project.

We also execute the test suite nightly against our [staging environment](https://staging.gitlab.com)
via a pipeline in the [staging project](https://gitlab.com/gitlab-org/quality/staging).

Finally, we trigger GitLab QA pipelines whenever someone clicks `package-and-qa` manual
action in a merge request.

## How can you use it

The GitLab QA tool is published as a [Ruby Gem](https://rubygems.org/gems/gitlab-qa).

You can install it with `gem install gitlab-qa`. It will expose a `gitlab-qa`
command in your system.

If you want to run the scenarios against your GDK and/or develop them on Mac OS,
please read [Run QA tests against your GDK setup](/docs/run_qa_against_gdk.md)
as there are caveats and things that may work differently.

All the scenarios you can run are described in the
[What tests can be run?](/docs/what_tests_can_be_run.md) documentation.

Note: The GitLab QA tool requires that [Docker](https://docs.docker.com/install/) is installed.

### How to add new scenarios

Scenarios (test cases) and scripts to run them are located in the
[CE](https://gitlab.com/gitlab-org/gitlab-ce/tree/master/qa) and
[EE](https://gitlab.com/gitlab-org/gitlab-ee/tree/master/qa)
repositories under the `qa/` directory, so please also check the documentation 
there.

## Contributing

Please see the [contribution guidelines](CONTRIBUTING.md).
