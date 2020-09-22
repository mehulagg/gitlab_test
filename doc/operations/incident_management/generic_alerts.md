---
stage: Monitor
group: Health
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Generic alerts integration

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/13203) in [GitLab Ultimate](https://about.gitlab.com/pricing/) 12.4.
> - [Moved](https://gitlab.com/gitlab-org/gitlab/-/issues/42640) to [GitLab Core](https://about.gitlab.com/pricing/) in 12.8.

GitLab can accept alerts from any source via a generic webhook receiver.
When you set up the generic alerts integration, a unique endpoint will
be created which can receive a payload in JSON format, and will in turn
create an issue with the payload in the body of the issue. You can always
[customize the payload](#customizing-the-payload) to your liking.

The entire payload will be posted in the issue discussion as a comment
authored by the GitLab Alert Bot.

NOTE: **Note:**
In GitLab versions 13.1 and greater, you can configure
[External Prometheus instances](../metrics/alerts.md#external-prometheus-instances)
to use this endpoint.

## Setting up generic alerts

To obtain credentials for setting up a generic alerts integration:

- Sign in to GitLab as a user with maintainer [permissions](../../user/permissions.md) for a project.
- Navigate to the **Operations** page for your project, depending on your installed version of GitLab:
  - *In GitLab versions 13.1 and greater,* navigate to **Settings > Operations** in your project.
  - *In GitLab versions prior to 13.1,* navigate to **Settings > Integrations** in your project. GitLab will display a banner encouraging you to enable the Alerts endpoint in **Settings > Operations** instead.
- Click **Alerts endpoint**.
- Toggle the **Active** alert setting to display the **URL** and **Authorization Key** for the webhook configuration.

## Customizing the payload

You can customize the payload by sending the following parameters. All fields other than `title` are optional:

| Property | Type | Description |
| -------- | ---- | ----------- |
| `title` | String | The title of the incident. Required. |
| `description` | String | A high-level summary of the problem. |
| `start_time` | DateTime | The time of the incident. If none is provided, a timestamp of the issue will be used. |
| `end_time` | DateTime | For existing alerts only. When provided, the alert is resolved and the associated incident is closed. |
| `service` | String | The affected service. |
| `monitoring_tool` | String |  The name of the associated monitoring tool. |
| `hosts` | String or Array | One or more hosts, as to where this incident occurred. |
| `severity` | String | The severity of the alert. Must be one of `critical`, `high`, `medium`, `low`, `info`, `unknown`. Default is `critical`. |
| `fingerprint` | String or Array | The unique identifier of the alert. This can be used to group occurrences of the same alert. |
| `gitlab_environment_name` | String | The name of the associated GitLab [environment](../../ci/environments/index.md). This can be used to associate your alert to your environment. |

You can also add custom fields to the alert's payload. The values of extra parameters
are not limited to primitive types, such as strings or numbers, but can be a nested
JSON object. For example:

```json
{ "foo": { "bar": { "baz": 42 } } }
```

TIP: **Payload size:**
Ensure your requests are smaller than the [payload application limits](../../administration/instance_limits.md#generic-alert-json-payloads).

Example request:

```shell
curl --request POST \
  --data '{"title": "Incident title"}' \
  --header "Authorization: Bearer <authorization_key>" \
  --header "Content-Type: application/json" \
  <url>
```

The `<authorization_key>` and `<url>` values can be found when [setting up generic alerts](#setting-up-generic-alerts).

Example payload:

```json
{
  "title": "Incident title",
  "description": "Short description of the incident",
  "start_time": "2019-09-12T06:00:55Z",
  "service": "service affected",
  "monitoring_tool": "value",
  "hosts": "value",
  "severity": "high",
  "fingerprint": "d19381d4e8ebca87b55cda6e8eee7385",
  "foo": {
    "bar": {
      "baz": 42
    }
  }
}
```

## Triggering test alerts

> [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/3066) in GitLab Core in 13.2.

After a [project maintainer or owner](#setting-up-generic-alerts)
[configures generic alerts](#setting-up-generic-alerts), you can trigger a
test alert to confirm your integration works properly.

1. Sign in as a user with Developer or greater [permissions](../../user/permissions.md).
1. Navigate to **Settings > Operations** in your project.
1. Click **Alerts endpoint** to expand the section.
1. Enter a sample payload in **Alert test payload** (valid JSON is required).
1. Click **Test alert payload**.

GitLab displays an error or success message, depending on the outcome of your test.

## Automatic grouping of identical alerts **(PREMIUM)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/214557) in [GitLab Premium](https://about.gitlab.com/pricing/) 13.2.

In GitLab versions 13.2 and greater, GitLab groups alerts based on their payload.
When an incoming alert contains the same payload as another alert (excluding the
`start_time` and `hosts` attributes), GitLab groups these alerts together and
displays a counter on the
[Alert Management List](./incidents.md)
and details pages.

If the existing alert is already `resolved`, then a new alert will be created instead.

![Alert Management List](./img/alert_list_v13_1.png)
