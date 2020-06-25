---
stage: Configure
group: Configure
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Cluster Cost Management

## Cost insights

GitLab support cluster cost insights using kubecost's `cost-model` and specialized dashboards.

### Setting up

See the `cost-model` license for details and possible restrictions.

1. Deploy as a pod: https://github.com/kubecost/cost-model/blob/master/deploying-as-a-pod.md
1. Create custom metric on an Operations dashboard
