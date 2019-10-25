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

- Update [`lib/gitlab/qa/version.rb`] to an appropriate [semantic version](https://semver.org).
- Create a new tag via the UI (https://gitlab.com/gitlab-org/gitlab-qa/-/tags/new)
  * **Tag name**: The same version found in [`lib/gitlab/qa/version.rb`], prefixed with `v`, e.g. if the version is `4.7.1`, the tag would be `v4.7.1`.
  * **Message**: This can be something simple such as "<version> release"
  * **Release notes**: This should be a more detailed message of what the change introduces.  Make sure to link the 
    Merge Request(s) in this. See [`Release.md`](https://gitlab.com/gitlab-org/gitlab-qa/blob/7325c1f723ca666580e76df4d0ef5206da731bdf/.gitlab/merge_request_templates/Release.md).
  * Click *Create Tag*
  
GitLab will then starts a pipeline for this new tag, and the `release` job will build and push the new version of `gitlab-qa` to RubyGems.

[`lib/gitlab/qa/version.rb`]: https://gitlab.com/gitlab-org/gitlab-qa/blob/a4822daa230bfd7639b035aea847b129e5dfdfb5/lib/gitlab/qa/version.rb#L3
