---
description: "Merge Request Analytics help you understand the efficiency of your code review process, and the productivity of your team." # Up to ~200 chars long. They will be displayed in Google Search snippets. It may help to write the page intro first, and then reuse it here.
stage: Manage
group: Analytics
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Merge Request Analytics **(STARTER)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/229045) in [GitLab Starter](https://about.gitlab.com/pricing/) 13.3.

Merge Request Analytics helps you understand the efficiency of your code review process, and the productivity of your team.

## Overview

Merge Request Analytics displays information that will help you evaluate the efficiency and productivity of your merge request process.

The Throughput chart shows the number of completed merge requests, by month. Merge request throughput is
a common measure of productivity in software engineering. Although imperfect, the average throughput can
be a meaningful benchmark of your team's overall productivity.

To access Merge Request Analytics, from your project's menu, go to **Analytics > Merge Request**.

## Use cases

This feature is designed for [development team leaders](https://about.gitlab.com/handbook/marketing/product-marketing/roles-personas/#delaney-development-team-lead)
and others who want to understand broad patterns in code review and productivity.

You can use Merge Request Analytics to expose when your team is most and least productive, and
identify improvements that might substantially accelerate your development cycle.

Merge Request Analytics could be used when:

- You want to know if you were more productive this month than last month, or 12 months ago.
- You want to drill into low- or high-productivity months to understand the work that took place.

## Visualizations and data

The following visualizations and data are available, representing all merge requests that were merged in the past 12 months.

### Throughput chart

The throughput chart shows the number of completed merge requests per month.

![Throughput chart](img/mr_throughput_chart_v13_3.png "Merge Request Analytics - Throughput chart showing merge requests merged in the past 12 months")

### Throughput table

Data table displaying a maximum of the 100 most recent merge requests merged for the time period.

![Throughput table](img/mr_throughput_table_v13_3.png "Merge Request Analytics - Throughput table listing the 100 merge requests most recently merged")

## Permissions

The **Merge Request Analytics** feature can be accessed only:

- On [Starter](https://about.gitlab.com/pricing/) and above.
- By users with [Reporter access](../permissions.md) and above.

## Enable and disable related feature flags

Merge Request Analytics is disabled by default but can be enabled using the following
[feature flag](../../development/feature_flags/development.md#enabling-a-feature-flag-locally-in-development):

- `project_merge_request_analytics`

A GitLab administrator can:

- Enable this feature by running the following command in a Rails console:

  ```ruby
  Feature.enable(:project_merge_request_analytics)
  ```
