---
stage: Create
group: Ecosystem
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Service templates

Using a service template, GitLab administrators can

- Provide default values for configuring integrations when creating new projects.
- Configure, in bulk, all existing projects as a one-time change.

When you enable a service template, the defaults are applied to **all** existing projects
that do not already have the integration enabled or do not otherwise have custom values
saved.
The values are populated on each project's configuration page for the applicable integration.

Settings for integrations are stored at the project level.

If you disable the template, these values no longer appear as defaults on new projects.
Projects previously configured using the template will continue to use those settings.

If you change the template, the revised values are applied to new projects. This feature
does not provide central administration of integration settings.

## Enable a service template

Navigate to the **Admin Area > Service Templates** and choose the service
template you wish to create.

Recommendation:

- Test the settings on some projects individually before enabling a template.
- Copy the working settings from a project to the template.

There is no 'Test settings' option when enabling templates. If the settings do not work,
these incorrect settings will be applied to all existing projects that do not already have
the integration configured. Fixing the integration then needs to be done project-by-project.

## Service for external issue trackers

The following image shows an example service template for Redmine.

![Redmine service template](img/services_templates_redmine_example.png)

For each project, you will still need to configure the issue tracking
URLs by replacing `:issues_tracker_id` in the above screenshot with the ID used
by your external issue tracker.
