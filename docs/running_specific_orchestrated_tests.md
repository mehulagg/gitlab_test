# Running specific orchestrated tests

## Maven artifact spec

The [maven repository spec](https://gitlab.com/gitlab-org/gitlab/-/blob/master/qa/qa/specs/features/ee/browser_ui/5_package/maven_repository_spec.rb) creates a Maven artifact and links it to a GitLab project. The artifact is created within a [Maven docker image](https://gitlab.com/gitlab-org/gitlab/-/blob/master/qa/qa/service/docker_run/maven.rb#L8).

Using `gitlab-qa` to run these tests reduces the liklihood of network errors between the maven container and GitLab instance.

To run this with `gitlab-qa` you can use the `Test::Instance::Image` that is needed for your test. For example:

`gitlab-qa Test::Instance::Image registry.gitlab.com/gitlab-org/build/omnibus-gitlab-mirror/gitlab-ee:2cb9a85d2beadd51b926eaddb05005403bee0013 -- --tag orchestrated qa/specs/features/ee/browser_ui/5_package/maven_repository_spec.rb` - runs the test against a specific Omnibus GitLab image that was built through `package-and-qa`.
