---
stage: Monitor
group: APM
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Troubleshooting monitoring dashboards

## "No data found" error on Metrics dashboard page

If the "No data found" screen continues to appear, it could be due to:

- No successful deployments have occurred to this environment.
- Prometheus does not have performance data for this environment, or the metrics
  are not labeled correctly. To test this,
  [connect to the Prometheus server](../../../development/prometheus.md#access-the-ui-of-a-prometheus-managed-application-in-kubernetes) and
  [run a query](../integrations/prometheus_library/kubernetes.md#metrics-supported), replacing the `ci_environment_slug` variable with the name of your environment.
- You may need to re-add the GitLab predefined common metrics. This can be done by running the [import common metrics Rake task](../../../administration/raketasks/maintenance.md#import-common-metrics).
