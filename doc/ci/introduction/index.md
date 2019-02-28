---
description: "An overview of Continuous Integration, Continuous Delivery, Continuous Deployment, and an introduction to GitLab CI/CD."
---

# Introduction to CI/CD with GitLab

On this document we'll present an overview of Continuous Integration,
Continuous Delivery, Continuous Deployment, and an introduction to
GitLab CI/CD.

<!-- TBA: PM's introductory video? -->

## Introduction to continuous methods

Read below an introduction to continuous methods of software development:

- [Continuous Integration](#continuous-integration)
- [Continuous Delivery](#continuous-delivery)
- [Continuous Deployment](#continuous-deployment)

### Continuous Integration

Consider an application in which its code is stored in a Git
repository in GitLab. Developers push code changes every day,
multiple times a day. For every push to the repository, you
can create a set of scripts to build and test your application
straightaway, decreasing the chance of introducing errors to your app.

This practice is known as [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration);
for every change submitted to a given application, it's built
and tested continuously, making sure the introduced changes
pass all tests, guidelines, and code compliances you established
for your app.

[GitLab itself](https://gitlab.com/gitlab-org/gitlab-ce) is a
practical example of using Continuous Integration as a software
development method. For every push to the project, there's a set
of scripts the code is checked against.

<!-- TBA: illustration -->

### Continuous Delivery

[Continuous Delivery](https://continuousdelivery.com/) is a step
forward after Continuous Integration with which you not only build
and test your application at every code change pushed to your
application's codebase, but, as an additional step, you also
deploy it continuously, but the deployment is triggered manually.

This method ensures the code is checked automatically but requires
someone to manually and strategically trigger the deployment
of the changes.

> Continuous Delivery is a software engineering approach in
which Continuous Integration, automated testing, and automated
deployment capabilities allow software to be developed and
deployed rapidly, reliably and repeatedly with minimal human
intervention.

<!-- TBA: illustration -->

### Continuous Deployment

[Continuous Deployment](https://www.airpair.com/continuous-deployment/posts/continuous-deployment-for-practical-people)
is also a step forward after Continuous Integration, on the light of
Continuous Delivery. The difference is that instead of deploying your
application manually, you set it up so that the deployment is also
triggered automatically.

> Continuous Deployment is a software development practice in which
every code change goes through the entire pipeline and is put into
production automatically, resulting in many production deployments
every day. It does everything that Continuous Delivery does, but
the process is fully automated, with no human intervention at all.

<!-- TBA: illustration -->

## Introduction to GitLab CI/CD

GitLab CI/CD is a powerful tool built into GitLab that allows you
to apply all the continuous methods (Continuous Integration,
Delivery, and Deployment) to your software with no third-party
integration needed.

### How GitLab CI/CD works

To use GitLab CI/CD, all you need is an application hosted in a
Git repository and configure your build, test, and deployment
scripts in a file called [`.gitlab-ci.yml`](../yaml/README.md),
placed at the root of your repository.

In this file, you define the scripts you want to run, include and
cache dependencies, choose what commands you want to run in sequence
and those you want to run in parallel, define where you want to
deploy your app to, choose if you want to run the script automatically
or if you want to trigger it manually. Once you're familiar with
GitLab CI/CD you can add more advanced steps into the configuration file.

To add scripts to that file, you'll need to organize them in a
sequence that suits your application and are in accordance with
the tests you wish to perform. To visualize the process, imagine
that all the scripts you add to the configuration file are the
same as the commands you run on a terminal in your computer.

Once you've added your configuration file `.gitlab-ci.yml` to your
repository, GitLab will identify it and run your scripts with the
tool called [GitLab Runner](https://docs.gitlab.com/runner/), which
works similarly to your terminal.

GitLab CI/CD not only executes the scripts you've set but shows you
what's happening, as you would see on your terminal:

![job running](img/job_running.png)

You create the strategy for your app and GitLab runs the pipeline
for you according to what you've set. Your pipeline status is also
displayed by GitLab:

![pipeline status](img/pipeline_status.png)

At the end, if anything goes wrong, you can easily
[roll back](../environments.md#rolling-back-changes) all the changes:

![rollback button](img/rollback.png)

<!--

## Setting up GitLab CI/CD for the first time

Link to "hello-world" document (to be written).

-->

### Basic CI/CD Workflow

A very simple workflow for using GitLab CI/CD could be:

- Create an issue to discuss an implementation.
- Submit your changes on a merge request in a feature branch.
- Run automated scripts (sequential or parallel).
  - Build, test, and deploy to a staging environment.
  - Preview the changes with Review Apps.
- Get your code reviewed and approved.
- Merge the feature branch into the default branch.
  - Deploy your changes automatically to a production environment.
-  Roll it back if something goes wrong.

GitLab CI/CD is capable of a doing a lot more, but this workflow
exemplifies the ability GitLab has to track the entire process,
without the need of any external tool to deliver your software.
And, most interestingly, you can visualize all the steps through
the GitLab UI.

<img src="../img/cicd_pipeline_infograph.png" alt="pipeline graph" class="image-noshadow">

### GitLab CI/CD feature set

- Easily set your app's entire lifecycle up with [Auto DevOps](../../topics/autodevops/index.md).
- Deploy static websites with [GitLab Pages](../../user/project/pages/index.md).
- Deploy your app to different [environments](../environments.md).
- Preview changes per merge request with [Review Apps](../review_apps/index.md).
- Develop secure and private Docker images with [Container Registry](../../user/project/container_registry.md).
- Install your own [GitLab Runner](https://docs.gitlab.com/runner/).
- [Schedule pipelines](../../user/project/pipelines/schedules.md).
- Check the app vulnerability with [Security Test reports](https://docs.gitlab.com/ee/user/project/merge_requests/#security-reports-ultimate). **[ULTIMATE]**

To see all CI/CD features, navigate back to the [CI/CD index](../README.md).
