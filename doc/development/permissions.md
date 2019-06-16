# GitLab permissions guide

There are multiple types of permissions across GitLab, and when implementing
anything that deals with permissions, all of them should be considered.

## Groups and Projects

### General permissions

Groups and projects can have the following visibility levels:

- public (20) -  an entity is visible to everyone
- internal (10) - an entity is visible to logged in users
- private (0) - an entity is visible only to the approved members of the entity

The visibility level of a group can be changed  only if all subgroups and
subprojects have the same or lower visibility level. (e.g., a group can be set
to internal only if all subgroups and projects are internal or private).

Visibility levels can be found in the `Gitlab::VisibilityLevel` module.

### Feature specific permissions

Additionally, the following project features can have different visibility levels:

- Issues
- Repository
  - Merge Request
  - Pipelines
  - Container Registry
  - Git Large File Storage
- Wiki
- Snippets

These features can be set to "Everyone with Access" or "Only Project Members".
They make sense only for public or internal projects because private projects
can be accessed only by project members by default.

### Members

Users can be members of multiple groups and projects. The following access
levels are available (defined in the `Gitlab::Access` module):

- Guest
- Reporter
- Developer
- Maintainer
- Owner

If a user is the member of both a project and the project parent group, the
higher permission is taken into account for the project.

If a user is the member of a project, but not the parent group (or groups), they
can still view the groups and their entities (like epics).

Project membership (where the group membership is already taken into account)
is stored in the `project_authorizations` table.

### IP access restriction

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ee/issues/1985) in
[GitLab Ultimate](https://about.gitlab.com/pricing/) 12.0.

To make sure only people from within your organization can access particular
resources, you have the option to restrict access to groups and their
underlying projects, issues, etc, by IP address. This can help ensure that
particular content doesn't leave the premises, while not blocking off access to
the entire instance.

Add whitelisted IP subnet using CIDR notation to the group settings and anyone
coming from a different IP address won't be able to access the restricted
content.

Restriction currently applies to UI, API access is not restricted.
To avoid accidental lock-out, admins and group owners are are able to access
the group regardless of the IP restriction.

### Confidential issues

Confidential issues can be accessed only by project members who are at least
reporters (they can't be accessed by guests). Additionally they can be accessed
by their authors and assignees.
