<!-- Replace `v4.5.0` with the previous release here, and `e18d76b309e42888759c1effe96767f13e34ae55`
with the latest commit from https://gitlab.com/gitlab-org/gitlab-qa/commits/master that will be included in the release. -->
- Diff: https://gitlab.com/gitlab-org/gitlab-qa/compare/v4.5.0...e18d76b309e42888759c1effe96767f13e34ae55

- Release notes:

<!-- Keep the sections order but remove the empty sections -->

```markdown
### New scenarios and scenario updates

- !aaa <Title of the aaa MR>.

### Fixes

- !bbb <Title of the bbb MR>.

### Doc changes

- !ccc <Title of the ccc MR>.

### Other changes (CI, backstage)

- !ddd <Title of the ddd MR>.
```

- Checklist before merging:
  - [ ] Diff link is up-to-date.
  - [ ] Based on the diff, `lib/gitlab/qa/version.rb` is updated, according to [SemVer](https://semver.org).
  - [ ] Release notes are accurate.

- Checklist after merging:
  - [ ] [Create a tag for the new release version](docs/release_process.md#how-to).

/label ~Quality ~backstage
