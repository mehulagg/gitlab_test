# Job management / scheduling

## `if:` order of operations with `rules`

- First match
- If no match, last item is true. Careful with this, may run jobs more often than desired.

## Migrations from `only/except` to `rules`

Examples of `if:` clauses for `rules`, and the `only`/`except` equivalents:

| `only` or `except`      | `rules`                                      | Notes                                                                                                                                                                                       |
|-------------------------|----------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `only: merge_requests`  | `if: $CI_MERGE_REQUEST_ID`                   | Adds jobs to [merge request pipelines](../merge_request_pipelines/index.md).                                                                                                                |
| `only: branches`        | `if: $CI_COMMIT_BRANCH`                      | Adds jobs to pipelines for changes to any branch.                                                                                                                                           |
| `only: master`          | `if: '$CI_COMMIT_BRANCH == "master"'`        | Adds jobs to pipelines on the `master` branch.                                                                                                                                              |
| `only: /regex-pattern/` | `if: '$CI_COMMIT_BRANCH =~ /regex-pattern/'` | Adds jobs to pipelines for changes to all branches that match the regex pattern. In this example, branches with `regex-pattern` will match, such as `regex-pattern-1` or `a-regex-pattern`. |
| `only: tags`            | `if: $CI_COMMIT_TAG`                         | Adds jobs to pipelines for changes to tags.                                                                                                                                                 |
| `only: schedules`       | `if: '$CI_PIPELINE_SOURCE == "schedule"'`    | Adds jobs to scheduled pipelines.                                                                                                                                                           |

## Types of pipelines

There are multiple types of pipelines that can be triggered:

- Branch pipelines
- Merge request pipelines
- Scheduled pipelines

These pipelines run independently in parallel, and can even be trigged by the same
event, which may cause seemingly identical pipelines.

## `when:` clauses with `rules:`

Note difference between `on_success` (default), vs `always`.

- `on_success`
- `always`
- `manual`
- `never`