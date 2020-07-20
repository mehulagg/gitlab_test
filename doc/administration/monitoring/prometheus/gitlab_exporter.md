---
stage: Monitor
group: APM
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# GitLab exporter

>- Available since [Omnibus GitLab 8.17](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/1132).
>- Renamed from `GitLab monitor exporter` to `GitLab exporter` in [GitLab 12.3](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/16511).

The [GitLab exporter](https://gitlab.com/gitlab-org/gitlab-exporter) enables you to
measure various GitLab metrics pulled from Redis and the database in Omnibus GitLab
instances.

NOTE: **Note:**
For installations from source you must install and configure it yourself.

To enable the GitLab exporter in an Omnibus GitLab instance:

1. [Enable Prometheus](index.md#configuring-prometheus).
1. Edit `/etc/gitlab/gitlab.rb`.
1. Add, or find and uncomment, the following line, making sure it's set to `true`:

   ```ruby
   gitlab_exporter['enable'] = true
   ```

1. Save the file and [reconfigure GitLab](../../restart_gitlab.md#omnibus-gitlab-reconfigure)
   for the changes to take effect.

Prometheus automatically begins collecting performance data from
the GitLab exporter metrics exposed at `localhost:9168/metrics`.

Note that GitLab Exporter, in additon to /metrics endpoint, also exposes the following endpoints:

/database
/git_process
/process
/sidekiq

All of them combined are making up the /metrics endpoint.

Note that, however, for Omnibus installations, /git_process endpoint is always going to be empty. Metrics
exposed through it (git_pull_time_milliseconds, git_push_time_milliseconds and process_count (for Git processes))
are not configured out-of-the-box for Omnibus installations and are outside of scope for support for now. You are
more than welcome to play around with the exporter configuration on your own though to make them work for your instance.
