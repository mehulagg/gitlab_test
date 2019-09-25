# Import Phabricator tasks into a GitLab project

> [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/issues/60562) in GitLab 12.0 (enable using a [feature flag](../../../administration/feature_flags.md#phabricator_import)).

GitLab allows you to import all tasks from a Phabricator instance into
GitLab issues. The import creates a single project with the
repository disabled.

Only the following basic fields are imported:

- Title
- Description
- State (open or closed)
- Created at
- Closed at

## Users

The assignee and author of a user are deducted from a Task's owner and
author: If a user with the same username has access to the namespace
of the project being imported into, then the user will be linked.
