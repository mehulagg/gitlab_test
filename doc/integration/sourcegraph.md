# Sourcegraph

> [Introduced](https://gitlab.com/gitlab-org/gitlab/merge_requests/16556) in GitLab X.X.

When [Sourcegraph](https://sourcegraph.com) is configured on your GitLab instance, you
will get complete code intelligence functionality (historically provided by the browser
extension) including go-to-definitions and find references working by default for all users.

## Sourcegraph

Before you can enable Sourcegraph code intelligence in GitLab you need to have a
Sourcegraph instance running and configured with your GitLab instance as an external
service.

### Set up your Sourcegraph instance

If you are new to Sourcegraph, head over to the [Sourcegraph installation documentation](https://docs.sourcegraph.com/admin) and get your instance up and running.

### Configure your Sourcegraph instance

1. Navigate to the site admin area in Sourcegraph.
1. [Configure your GitLab external service](https://docs.sourcegraph.com/admin/external_service/gitlab).
You can skip this step if you already have your GitLab repositories searchable in Sourcegraph.
1. Validate that you can search your repositories from GitLab in your Sourcegraph instance by running a test query.
1. Add your GitLab URL to the [`corsOrigin` setting](https://docs.sourcegraph.com/admin/config/site_config#corsOrigin) in your site configuration (e.g. `https://sourcegraph.example.com/site-admin/configuration`).

## GitLab

1. In GitLab, go to **Admin Area > Settings > Integrations**.
1. Exapnd the **Sourcegraph** configuration section.
1. Check the **Enable Sourcegraph** checkbox.
1. Set the Sourcegraph URL to your Sourcegraph instance, e.g. `https://sourcegraph.example.com`.

You should now see code intelligence on your files, without needing the browser
extension installed!
