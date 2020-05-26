# Job management / scheduling

In a simple pipeline, it might be reasonable to have all jobs run in all cases. In
more complicated projects, it's important to clearly define for which cases each job
should run. This ensures the optimal use of resources, as you are not adding jobs
to pipelines when not needed.

The primary way to manage job inclusion or exclusion from pipelines is with the `rules`
keyword. This can also be done with the legacy `only` and `except` keywords.

The **order** that jobs are executed in a pipeline is a separate configuration issue,
controlled by:

- [Stages](../yaml/README.md#stages), for linear stage-by-stage execution.
- [Directed Acyclic Graphs (DAG)](../directed_acyclic_graph/index.md), allowing jobs
  to execute earlier than their defined stage.

## Differences between `rules` and `only` / `except`

`rules` and `only`/`except` cannot be combined in the same job. Separate jobs
in the same pipeline can use either method, but if a single pipeline mixes these methods,
it risks confusing or unexpected behavior.

`rules` key points:

- The `rules` keyword manages jobs based on a series of statements, which are checked
  *in order*, to determine if a job is added to a pipeline:
  - `if` statements make use of [predefined CI/CD environment variables](../variables/predefined_variables.md),
    as well as [custom CI/CD environment variables](../variables/README.md#custom-environment-variables),
    to include or exclude jobs based on variable values. `if` statements can be combined
    together with `&&` (and) and `||` (or) operators for more precise configuration.
  - `changes` statements will include or exclude jobs in pipelines when specific files
    are changed.
  - `exists` statements will include or exclude jobs in pipelines when specific files
    exist in the repository.
- Statements can make use of other keywords for more complicated behavior:
  - `when`: The same job could be `when: manual` in one pipeline, `when: on_failure` in another,
    and so on. With `when: delayed`, the `start_in` parameter must also be defined.
  - `allow_failure`: Jobs can be configured to allow or prevent a pipeline from continuing
    to execute when the job fails. With `rules`, `when: manual` jobs default to `allow_failure: false`
    and will block execution of a pipeline unless `allow_failure: true` is explicitly defined.
- Job inclusion and exclusion are all controlled with the single `rules` keyword.
- Since `rules` statements are checked in order, later statements are not checked if an earlier
  statement matches. This enables the creation of a hierarchical-style configuration,
  which means specific exclusion behavior (like with `except`), does not usually need
  to be explicitly defined.

`only` and `except` key points:

- The legacy `only` and `except` keywords are more commonly used with a limited
  [set of special keywords](#migration-from-onlyexcept-to-rules), but can also make
  use of environment variables, like `rules`.
- `only` and `except` can make use of the `changes` keyword, which includes jobs in pipelines
  when specific files are changed.
- Job inclusion is controlled by `only`, and job exclusion is controlled by `except`.
- The `only` and `except` configuration must be evaluated in its entirety to determine
  whether or not a job is added to a pipeline.
- `when` can not be used within `only` and `except` configuration. Without `rules`,
  each job can only have a single `when`.

## Order of operations with `rules`

The statements defined within `rules` are checked in order, from top to bottom. If any
statement resolves as true, the job will be added to the pipeline with the parameters (`when`,
`allow_failure`) defined within that statement.

If not defined, jobs default to `when: on_success` and `allow_failure: false`.

The simplest case is to have a single statement:

```yaml
job1A:
  script:
    - echo "Job1A does a specific task"
  rules:
    - if: $CI_MERGE_REQUEST_ID
```

This adds `job1A` to merge request pipelines, with the default `when: on_success`
and `allow_failure: false`. The job is not added to pipelines in any other case.

When more statements are added to `rules`, they are evaluated in order until either
a match is found, or no matches are found (so the job does not get added to any pipeline).

For example:

```yaml
job2:
  script:
    - echo "Job2 does a specific task"
  rules:
    - if: '$CI_COMMIT_BRANCH == "master"'
    - if: '$CI_COMMIT_BRANCH =~ /special-branch-name-pattern/'
      when: never
    - if: $CI_COMMIT_BRANCH
      when: manual
      allow_failure: true
```

In the example above, the 3 statements can be translated into 4 steps:

1. If the commit branch is `master`, add the job to the pipeline, with the default
   `when: on_success` and `allow_failure: false`.
1. If the previous statement is not true, but the pipeline is for a branch that matches
   a specific regex pattern, do **not** add the job to the pipeline.
1. If the previous statements are not true, but the pipeline is for changes to any
   other branch, add the job to the pipeline as a manual job (`when: manual`), and
   `allow_failure: true` (to allow the pipeline to continue running even if the manual
   job is not triggered).
1. If none of the statements evaluate to true, then do **not** add the job in any other
   pipelines.

It is also possible to define a final clause that applies in the last step, if
none of the previous statements evaluate to true.

For example:

```yaml
job3:
  script:
    - echo "Job3 does a specific task"
  rules:
    - if: $CI_COMMIT_TAG
    - changes:
      - directory/filename.ext
    - exists:
      - directory2/filename2.ext
    - when: on_success
```

This translates to:

1. If the pipeline is for a new tag, add the job with the default
   `when: on_success` and `allow_failure: false`.
1. If `filename.ext` was changed in the branch, add the job with the defaults.
1. If `filename2.ext` exists in the branch, add the job with the defaults.
1. In **all other** cases, add the job to **all pipelines**. This always evaluates
   to true if reached.

CAUTION: **Caution::**
The example above could cause duplicated pipelines, as a single event can trigger
multiple pipelines. For example, a push to a branch that is the source for a merge
request will cause this job to be added to both a branch pipeline and a merge request
pipeline.

## Migration from `only/except` to `rules`

Examples of `if:` statements for `rules`, and the `only`/`except` equivalents:

| `only` or `except`             | `rules`                                      | Notes                                                                                                                                                                                    |
|--------------------------------|----------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `only: merge_requests`         | `if: $CI_MERGE_REQUEST_ID`                   | Adds job to [merge request pipelines](../merge_request_pipelines/index.md).                                                                                                              |
| `only: branches`               | `if: $CI_COMMIT_BRANCH`                      | Adds job to pipelines for changes to any branch.                                                                                                                                         |
| `only: master`                 | `if: '$CI_COMMIT_BRANCH == "master"'`        | Adds job to pipelines for changes to the `master` branch.                                                                                                                                |
| `except: master`               | `if: '$CI_COMMIT_BRANCH != "master"'`        | Adds job to pipelines if the changes are to any branch except master.                                                                                                                                      |
| `only: /regex-pattern/`        | `if: '$CI_COMMIT_BRANCH =~ /regex-pattern/'` | Adds job to pipelines for changes to all branches that match the regex pattern. For example, branches with `/regex-pattern/` will match, such as `regex-pattern-1` or `a-regex-pattern`. |
| `only: tags`                   | `if: $CI_COMMIT_TAG`                         | Adds job to pipelines for tags.                                                                                                                                                          |
| `only: schedules`              | `if: '$CI_PIPELINE_SOURCE == "schedule"'`    | Adds job to scheduled pipelines.                                                                                                                                                         |
| `only: api`                    |                                              | Adds job to pipelines triggered by API.                                                                                                                                                  |
| `only: external`               |                                              | Adds job to pipelines triggered by external CI services.                                                                                                                                 |
| `only: pipelines`              |                                              | Adds job to pipelines triggered by multi-project triggers, using the API with `CI_JOB_TOKEN`.                                                                                            |
| `only: pushes`                 |                                              | Adds job to pipelines triggered by `git push` events.                                                                                                                                    |
| `only: triggers`               |                                              | Adds job to pipelines triggered with a trigger token.                                                                                                                                    |
| `only: web`                    |                                              | Adds job to pipelines triggered by using the **Run pipeline** button in the GitLab UI (**CI/CD > Pipelines**).                                                                           |
| `only: external_pull_requests` |                                              | Adds job to pipelines triggered by [external pull requests](../ci_cd_for_external_repos/index.md#pipelines-for-external-pull-requests).                                                  |
| `only: chat`                   |                                              | Adds job to pipelines triggered by [GitLab ChatOps](../chatops/README.md).                                                                                                               |

## Types of pipelines

There are multiple types of pipelines that can be triggered:

- **Branch pipelines**: Run in the context of a branch. Each push to a branch will trigger
  a new pipeline.
- **Merge request pipelines**: Run in the context of a merge request. If used at the
  same time as branch pipelines, may result in two pipelines at the same time. One
  for the branch, one for the merge request using the same branch as its source.
  - **Merged results pipelines**: If enabled, pipelines run
- **Scheduled pipelines**: Run only at scheduled times, and never triggered by changes.
- **Triggered pipelines**: Pipelines can also be triggered by:
  - cross-project pipelines
  - parent-child pipelines
  - API calls
  - external CI services
  - the **Run pipeline** button in the GitLab UI.
  - external pull requests from GitHub
  - [GitLab ChatOps](../chatops/README.md)

These pipelines run independently in parallel, and can even be triggered by the same
event, which may cause seemingly identical pipelines.

## `when:` clauses with `rules:`

Note difference between `on_success` (default), vs `always`.

- `on_success`
- `always`
- `manual`
- `never`
