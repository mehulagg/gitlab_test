<!-- For a given _milestone_ (m) that is planned for release in _month_ M (i.e. kicked off in month M-1),
the group technical writer should do the following:

- By month M-1, 1st (at least 17 days before milestone m beings)
   - Create an issue for the group with this template.
   - Name it `<group name> documentation planning for <GitLab version>`.
   - Add the milestone, assign the TW and PM of the group, and add the `~"Technical Writing"` and `~"documentation planning"` labels.
-->

# Documentation planning for \<group\> for \<GitLab release number\>

## Feature work

- By month M-1, 4th (at least 14 days before milestone m begins):
  - [ ] **PM:** Ensure all planned ~feature issues impacting any user view/workflow have:
    - a ~documentation label
    - a **Documentation** section in the description with minimum requirements for what should be covered or updated. (This can be expanded during feature work.)
    - Note: This work can be delegated to engineering but verified by the PM.
- By month M-1, 13th (at least 5 days before milestone m begins):
  - [ ] **TW:** Review the milestone's ~feature issues that do not have the ~documentation label. If you suspect docs are needed, inquire in the issue.
- By month M, 10th
  - [ ] **PM:** Contribute release post content (feature items, Omnibus improvements, deprecation/removal notices, and more, as [described in the Handbook](https://about.gitlab.com/handbook/marketing/blog/release-posts/#pm-contributors)).
- By month M, 16th
  - [ ] **TW:** Ensure all docs and release post content is reviewed and merged (or ready to merge by the assignee).

## Docs-only work

- By month M-1, 4th (at least 14 days before milestone m begins):
  - [ ] **PM:** Confirm the doc issues slated for next milestone, assigning each to a Technical Writer or engineer to show who is expected to be the primary author.
- By month M-1, 13th (at least 5 days before milestone m begins):
  - [ ] **TW:** Review the issues and assignments, discussing with the PM or engineer as needed. Ensure the needs and roles are clear, for example: who is the SME (if not the author), required examples, additional reviewers, etc.
  - [ ] **TW:** Coordinate with any other TWs whose groups fall under the next-higher-level PM (stage or section) to have that PM review the set of doc issues assigned. If any TW would be over capacity, flag this, so that the PM can help prioritize.
    - The stage/section PM should help decide priorities of issus across groups, especially in cases where TW is over capacity.
- By month M, 17th
  - [ ] **TW:** Ensure content is reviewed and merged, or pushed back to the next milestone with explanation of why it slipped.

## Notes

This checklist should remain aligned with the:

- Release Post [Monthly Releases](https://about.gitlab.com/handbook/marketing/blog/release-posts/#monthly-releases) timeline.
- Engineering Handbook's [Product Development Timeline](https://about.gitlab.com/handbook/engineering/workflow/#product-development-timeline).
- [Product Development Flow](https://about.gitlab.com/handbook/product-development-flow/).

Information here can be moved to those pages as SSOT where possible.
