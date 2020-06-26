# Development guide for CI Job Artifacts

Job Artifact is very powerful tool to collect data from the pipeline jobs, that
can be integrated with any features in any DevOps stages.

One of the common usages is to collect a **report**-type artifact that anaylizes user's project
by running a test script and show the result in an MR widget e.g. [JUnit test reports](../../ci/junit_test_reports.md).

## Usage example

- Show [JUnit test reports](../../ci/junit_test_reports.md) in MR widgets.
- Running [On-demand DAST scan](https://gitlab.com/gitlab-org/gitlab/-/issues/218685).
- Passing [dynamically generated job variables between stages](https://gitlab.com/gitlab-org/gitlab/-/issues/22638).
- Generating [a static website for GitLab Pages](../../user/project/pages/index.md)
- and more

## Artifact definition

Artifact has the following attribute to describe its entity, which
is managed under `Gitlab::Ci::Build::Artifacts::Definitions` domain.

- [`description`](#description-required)
- [`file_type`](#file_type-required)
- [`file_format`](#file_format-required)
- [`default_file_name`](#default_file_name-required)
- [`tags`](#tags-optional)
- [`options`](#options-optional)

### `description` (Required)

The explanation for the usage of the job artifact.

NOTE: **Note:**
If the job artifact is deprecated, you should update the description filed
about when it's deprecated and will be [unsupported](#options-optional).
Alternatively, you can include an issue link for the deprecation.

### `file_type` (Required)

The file type of the artifact.
The value must be defined in `Gitlab::Ci::Build::Artifacts::Definitions` too.

### `file_format` (Required)

The file format of the artifact.
The value must be defined in `Gitlab::Ci::Build::Artifacts::Definitions` too.

You have to choose the most relevant format based on the usage of the job artifact.

|Format       | PROs                                                    | CONs                                                              | When to use |
|---------    |--------                                                 |----------------------------------                                 | ----------- |
|`zip`        | Compressed. Multiple folders and files can be included. | It's hard to consume e.g. The extraction must happen in Sidekiq jobs and not Puma. | Not a time sensitive feature. |
|`gzip`       | Compressed. Multiple files can be included. Can be read in Puma. | Cannot be read in frontend. | Backend serializes data before it's sent to frontend. |
|`raw`        | Can be read in frontend.                                | Not comporessed. Only single file can be included. | Frontend directly consumes the file. |

### `default_file_name` (Required)

The default file name of the job artifact. GitLab persists the artifact with the default name unless it's overridden.

### `tags` (Optional)

The tags for grouping artifacts by kind. For example, when you get all `report` type artifact definitions,
execute `Gitlab::Ci::Build::Artifacts::Definitions.find_by_tags(:report)`.

### `options` (Optional)

The optional behavior of the job artifact. Available options are:

|Option           |Description                                              | Default |
|---------        |----------------------------------                       | ----    |
|`downloadable`   | The artifact can be downloaded via UI, API, etc.        | True    |
|`erasable`       | The artifact will be erased when it's expired.          | True    |
|`unsupported`    | Runners can no longer upload the artifact. Please also see [How to deprecate/remove an existing file type](#how-to-deprecate-and-drop-the-support-of-an-existing-file-type) | False    |

## Artifact Size limitation

See [maximum file size per type of artifact](../../administration/instance_limits.md#maximum-file-size-per-type-of-artifact).

## How to add a new file type

- Add a new file type in the `Gitlab::Ci::Build::Artifacts::Definitions`.
- Add a new [definition](#artifact-definition) in `lib/gitlab/ci/build/artifacts/definitions/<file_type>.rb`
- Add a database migration to define [a limit](#artifact-size-limitation) for the new file type.

## How to deprecate and drop the support of an existing file type

- Make deprecation announcement in advance.
- Discuss with PMs and domain experts if it's safe to drop the support.
  In general, a breaking change can only happen at **major** version update.
  If the artifact has been added recently or still there are many users depend on it,
  you should not drop the support regardless of the major version update.
- Add [`unsupported`](#options-optional) option to the artifact definition.

NOTE: **Note:**
If you dropped support because of _renaming_ artifact, you should update `description` filed
about the new name of the artifact.

## How to access to the composed file (`gzip` and `raw` file type only)

```ruby
build.artifact.open do |stream|
  stream.read # returns the content of the job artifact
end
```

## References

- [Job artifacts](../../ci/pipelines/job_artifacts.md)
- [Job artifacts administration](../../administration/job_artifacts.md)
