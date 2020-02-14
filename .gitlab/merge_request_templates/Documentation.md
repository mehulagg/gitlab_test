<!-- Follow the documentation workflow https://docs.gitlab.com/ee/development/documentation/workflow.html -->
<!-- Additional information is located at https://docs.gitlab.com/ee/development/documentation/ -->

<!-- Mention "documentation" or "docs" in the MR title -->
<!-- For changing documentation location use the "Change documentation location" template -->

## What does this MR do?

<!-- Briefly describe what this MR is about. -->

## Related issues

<!-- Link related issues below. Insert the issue link or reference after the word "Closes" if merging this should automatically close it. -->

## Author's checklist

- [ ] Follow the [Documentation Guidelines](https://docs.gitlab.com/ee/development/documentation/) and [Style Guide](https://docs.gitlab.com/ee/development/documentation/styleguide.html).
- [ ] If applicable, update the [permissions table](https://docs.gitlab.com/ee/user/permissions.html).
- [ ] Link docs to and from the higher-level index page, plus other related docs where helpful.
- [ ] Ensure the `docs-lint` job completes successfully.
- [ ] Apply the correct `~devops::` and `~group::` scoped labels.
- [ ] Apply the ~documentation label and a throughput label (~backstage for MRs including only docs)

## Review checklist

All reviewers must help ensure accuracy, clarity, completeness, and adherence to the [Documentation Guidelines](https://docs.gitlab.com/ee/development/documentation/) and [Style Guide](https://docs.gitlab.com/ee/development/documentation/styleguide.html).

**1. Reviewers**

Both reviewers below can be assigned at the same time:

- [ ] **Technical writer review**. Assign the writer listed for the applicable [DevOps stage](https://about.gitlab.com/handbook/product/categories/#devops-stages).
- [ ] (Optional): Review by a code reviewer or other selected colleague to confirm accuracy, clarity, and completeness. When complete, should be assigned to a Maintainer for second review. This can be skipped for minor fixes without substantive content changes.

**2. Maintainer**

- [ ] Review by assigned maintainer, who can always request/require the above reviews. Maintainer's review can occur before or after a technical writer review.
- [ ] Ensure a release milestone is set.
- [ ] If the technical writer review is being skipped, please follow the [post merge review guidelines](https://docs.gitlab.com/ee/development/documentation/workflow.html#post-merge-reviews), and [create an issue for one using the Doc Review template](https://gitlab.com/gitlab-org/gitlab/issues/new?issuable_template=Doc%20Review) if needed.

  Reviews may be skipped only if:

  - The MR contains an extremely minor change, such as a single typo correction, and the maintainer is confident Technical Writer review is not needed.
  - The MR corrects a critical problem with documentation that must be fixed extremely quickly.

/label ~documentation
