---
stage: Package
group: Package
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# GitLab Composer Repository

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/15886) in [GitLab Premium](https://about.gitlab.com/pricing/) 13.2.
> - [Moved](https://gitlab.com/gitlab-org/gitlab/-/issues/221259) to GitLab Core in 13.3.

With the GitLab Composer Repository, every project can have its own space to store [Composer](https://getcomposer.org/) packages.

## Enabling the Composer Repository

NOTE: **Note:**
This option is available only if your GitLab administrator has
[enabled support for the Package Registry](../../../administration/packages/index.md).

When the Composer Repository is enabled, it is available for all new projects
by default. To enable it for existing projects, or if you want to disable it:

1. Navigate to your project's **Settings > General > Visibility, project features, permissions**.
1. Find the Packages feature and enable or disable it.
1. Click on **Save changes** for the changes to take effect.

You should then be able to see the **Packages & Registries** section on the left sidebar.

## Getting started

This section covers creating a new example Composer package to publish. This is a
quickstart to test out the **GitLab Composer Registry**.

To complete this section, you need a recent version of [Composer](https://getcomposer.org/).

### Creating a package project

Understanding how to create a full Composer project is outside the scope of this
guide, but you can create a small package to test out the registry. Start by
creating a new directory called `my-composer-package`:

```shell
mkdir my-composer-package && cd my-composer-package
```

Create a new `composer.json` file inside this directory to set up the basic project:

```shell
touch composer.json
```

Inside `composer.json`, add the following code:

```json
{
  "name": "<namespace>/composer-test",
  "type": "library",
  "license": "GPL-3.0-only",
  "version": "1.0.0"
}
```

Replace `<namespace>` with a unique namespace like your GitLab username or group name.

After this basic package structure is created, we need to tag it in Git and push it to the repository.

```shell
git init
git add composer.json
git commit -m 'Composer package test'
git tag v1.0.0
git remote add origin git@gitlab.com:<namespace>/<project-name>.git
git push --set-upstream origin master
git push origin v1.0.0
```

### Publishing the package

Now that the basics of our project is completed, we can publish the package.
To publish the package, you need:

- A personal access token or `CI_JOB_TOKEN`.

  ([Deploy tokens](./../../project/deploy_tokens/index.md) are not yet supported for use with Composer.)

- Your project ID which can be found on the home page of your project.

To publish the package hosted on GitLab, make a `POST` request to the GitLab package API.
A tool like `curl` can be used to make this request:

You can generate a [personal access token](../../../user/profile/personal_access_tokens.md) with the scope set to `api` for repository authentication. For example:

```shell
curl --data tag=<tag> 'https://__token__:<personal-access-token>@gitlab.com/api/v4/projects/<project_id>/packages/composer'
```

Where:

- `<personal-access-token>` is your personal access token.
- `<project_id>` is your project ID.
- `<tag>` is the Git tag name of the version you want to publish. In this example it should be `v1.0.0`. Notice that instead of `tag=<tag>` you can also use `branch=<branch>` to publish branches.

If the above command succeeds, you now should be able to see the package under the **Packages & Registries** section of your project page.

### Publishing the package with CI/CD

To work with Composer commands within [GitLab CI/CD](./../../../ci/README.md), you can
publish Composer packages by using `CI_JOB_TOKEN` in your `.gitlab-ci.yml` file:

```yaml
stages:
  - deploy

deploy:
  stage: deploy
  script:
    - 'curl --header "Job-Token: $CI_JOB_TOKEN" --data tag=<tag> "https://gitlab.example.com/api/v4/projects/$CI_PROJECT_ID/packages/composer"'
```

### Installing a package

To install your package, you need:

- A personal access token. You can generate a [personal access token](../../../user/profile/personal_access_tokens.md) with the scope set to `api` for repository authentication.
- Your group ID which can be found on the home page of your project's group.

Add the GitLab Composer package repository to your existing project's `composer.json` file, along with the package name and version you want to install like so:

```json
{
  ...
  "repositories": [
    { "type": "composer", "url": "https://gitlab.com/api/v4/group/<group_id>/-/packages/composer/packages.json" }
  ],
  "require": {
    ...
    "<package_name>": "<version>"
  },
  ...
}
```

Where:

- `<group_id>` is the group ID found under your project's group page.
- `<package_name>` is your package name as defined in your package's `composer.json` file.
- `<version>` is your package version (`1.0.0` in this example).

You also need to create a `auth.json` file with your GitLab credentials:

```json
{
    "gitlab-token": {
       "gitlab.com": "<personal_access_token>"
    }
}
```

Where:

- `<personal_access_token>` is your personal access token.

With the `composer.json` and `auth.json` files configured, you can install the package by running `composer`:

```shell
composer update
```

If successful, you should be able to see the output indicating that the package has been successfully installed.

CAUTION: **Important:**
Make sure to never commit the `auth.json` file to your repository. To install packages from a CI job,
consider using the [`composer config`](https://getcomposer.org/doc/articles/handling-private-packages-with-satis.md#authentication) tool with your personal access token
stored in a [GitLab CI/CD environment variable](../../../ci/variables/README.md) or in
[Hashicorp Vault](../../../ci/secrets/index.md).
