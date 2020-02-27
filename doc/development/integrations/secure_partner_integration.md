# Secure Partner Integration - Onboarding Process

If you want to integrate with the [Secure Stage](https://about.gitlab.com/direction/secure/) (which
is integrated with the [GitLab CI/CD Section](https://about.gitlab.com/handbook/product/categories/#cicd-section)),
this page helps you understand the desired developer workflow and helps you find the correct
resources for the technical work associated with [onboarding as a partner](https://about.gitlab.com/partners/integrate/).

## What is the Desired Developer Workflow?

- Developers want to write code without leaving that context to consume feedback and critical data
  about the item they are working on.
- During the GitLab CI/CD step, developers submit changes via a branch which triggers a pipeline and
  associated jobs on the updated code. Then the developer creates a merge request (MR) where these
  changes and corresponding security analysis can be reviewed.
- Jobs serve a variety of purposes. For this feature, we are concerned with ones that have security,
  policy, or compliance implications. The job reports back on its status and creates a
  [job artifact](https://docs.gitlab.com/ee/user/project/pipelines/job_artifacts.html) as a result.
- The [Merge Request Security Widget](https://docs.gitlab.com/ee/user/project/merge_requests/#security-reports-ultimate) displays feedback on the findings.
- A developer may expand and review a summary of the findings in the MR report, and then view more
  information as needed.
- A developer can click to get more information about the findings, and then act as needed.
- If certain policies (such as [merge request approvals](https://docs.gitlab.com/ee/user/project/merge_requests/merge_request_approvals.html))
  are in place for a project, developers must resolve specific findings or get an approval from a
  specific list of people.
- The [security dashboard](https://docs.gitlab.com/ee/user/application_security/security_dashboard/#gitlab-security-dashboard-ultimate)
  also shows results.
- Users can see summary information in the dashboard, view the vulnerability summary (the same data
  as in the pipeline report), and take action as needed (see below).
- However the developer arrives at the vulnerability details, they are presented with additional
  information and choices on next steps:
    1. Links: Partners can link out to their own sites or sources for users to get more data around
       the findings.
    1. Create Issue (Confirm finding): Creates an issue to be prioritized in the normal development
       workflow.
    1. Add Comment and Dismiss: When dismissing a finding, users can comment to note items that they
       have mitigated or accepted, or that are false positives.
    1. Auto-Remediation / Create Merge Request: A potential solution is offered in the artifact,
       allowing an easy and boring solution for the user. It is preferable to offer this where
       possible.

## How to onboard

1. Read about our [partnerships](https://about.gitlab.com/partners/integrate/).
   1. [Create an issue](https://gitlab.com/gitlab-com/alliances/alliances/issues/new?issuable_template=new_partner)
   1. Get a test account - [GitLab.com Gold Subscription Sandbox Request](https://about.gitlab.com/partners/integrate/#gitlabcom-gold-subscription-sandbox-request) or [EE Developer License](https://about.gitlab.com/partners/integrate/#requesting-ee-dev-license-for-rd)
1. Provide a pipeline job to integrate into GitLab
   1. You need to integrate into CI using [pipeline jobs](https://docs.gitlab.com/ee/development/pipelines.html)
1. Create a report artifact with your pipeline jobs
   1. Detailed [technical directions](secure.md) for this step.
   1. About [job report artifacts](https://docs.gitlab.com/ee/ci/yaml/README.html#artifactsreports)
   1. About [job artifacts](https://docs.gitlab.com/ee/user/project/pipelines/job_artifacts.html) in general.
   1. Your report artifact must be in one of our currently supported formats. General documentation about the reports is available in the [Secure Reports](https://docs.gitlab.com/ee/development/integrations/secure/#report) page.
      1. [SAST report](https://docs.gitlab.com/ee/user/application_security/sast/#reports-json-format)
      1. [Dependency Scanning report](https://docs.gitlab.com/ee/user/application_security/dependency_scanning/#reports-json-format)
      1. [Container Scanning](https://docs.gitlab.com/ee/user/application_security/container_scanning/index.html#reports-json-format)
      1. [Example secure job definition that also defines the artifact created](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Security/Container-Scanning.gitlab-ci.yml)
      1. Did you need a new kind of scan/report? [Create an issue here](https://gitlab.com/gitlab-org/gitlab/issues/new#) and add label `devops::secure`
   1. Additional fields in secure reports
      1. We are working to define and add an area to make it more clear what software identified findings in [issue 36147](https://gitlab.com/gitlab-org/gitlab/issues/36147) if you would like to comment.
   1. Once the job is completed (which generates the artifact in the working directory of the job) the data can now be seen:
      1. In ther [Merge Request Security Report](https://docs.gitlab.com/ee/user/project/merge_requests/#security-reports-ultimate)
         1. [MR Security Report data flow](https://gitlab.com/snippets/1910005#merge-request-view)
      1. While [browsing Job Artifact](https://docs.gitlab.com/ee/user/project/pipelines/job_artifacts.html#browsing-artifacts)
      1. In the [Security Dashboard](https://docs.gitlab.com/ee/user/application_security/security_dashboard/)
         1. [Dashboard data flow](https://gitlab.com/snippets/1910005#project-and-group-dashboards)
1. Optional: Provide a way to interact with results as Vulnerabilities
   1. Users will be able to interact with the findings from your artifact within their workflow. They will be able to dismiss them or accept and create a backlog issue.
   1. If you wish to automatically create Issues without user interaction you may use the [issue API](https://docs.gitlab.com/ee/api/issues.html)
      1. This will be replaced by [Standalone Vulnerabilities](https://gitlab.com/groups/gitlab-org/-/epics/634) in the future
1. Optional: Provide Auto Remediation steps
   1. If you specified `remediations` in your artifact, it will be proposed through [auto remediation](https://docs.gitlab.com/ee/user/application_security/index.html#solutions-for-vulnerabilities-auto-remediation)
1. Demo the integration to GitLab
   1. After you have tested and are ready to demo your integration please [reach out](https://about.gitlab.com/partners/integrate/). If you skip this step you won’t be able to do supported marketing.
1. Begin doing supported marketing
   1. Work with our [partner team](https://about.gitlab.com/partners/integrate/) to support your go to market as appropriate
   1. Example: Get linked on our Security [Partner page](https://about.gitlab.com/partners/#security)
   1. Example: [Unfiltered blog post](https://about.gitlab.com/handbook/marketing/blog/unfiltered/)
   1. Example: Co-branded webinar
   1. Example: Co-branded whitepaper
1. Troubleshooting
   1. Create an issue to discuss with us further if you have any issues.
