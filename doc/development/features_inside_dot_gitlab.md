# Features inside the `.gitlab/` directory

We have implemented standard features that depend on configuration files in the `.gitlab/` directory. You can find `.gitlab/` in various GitLab repositories.
When implementing new features, please refer to these existing features to avoid conflicts:

- [Custom Dashboards](../operations/metrics/dashboards/index.md#add-a-new-dashboard-to-your-project): `.gitlab/dashboards/`.
- [Issue Templates](../user/project/description_templates.md#creating-issue-templates): `.gitlab/issue_templates/`.
- [Merge Request Templates](../user/project/description_templates.md#creating-merge-request-templates): `.gitlab/merge_request_templates/`.
- [GitLab Kubernetes Agents](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/configuration_repository.md#layout): `.gitlab/agents/`.
- [CODEOWNERS](../user/project/code_owners.md#how-to-set-up-code-owners): `.gitlab/CODEOWNERS`.
- [Route Maps](../ci/review_apps/#route-maps): `.gitlab/route-map.yml`.
- [Customize Auto DevOps Helm Values](../topics/autodevops/customize.md#customize-values-for-helm-chart): `.gitlab/auto-deploy-values.yaml`.
- [GitLab managed apps CI/CD](../user/clusters/applications.md#usage): `.gitlab/managed-apps/config.yaml`.
- [Insights](../user/project/insights/index.md#configure-your-insights): `.gitlab/insights.yml`.
- [Service Desk Templates](../user/project/service_desk.md#using-customized-email-templates): `.gitlab/service_desk_templates/`.
- [Web IDE](../user/project/web_ide/#web-ide-configuration-file): `.gitlab/.gitlab-webide.yml`.
