# Enable GitLab's hidden features

Some features might be released in beta version, so they could be behind a
feature flag.

## Enabling or disabling a feature flag

To enable a feature flag:

1. SSH into the server where GitLab is installed.
1. Enter the Rails console:

   ```sh
   ## For Omnibus GitLab
   sudo gitlab-rails console

   ## For installations from source
   cd /home/git/gitlab
   sudo -u git -H bin/rails console RAILS_ENV=production
   ```

1. Enable the feature flag:

   ```ruby
   Feature.enable(:feature_flag_name)
   ```

1. You can now quit the Rails console, no need to restart or reconfigure GitLab.

Similarly, to disable a feature flag, follow the same steps as before, and in
the Rails console, run:

```ruby
Feature.disable(:feature_flag_name)
```

To check if a feature flag is enabled:

```ruby
Feature.enabled?(:feature_flag_name)
```

It should return `true`.

## Available feature flags

The following feature flags are available.

### `approval_rules` **(STARTER)**

| Introduced in | Enabled by default | Removed in | Description |
| ------------- | ------------------ | ---------- | ----------- |
| 11.8          | No                 | 12.0       | Enables the new interface of [Merge Requests Approvals](../user/project/merge_requests/merge_request_approvals.md). Prior to GitLab 12.0, the new interface shown on merge requests approvals was not enabled by default. |

Enable the feature flag in a Rails console:

```ruby
Feature.enable(:approval_rules)
```

### `cycle_analytics` **(PREMIUM)**

| Introduced in | Enabled by default | Removed in | Description |
| ------------- | ------------------ | ---------- | ----------- |
| 12.3          | No                 | -          | Enables the [Cycle Analytics](../user/analytics/cycle_analytics.md) at the group level. |

Enable the feature flag in a Rails console:

```ruby
Feature.enable(:cycle_analytics)
```

### `ingress_modsecurity`

| Introduced in | Enabled by default | Removed in | Description |
| ------------- | ------------------ | -----------| ----------- |
| 12.3          | No                 | -          | Enables the [Modsecurity Application Firewall](../user/clusters/applications.md#modsecurity-application-firewall) in your Kubernetes clusters. There is a small performance overhead by enabling this, so if this is considered significant for your application, you can disable the feature flag. Once disabled, you must [uninstall](../user/clusters/applications.md#uninstalling-applications) and reinstall your Ingress application for the changes to take effect. |

Enable the feature flag in a Rails console:

```ruby
Feature.enable(:ingress_modsecurity)
```

### `issue_zoom_integration`

| Introduced in | Enabled by default | Removed in | Description |
| ------------- | ------------------ | ---------- | ----------- |
| 12.3          | No                 | 12.4       | Enables the `/zoom` and `/remove_zoom` [quick actions](../user/project/quick_actions.md). The feature flag will be removed and [available by default in 12.4](https://gitlab.com/gitlab-org/gitlab/issues/32133)). |

Enable the feature flag in a Rails console:

```ruby
Feature.enable(:issue_zoom_integration)
```

### `phabricator_import`

| Introduced in | Enabled by default | Removed in | Description |
| ------------- | ------------------ | ---------- | ----------- |
| 12.0          | No                 | -          | Enables the [Phabricator import](../user/project/import/phabricator.md). While this feature is incomplete, a feature flag is required to enable it so that we can gain early feedback before releasing it for everyone. |

1. Enable the feature flag in a Rails console:

   ```ruby
   Feature.enable(:phabricator_import)
   ```

1. Enable Phabricator as an [import source](../user/admin_area/settings/visibility_and_access_controls.md#import-sources) in the Admin area.

### `productivity_analytics` **(PREMIUM)**

| Introduced in | Enabled by default | Removed in | Description |
| ------------- | ------------------ | ---------- | ----------- |
| 12.3          | No                 | -          | Enables the [Productivity Analytics](../user/analytics/productivity_analytics.md).

Enable the feature flag in a Rails console:

```ruby
Feature.enable(:productivity_analytics)
```

### `scim_group`

| Introduced in | Enabled by default | Removed in | Description |
| ------------- | ------------------ | ---------- | ----------- |
|               |                    |            |             |
