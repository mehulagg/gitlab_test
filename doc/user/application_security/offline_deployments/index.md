---
type: reference, howto
---

# Offline deployments

This file is intended to describe air-gap deployments.

## Overview
It is possible to run most of the GitLab security scanners when not
connected to the internet, in what is known as an "air-gap" or offline
environment.

GitLab scanners generally will connect to the internet to download the
latest sets of signatures, rules, and patches. When internet access is not
available, a few extra steps are necessary to configure the tools to not do
this and to still function properly.

### Container registries and images
At a high-level, each of the security analyzers are delivered as Docker
containers. When you run a job on an internet-connected GitLab installation,
GitLab checks the GitLab.com-hosted container registry to ensure that you have
the latest versions.

In an air-gapped environment, this must be disabled so that GitLab.com is not
queried. Because the GitLab.com registry is not avaialable, you must update
each of the scanners to either reference a different, internally-hosted registry
or provide access to the individual scanner images somehow.

### Scanner signature and rule updates
When connected to the internet, some scanners will reference public databases
for the latest sets of signatures and rules to check against. In an air-gap,
this is not possible. Depending on the scanner, you must therefore disable
these automatic update checks and either use the databases that they came
with or manually update those databases.

## Specific scanner instructions
Each individual scanner may be slightly different than the steps described
above. You can find more info at each of the pages below.

- [Container scanning offline directions](container_scanning/#running-container-scanning-in-an-offline-air-gapped-installation)
- [Dependency scanning offline directions]()
- [SAST offline directions]()
- [DAST offline directions]()
- [License scanning offline directions]()
