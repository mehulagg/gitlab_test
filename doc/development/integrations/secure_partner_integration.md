# Secure Partner Integration - Onboarding Process

If you are looking to integrate into the [Secure Stage](https://about.gitlab.com/direction/secure/), which is integrated into the [GitLab CI/CD Section](https://about.gitlab.com/handbook/product/categories/#cicd-section) of GitLab this page will help you understand how we want the developer experience to flow and also help you to find the correct resources for the technical work associated with [onboarding as a partner](https://about.gitlab.com/partners/integrate/).

## What is the Desired Developer Workflow?

- Developers want to write their code, and not need to leave context to consume feedback and critical data about the item they are working on.
- During the GitLab CI/CD step Developers submit changes via a branch which triggers a pipeline and its associated jobs on this updated code. Then the merge request (MR) is where it is best to review these changes and the corresponding security analyses.
- Jobs serve a variety of purposes, for this feature we are concerned with ones that have Security, Policy, or Compliance implications. The job will report back on its status, and create a [job artifact](https://docs.gitlab.com/ee/user/project/pipelines/job_artifacts.html) as a result.
- Feedback about the findings are shown in the [Merge Request Security Widget](https://docs.gitlab.com/ee/user/project/merge_requests/#security-reports-ultimate)
- A developer may expand and review a summary of the findings in the MR report, and then view more information as needed.
- If the developer needs more information they can click to get more information about the findings. They can then act (see below) as needed.
- If certain policies are put in place for a project, specific findings will require the developer to resolve the finding or get an approval form a specific list of people in order to proceed past this step. Documentation [“Merge request approvals”](https://docs.gitlab.com/ee/user/project/merge_requests/merge_request_approvals.html)
- Results will also show in the [security dashboard](https://docs.gitlab.com/ee/user/application_security/security_dashboard/#gitlab-security-dashboard-ultimate).
- Users can see summary information in the dashboard, view the vulnerability summary (same data as in the pipeline report) and take action as needed (see below).
- Developer Action: However the user arrives at the Vulnerability details, they are presented with additional information and choices.

1. Links This is where we expect partners to link out to their own sites or sources for users to get more data around the findings
1. Create Issue (Confirm finding) - creates an issue to be prioritized into the normal development workflow
1. Add Comment and Dismiss - The comments are where a users can denote items that they have mitigated, accepted, or that are a false positives when they dismiss a finding.
1. Auto-Remediation / Create Merge request - This is offered if a potential solution is offered in the artifact allowing an easy and boring solution for the user to try and continue on. Partners, it is preferable to offer this where possible

## What are the steps to onboard?

1. Read about our [partnerships](https://about.gitlab.com/partners/integrate/).
   1. [Create an issue](https://gitlab.com/gitlab-com/alliances/alliances/issues/new?issuable_template=new_partner)
   1. Get a test account - [GitLab.com Gold Subscription Sandbox Request](https://about.gitlab.com/partners/integrate/#gitlabcom-gold-subscription-sandbox-request) or [EE Developer License](https://about.gitlab.com/partners/integrate/#requesting-ee-dev-license-for-rd)
1. Provide a pipeline job to integrate into GitLab
   1. You need to integrate into CI using [pipeline jobs](https://docs.gitlab.com/ee/development/pipelines.html)
1. Create a report artifact with your pipeline jobs
   1. About [job report artifact](https://docs.gitlab.com/ee/ci/yaml/README.html#artifactsreports)
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
      1. In [Merge Request Security Report](https://docs.gitlab.com/ee/user/project/merge_requests/#security-reports-ultimate)
         1. [MR Security Report data flow](https://gitlab.com/snippets/1910005#merge-request-view) *can we improve on this, where should it live?*
      1. [Browse Artifact](https://docs.gitlab.com/ee/user/project/pipelines/job_artifacts.html#browsing-artifacts)
      1. In [Security Dashboard](https://docs.gitlab.com/ee/user/application_security/security_dashboard/)
         1. [Dashboard data flow](https://gitlab.com/snippets/1910005#project-and-group-dashboards) *can we improve on this, where should it live?*
1. Optional: Auto Remediation
   1. If you specified a `remediations` in your artifact, it will be proposed through [auto remediation](https://docs.gitlab.com/ee/user/application_security/index.html#solutions-for-vulnerabilities-auto-remediation)
   1. Example on how to populate that field *this needs to be improved to include full example <https://docs.gitlab.com/ee/user/application_security/dependency_scanning/#reports-json-format> and if all fields are optional or required*
1. Optional: Interacting with vulnerabilities
   1. Users will be able to interact with the findings from your artifact within their workflow. They will be able to dismiss, or accept and create a backlog issue.
   1. If you wish to automatically create Issues without user interaction you may use the [issue API](https://docs.gitlab.com/ee/api/issues.html)
      1. This will be replaced by [Standalone Vulnerabilities](https://gitlab.com/groups/gitlab-org/-/epics/634) in the future
1. Demo the integration to GitLab
   1. After you have tested and are ready to demo your integration please [reach out](https://about.gitlab.com/partners/integrate/). If you skip this step you won’t be able to do supported marketing.
1. Supported marketing
   1. Work with our [partner team](https://about.gitlab.com/partners/integrate/) to support your go to market as appropriate
   1. Example: Get linked on our Security [Partner page](https://about.gitlab.com/partners/#security)
   1. Example: [Unfiltered blog post](https://about.gitlab.com/handbook/marketing/blog/unfiltered/)
   1. Example: Co-branded webinar
   1. Example: Co-branded whitepaper
1. Troubleshooting
   1. TBD
