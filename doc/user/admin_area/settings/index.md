---
type: index
---

# Admin Area settings **(CORE ONLY)**

In **Admin Area > Settings**, you can find most of the settings that are accessible
from within GitLab itself, and available to self hosted GitLab instance administrators.

All the sections this in area are listed below.

## General

The default page for admin area settings, which you can access by going to **Admin Area > Settings**.
If you are already in a different section of the Admin Area settings, you can click on
**General** within the settings list. It contains settings for:

- [Visibility and access controls](visibility_and_access_controls.md)
- [Account and limit](account_and_limit_settings.md) **(STARTER)**
- [Diff limits](../diff_limits.md)
- [Sign-up restrictions](sign_up_restrictions.md)
- [Sign in restrictions](sign_in_restrictions.md)
- [Terms of Service and Privacy Policy](terms.md)
- [External Authentication](external_authorization.md#configuration)
- Web terminal (missing)
- Web IDE (missing)

## Integrations

- [Elasticsearch](../../../integration/elasticsearch.md#enabling-elasticsearch)
- [PlantUML](../../../administration/integration/plantuml.md#gitlab)
- [Slack application](../../../user/project/integrations/gitlab_slack_application.md#configuration) **(FREE ONLY)** NOT AVAILABLE IN SELF HOSTED!!
- [Third party offers](third_party_offers.md)
- [Snowplow](../../../development/event_tracking/#enabling-tracking)

## Repository

- [Repository mirror](visibility_and_access_controls.md#allow-mirrors-to-be-set-up-for-projects)
- [Repository storage](../../../administration/repository_storage_types.md#how-to-migrate-to-hashed-storage)
- Repository maintenance ([repository checks](../../../administration/repository_checks.md) and [repository housekeeping](../../../administration/housekeeping.md))
- [Repository static objects](../../../administration/static_objects_external_storage.md)

## Templates **(PREMIUM ONLY)**

- Templates - WAS -> [Custom templates repository](instance_template_repository.md) **(PREMIUM)**
- [Custom project templates](../custom_project_templates.md)

## CI/CD

- [Continuous Integration and Deployment](continuous_integration.md)
- [Required pipeline configuration](continuous_integration.md#required-pipeline-configuration-premium-only) **(PREMIUM ONLY)**

## Reporting

- Spam and Anti-bot Protection (missing)
- Abuse reports (missing)

## Metrics and profiling

- [Metrics - Influx](../../../administration/monitoring/performance/gitlab_configuration.md)
- [Metrics - Prometheus](../../../administration/monitoring/prometheus/gitlab_metrics.md)
- [Metrics - Grafana](../../../administration/monitoring/performance/grafana_configuration.md#integration-with-gitlab-ui)
- [Profiling - Performance bar](../../../administration/monitoring/performance/performance_bar.md#enable-the-performance-bar-via-the-admin-panel)
- [Usage statistics](usage_statistics.md)
- Pseudonymizer data collection (missing) **(ULTIMATE)**

## Network

- [Performance optimization](../../../administration/operations/fast_ssh_key_lookup.md#setting-up-fast-lookup-via-gitlab-shell)
- [User and IP rate limits](user_and_ip_rate_limits.md)
- [Help messages for the `/help` page and the login page](help_page.md)
- [Push event activities limit and bulk push events](push_event_activities_limit.md)
- [Outbound requests](../../../security/webhooks.md)
- [Protected Paths](protected_paths.md)

## Geo

- GitLab Geo (missing)

## Preferences

- [Email](email.md)
- [Help page](../../../customization/help_message.md)
- Pages - [Not all settings here](../../../administration/pages/index.md#custom-domain-verification)
- [Real-time features](../../../administration/polling.md)
- Gitaly (missing)
- Localization - (partially below, partially linked) [time tracking](../../../workflow/time_tracking.md#limit-displayed-units-to-hours-core-only)

NOTE: **Note:**
You can change the [first day of the week](../../profile/preferences.md) for the entire GitLab instance
in the **Localization** section of **Admin Area > Settings > Preferences**.

## GitLab.com Admin Area settings

Most of the settings under the Admin Area change the behavior of the whole
GitLab instance. For GitLab.com, the admin settings are available only for the
GitLab.com administrators, and the parameters can be found in the
[GitLab.com settings](../../gitlab_com/index.md) documentation.
