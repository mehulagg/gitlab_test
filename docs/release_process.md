# Release Process

## Versioning

We follow [Semantic Versioning](https://semver.org).  In short, this means that the new version should reflect the types of changes that are about to be released.

*summary from semver.org*

MAJOR.MINOR.PATCH

- MAJOR version when you make incompatible API changes,
- MINOR version when you add functionality in a backwards compatible manner, and
- PATCH version when you make backwards compatible bug fixes.

## When we release

We release `gitlab-qa` on an ad-hoc basis.  There is no regularity to when we release, we just release
when we make a change - no matter the size of the change.

## How-to

- Check if there is an [open merge request to bump the version](https://gitlab.com/gitlab-org/gitlab-qa/merge_requests?scope=all&utf8=%E2%9C%93&state=opened&search=bump+version) (to avoid creating a duplicate).
  - If there is one, update it if necessary.
  - If not, update [`lib/gitlab/qa/version.rb`] to an appropriate [semantic version](https://semver.org) in a new merge request using the [release template](https://gitlab.com/gitlab-org/gitlab-qa/blob/master/.gitlab/merge_request_templates/Release.md)
    and title the MR like `"Bump version to <version>"`.
- Merge the merge request.
- Create a new tag via the UI (https://gitlab.com/gitlab-org/gitlab-qa/-/tags/new).
  * **Tag name**: The same version found in [`lib/gitlab/qa/version.rb`], prefixed with `v`, e.g. if the version is `4.7.1`, the tag would be `v4.7.1`.
  * **Message**: This can be something simple such as "<version> release".
  * **Release notes**: Copy the release notes from the merge request.
  * Click *Create Tag*.
  
GitLab will then start a pipeline for this new tag, and the `release` job will build and push the new version of `gitlab-qa` to RubyGems.

[`lib/gitlab/qa/version.rb`]: https://gitlab.com/gitlab-org/gitlab-qa/blob/master/lib/gitlab/qa/version.rb#L3
