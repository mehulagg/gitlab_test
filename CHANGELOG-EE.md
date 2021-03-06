Please view this file on the master branch, on stable branches it's out of date.

## 13.4.0 (2020-09-22)

### Security (1 change, 1 of them is from the community)

- Remove v-html from environments/components/deploy_board_component.vue. !41521 (Takuya Noguchi)

### Removed (2 changes)

- Remove VSA duration median line. !39665
- Remove Users over license banner. !39836

### Fixed (56 changes, 6 of them are from the community)

- Allow creation of confidential sub-epics from tree. !37882 (Jan Beckmann)
- Use active user count instead historial max. !37916
- Move Add Approver name validation error into form. !39389
- Update environment dashboard help text. !39450
- Add identifier check when creating vulnerability findings. !39650
- Update epic inherited dates and create notes when reordering in epic tree. !39742
- Fix Approval Rules table in Merge Requests bursting out of the layout in some scenarios. !39753
- Fix group name bug for new purchase flow. !39915
- Add docker options for Load Perf testing. !39977
- Use Gitlab::ErrorTracking in place of project.logger for indexing errors. !39979
- Fix unchecking all compliance frameworks for MR approvals settings. !40070
- Remove gap on trial registrations page. !40080
- Fix issue where the select page dropdown would be disabled on the Insights Analytics page when no charts were loaded. !40096
- Display contents of Zuora iframe for the new purchase flow in Dark Mode. !40114
- Activate on-demand scans nav item when editing a site profile. !40148
- Omit sub-groups from trial selection menu. !40300
- Geo Statuses - Fix empty section bug. !40443
- Update description when editing iteration. !40476
- Fix remediated badge visibility on vulnerability list. !40483
- Fix breadcrumb for security dashboard. !40486
- Don’t create new gitlab_subscription records on nested attributes to namespaces. !40537
- Make vulnerability list columns have consistent widths. !40561
- Don't overwrite user's description by default template description. !40609
- Improve Accordion Item Focus State. !40638 (Kev @KevSlashNull)
- Geo: Fix design repository failures with selective sync, and make container repository updates more robust. !40643
- Prevent Download For Failed Vulnerability Export Jobs. !40656 (Kev @KevSlashNull)
- Fix vulnerability comment delete button spinner position. !40681
- Fix vulnerability save button spinner position. !40781
- Fix error in migration to populate historical vulnerability statistics. !40835
- Fix for Iterations closing a day early. !40884
- Add missing path to project vulnerability. !40935
- Allow on-demand DAST pipelines to be found for scanned resource. !40982
- Support dark theme for overview of payment method component for the new purchase flow. !40988
- Create resource weight event when setting the weight during issue creation. !41087
- Un-nest sidebar under .context-header div in security navigation. !41176
- Fix dasboard to dashboard. !41440
- Geo: Avoid orphaning blob files on secondaries. !41529
- Disable loading vulnerabilities in MR when pipeline is running. !41539 (Justin Zeng)
- Enable secret detection for MR Widget. !41582
- Introduce ^ as a reference prefix for Vulnerabilities. !41643
- Fix the size of chart placeholder on Analytics pages for Merge Requests, Insights and Value stream, so it matches the actual charts. the size of the real chart shown afterwards. !41904
- Correct sibling query for epic tree nodes. !41986
- Fix SAST Config GraphQL mutation. !42003
- Fix Duplicate Keys in Vulnerability Details. !42027 (Kev @KevSlashNull)
- Hide confirmation modal after closing a blocked issue. !42068
- Create a Geo cache invalidation event when toggling feature flags through the API. !42070
- Track state changes using resource state events for Epics. !42088
- This change preserves the environment when editing network policies. !42148
- Reset scope to all-environments when last scope removed. !42287
- Return stored seat counts in the subscriptions API endpoint. !42293
- DAST on-demand site profiles: prevent error banner from showing. !42300
- Fix MR Modal Vulnerability Links Overflow Modal. !42332 (Kev @KevSlashNull)
- Fix project_ids query param for downloading coverage CSV report. !42497
- Fix selecting all projects in group code coverage report. !42507
- Geo - Create repository updated events only if the repository exists. !42519
- Fix Iterations quickaction not showing all iterations. !42528

### Deprecated (1 change)

- Mark RunDASTScan mutation as deprecated. !42544

### Changed (66 changes, 2 of them are from the community)

- Use standard table colors in Dependency List. !31130
- Disable editing health status for closed issues and show informative tooltip. !38372
- Added Cluster Agent delete mutation for GraphQl. !38622
- Button migration to component on dependency list. !38624
- Update FF nav section using GitLab UI Utilities. !38768
- Pass current_plan all the way down the partial chain. !38868
- add CiliumNetworkPolicy into services. !39127
- Persist when dismissing FF will look different message. !39238
- Update URL when editing iteration. !39296
- Move Analytics to admin panel. !39368
- Relocate create issue button from header section to the related issues section. !39533
- Remove project selector logic from instance security dashboard. !39631
- Move variable audit logging to Starter. !39730
- Epic labeling for confidential epics. !39794
- Add How-to-upgrade link to admin license page. !39974
- Apply sizing to SAST Configuration variable fields. !40002
- Do not write SAST defaults via SAST Config UI. !40030
- Create instance-level security charts component and update severity widget CSS. !40046
- Return message when personal access token creation fails in internal API. !40073 (Taylan Develioglu)
- Replace <gl-deprecated-button> with <gl-button> in confirm_order component. !40119
- Revert Merge branch add_standard_field_into_payload into master. !40162
- Hide warning to disable GitLab issues in Jira integration form. !40248
- Add link to primary node in secondary node alert. !40297
- Make legacy feature flags read-only. !40320
- Remove project limit from Environments Dashboard help text. !40333
- Use semantic HTML in Progress Bar component. !40380
- Simplify progress bar steps logic. !40390
- Reset CI minutes for all namespaces every month. !40396
- Implement empty state on security dashboard. !40413
- DAST Scanner Profile Library: change new-profile button to dropdown. !40469
- Remove health status feature from incidents. !40520
- Improve error message when creating issue fails. !40525
- Allow SAST Configuration UI to be used when there's an existing CI file. !40528
- Add support for multiple environments on the controller and service level. !40529
- Allow for project filtering in Group code coverage Finder class. !40547
- Allow milestone and assignee board lists to be created using GraphQL. !40551
- Add Feature Flags Search Box shortcut. !40578
- Enhance error messages for Add Project to Security Dashboard mutation. !40607
- Make environments dropdown fetch results as soon as it's focused. !40624
- Change the configureSast mutation to use actual GraphQL types instead of JSON types. !40637
- Remove group_push_rules feature flag. !40658
- Remove issue note from vulnerability details. !40686
- Enhance error messages when Adding Projects to Security Dashboard. !40692
- ee Migrating modal button in License Compliance. !40747
- Change merge train position messaging. !40777
- Remove weight from incidents sidebar. !40794
- Expand retention period to 365 days for Vulnerability Statistics. !40833
- Move group activity analytics from beta to general availability. !40916
- Link Elasticsearch indexing progress to elastic_commit_indexer. !40928
- Use finding_description for Details in CSV vulnerability export. !40944
- Hide the upgrade link on the admin license page if plan Ultimate. !40977
- Show ancestor iterations in subgroups. !40990
- Improve the UX of the Start a Trial group selection page. !41020
- Replace bootstrap alerts in ee/app/views/admin/push_rules/_push_rules.html.haml. !41072 (Jacopo Beschi @jacopo-beschi)
- Only display downgraded message if on free plan. !41213
- Sort merge requests by merged at date in Merge Request Analytics. !41272
- Apply filters to vulnerability count list. !41566
- Filter out incidents from related issues in epics. !41807
- Show additional columns in Group and Instance Security Dashboards. !41829
- Add toast to the reset pipelines minutes button. !41838
- Add explanation text to FF create/edit sections. !41910
- Use GitLab utility classes for the alert component instead of Bootstrap. !41974
- Remove license check for feature flags. !42023
- Update in preparation of supporting analyzers. !42173
- Skip the who will be using GitLab question in signup when a user is invited. !42264
- Expose approvals required and approvals left for merge requests in GraphQL. !42354

### Performance (10 changes)

- Optimize the Advanced Search query for Issues and Notes. !38095
- Load only the requested report artifacts into the memory for vulnerability_findings endpoint. !39749
- Add cache for elasticsearch_indexes_namespace check. !41274
- Limit the context for paused elasticsearch jobs. !41297
- Cache project user defined rules by branch. !41564
- Return empty scanners list when pipeline has no reports. !41652
- Enable elasticsearch namespace enabled cache by default. !41875
- Refactor approval_rules association. !41965
- Move approval reset to new service and worker. !42001
- Geo: Improve performance of package files queries. !42294

### Added (66 changes)

- Add usage data for counting projects with sectional codeowner rules. !37786
- Add group code coverage download button. !37853
- Deployer authorisation for protected environments. !38188
- Add ability to fetch DastSiteProfile via GraphQL. !38380
- Added loading animations for value stream analytics. !38447
- Add epic_id param to issue update graphQL mutation. !38678
- Cluster token create mutation for GraphQL. !38820
- Add GraphQL endpoint for retrieving cluster agents for a project. !38833
- Add metrics for terraform state replication. !38959
- Allow requirement status to be updated with GraphQL. !39371
- Count security jobs. !39481
- Show tooltips for License-Check and Vulnerability-Check approval rules. !39579
- Add pagination to Environments Dashboard. !39637
- Show license overage warning on admin dashboard. !39704
- Add Revoke buttons to the PAT tab of the instance credential inventory. !39712
- Show Latest Most Severe Alert on Environment. !39743
- Add an API to add a push rule to a group. !39760
- Add a License overview section to the Admin dashboard. !40009
- Include subgroup issues in iteration issue list. !40099
- Enable to delete a custom value stream. !40127
- API to edit group push rules. !40136
- Add endpoint to update Dast Scanner Profile. !40208
- Add global_id field to DastScannerProfiles::Create. !40225
- Add suggested security approval rules. !40250
- Add deployment events to group webhooks. !40270
- API to delete group push rule. !40293
- Geo: Add graphql endpoints for terraform state. !40317
- Add GraphQL endpoint for deleting a cluster agent token. !40338
- Add EULA checkbox on license page. !40352
- Add feedback call to action in SAST Configuration. !40363
- Make Auto DevOps alert in Security Configuration dismissible. !40375
- Adding counts of users using default branch locks and users using multi-branch LFS locks. !40419
- Make searching issues/MRs by IID even easier. !40467
- On-demand scans item on Security & Compliance configuration page. !40474
- Allow reporters to approve MRs. !40491
- Expose approved flag in Merge Request GraphQL API. !40505
- Populate `resolved_on_default_branch` column for existing vulnerabilities. !40755
- Allow fetching agent tokens from cluster agent GraphQL endpoint. !40779
- Add detected date to vulnerability details page. !40782
- Add delete mutation for DAST scanner profile. !40805
- Add REST endpoint to access resource iteration events. !40850
- Add ability to sort vulnerabilities by severity in GraphQL API. !40856
- Delete custom value streams. !40927
- Introduce `detectedAt` field for VulnerabilityType on GraphQL API. !41000
- Use dast_scanner_profiles in DAST on-demand scans. !41060
- Add ability to filter vulnerabilitiesSeveritiesCount in GraphQL for Project, Group and Instance Security Dashboard. !41067
- Add detected column with timestamp on security dashboards. !41092
- Create vulnerabilities route/page for instance-level security dashboard. !41156
- Add GraphQL mutation to create test cases. !41190
- Geo: Add rake task to check if DB replication is working. !41618
- New checkout flow for free groups on gitlab.com. !41644
- Add filtering by activity (has_resolution, has_issues) to Vulnerability. !41650
- Add link to GitLab CI history in Security Configuration. !41673
- Add ability to track unique uses of API endpoints. !41689
- Support custom JSON schema validation in the Web IDE. !41700
- Support moving issue between epics in GraphQL. !41790
- Adding total counts of default branch locks and multi-branch LFS locks. !41824
- Expose analyzer info for SAST Config. !41825
- Add Vulnerabilities Count by Day to Project GraphQL API. !41856
- Add policy editor to the Threat Monitoring page. !41949
- Enable on-demand DAST scans scanner-profiles flag by default. !41950
- Add support for reading Vault secrets from CI jobs. !42055
- Add ability to select projects for group coverage report. !42129
- Add + as a special reference for to GFM Autocomplete. !42190
- Add sorting functionality to vulnerability list. !42347
- Add mutation to Resolve Vulnerability in GraphQL. !42500

### Other (26 changes, 11 of them are from the community)

- Update Browser Performance Testing SiteSpeed version to 14.1.0. !37685
- Change Advanced Global Search to Advanced Search. !39526
- Migrate analytics stage button away from deprecated button. !39560
- Add backend pagination to the environments dashboard. !39847
- Deprecate -gray- variables and replace with - variables. !39860
- Add Snowplow to Toggles on Feature Flag Table. !39995
- Add Snowplow to Toggles on Edit Feature Flag. !40023
- Update Standalone Vulnerabilities Page to be a Single Vue App. !40189 (Kev @KevSlashNull)
- Migrate Bootstrap button to GlButton in the issue boards assignee dropdown list. !40398
- Update $orange variables to match GitLab UI and address contrast for accessibility. !40652
- Track iteraton changes using resource events. !40841
- Replace deprecated button on status page. !41012
- Fix typos of committed in project views. !41038 (Takuya Noguchi)
- Replace v-html with v-safe-html in dismissal_note.vue. !41137 (Kev @KevSlashNull)
- Replace v-html with v-safe-html in card_security_discover_app.vue. !41139 (Kev @KevSlashNull)
- Replace deprecated buttons with new GlButton component from GitLab UI. !41154
- Replace v-html with v-safe-html in configure_feature_flags_modal.vue. !41210 (Kev @KevSlashNull)
- Replace v-html with v-safe-html in groups_dropdown_filter.vue. !41212 (Kev @KevSlashNull)
- Replace v-html with inline text in weight.vue. !41325 (Kev @KevSlashNull)
- Internationalize Admin namespace plan. !41363 (Takuya Noguchi)
- Internationalize Admin dashboard Geo. !41368 (Takuya Noguchi)
- Update location fingerprint for existing CS vulnerabilities. !41756
- Rename Elasticsearch to Advanced Search in Admin UI. !42048
- Remove without_index_namespace_callback trait. !42082 (Andrei Cirnici @acirnici)
- Adjust Color of Low Severity Symbol. !42153 (Kev @KevSlashNull)
- Elasticsearch reindexing: add confirmation popup and change color scheme. !42209


## 13.3.4 (2020-09-02)

- No changes.

## 13.3.3 (2020-09-02)

### Security (2 changes)

- Sanitize vulnerability history comment.
- Fix displaying epics visibility in issue sidebar.


## 13.3.2 (2020-08-28)

- No changes.

## 13.3.1 (2020-08-25)

### Fixed (2 changes)

- Geo: Apply selective sync to container repo updates. !39663
- Geo: Apply selective sync to design repo updates. !39916


## 13.3.0 (2020-08-22)

### Removed (7 changes)

- Remove unused approvals controller actions. !36855
- Geo: Remove FDW warnings from health checks. !38620
- Geo: Remove FDW warnings from configuration checks. !38629
- Geo: Remove rake task to refresh foreign tables definition in Geo Secondary node. !38632
- Geo: Remove support for Foreign Data Wrapper. !38718
- Disable loading resolvedOnDefaultBranch for Vulnerabilities. !38783
- Remove Foreign Data Wrapper support from Geo docs. !39485

### Fixed (53 changes, 3 of them are from the community)

- changed the default value of checkbox to false from a dynamic value on first page load. !36646 (Uday Aggarwal @uday.agg97)
- Geo: Package file backfill/removal accounts for object storage settings. !36771
- Geo: Fix LFS file downloads from S3 to secondary. !37008
- Fix scanned resources count in MR security modal. !37029
- Geo: Fix OAuth authentication with relative URL used on secondary. !37083
- Display correct information on Roadmap when an epic has no start and due date. !37093
- Fix epic label dropdown behavior when opened within the new epic page. !37125
- Fix security dashboard by excluding license scanning information. !37318
- VSA fetch duration data for active stages only. !37336
- Disable security scanner alerts. !37354
- Geo - Fix Node Form Breadcrumbs. !37366
- Minor style fixes to 'Linked Issues' card. !37396
- Fix duplicate dispatch of 'fetchCycleAnalyticsData' action. !37458
- Do not display the export button while projects are loading. !37573
- Fix Any filter for labels in Value Stream Analytics. !37584
- Fix Elasticsearch sorting incorrectly from DB. !37665
- Scanners Alert: translate COVERAGE_FUZZING. !37803
- Support Indexing files in Elasticsearch with paths longer than 512 bytes. !37834
- Only send AWS Credentials ENV to indexer when AWS config is enabled. !37865
- Remove an extra padding in y-axis on Epic detail. !37886 (Takuya Noguchi)
- Fix number mismatch issue for MR Widget. !38021
- Truncate long vulnerability names on security report. !38056
- Fix persisting multiple default Value Stream Analytics stages per value stream. !38072
- Geo: Fix consuming events of blobs that should not be synced. !38089
- Dont use DB connection in GlobalSearchSampler. !38138
- Permit new projects to be created from active project templates only. !38335
- Add support for active field to feature flags api. !38350
- Fix GraphQL for read-only instances with relative URLs. !38402
- Fix insights period_field parameter. !38404
- Support renaming feature flags via the api. !38425
- Geo: Fix not working redownloading of repositories via snapshot. !38464
- Audit failed login from OAuth provider. !38473 (banovp)
- Utilize `resolvedOnDefaultBranch` field to show the remediated badge on vulnerabilities list. !38478
- Show only root namespaces for subscriptions. !38481
- VSA requests fail without multiple value streams feature flag. !38542
- Fix MR approval rule update logic for Vulnerability-Check. !38589
- Update Vulnerability::IssueLinks when moving Issues to new Project. !38765
- Only show subscribable banner when auto-renew is set. !38962
- Dark mode - Fix edit scoped labels. !39166
- Add logging when indexing projects are missing project_feature attribute. !39255
- SCIM provisioning to avoid creating SCIM identity without membership. !39259
- Fixed iteration references when in a private group/project. !39262
- Fix Iteration Edit button color to black. !39286
- Geo: Replicate repository changes when mirrors are updated. !39295
- Fix commented_by for any approvers rule. !39432
- Filtered search width fix on Roadmap. !39440
- Geo: Skip project/wiki repo create/update events based on selective sync. !39488
- Fix scanner check when creating vulnerability findings. !39500
- Set default for current_value in SAST config UI. !39504
- Fix the `Vulnerability-Check` and `License-Check` approval rules to be synched correctly after creating a merge request. !39587
- Ensure secondary is enabled on failover. !39615
- Pass the IID of the User List on Update. !39639
- Geo: Apply selective sync to container repo updates. !39663

### Deprecated (1 change)

- Deprecate vulnerabilitiesCountByDayAndSeverity on Group and InstanceSecurityDashboard GraphQL API. !38197

### Changed (58 changes, 1 of them is from the community)

- Geo: Add package files to status rake tasks. !36192
- Omit namespaces w/ non-free plans from trial select. !36394
- Expose blocked field on GraphQL issue type. !36428
- Display notices above license breakdown. !36881
- Send AWS credentials via environment variables to indexer. !36917
- Track issue weight changes using resource events. !36936
- Smartly truncate URLs in DAST Modal. !37078
- Polish Jira issues UI. !37095
- Inherit parent epic during an issue promotion. !37109
- Geo: Replace geo_self_service_framework_replication feature flag with replicable specific flags. !37112
- Expired subscription banner doesn't display for auto-renew. !37127
- License Compliance: Show license-approvals to be inactive if no approvals required. !37170
- Show count of extra identifiers in project dashboard. !37256
- Make New Feature Flags alert dismissible. !37306
- Simplify Advanced Search code_analyzer regex complexity. !37372
- Subscription Banner has 14 day grace period. !37378
- Allow nested gitlab_subscription on namespace api. !37397 (jejacks0n)
- Add is_standard as part of frontend payload for NetworkPolicyController. !37527
- Hide health status labels for closed issues on epics tree. !37561
- Remove heading from Feature Flags section. !37613
- Add extra identifier count to pipeline sec tab. !37654
- Hide Epic widget for incidents. !37731
- Use new chart loader on Insights page. !37815
- By default display only confirmed and detected vulnerabilities. !37914
- Use Drawer for Requirement Create/Edit form UI. !37943
- Audit log group variable updates. !37945
- Update merge request button messaging for license-check approval. !37954
- Update Compliance Dashboard to use tabs. !37959
- Make security summary message more understandable. !38043
- Reset CI minutes for all namespaces every month. !38057
- Add new security charts page and unavailable view. !38088
- Add empty state for Deploy Keys section. !38329
- Add frontend validation to "Restrict membership by email domain" field. !38348
- Geo API - Expose repositories_count and wikis_count. !38361
- Show blank empty text for approved by in MR widget. !38436
- Add published column. !38439
- Change prefix to COVFUZZ for CI variables related to coverage fuzzing. !38441
- Fetch latest successful pipeline with security jobs to check if vulnerability was resolved. !38452
- Add confirmation message when regenerating feature flags instance ID. !38497
- Add a left-hand navigation to the security page. !38529
- Update Merge Train helper text. !38619
- Audit events log table is now responsive to different display sizes. !38803
- Use GraphQL to get list of vulnerable projects. !38808
- Update {groups,profiles}/billings_controller_spec.rb files. !38872
- Automate the deletion of the old Index after a reindex. !38914
- Rename project delete 'adjourned' and 'soft deleted' to 'delayed'. !38921
- Audit variable changes for project variables. !38928
- Create a standalone settings page for the instance security dashboard. !38965
- Add frontend validation to "Restrict access by IP address" field. !39061
- Replace .com check with an app setting to enforce namespace storage limit. !39150
- Reduce number of users required to qualify for a free instance review from 100 to 50. !39155
- Productivity Analytics: Replace bs-callout with GlAlert component. !39207
- Update feature flag form buttons to gl-button. !39220
- Update requirements list buttons to gl-button. !39372
- Change IssueSetEpic mutation to make epic_id argument not required. !39451
- Re-name Issues Analytics (plural) as Issue Analytics (singular). !39506
- Implement a parser to extract SAST configuration. !39605
- Button migration to component.

### Performance (10 changes)

- Avoid N+1 of merge requests associations in Search. !36712
- Memoize project regulated settings check. !37403
- Fix slow Value Stream label stage query. !38252
- Improve issues confidentiality check performance for AGS. !38564
- Replace deprecated button syntax in empty_state. !38730
- Geo - Optimize the query to return reverifiable projects on Geo primary node. !38732
- Change data source for Vulnerable Projects to GraphQL. !38878
- Preload vulnerability statistics when loading vulnerable projects. !38905
- Disable loading hasNextPage value for Security Dashboards. !39261
- Load project list only during loading the Security Dashboard. !39263

### Added (66 changes, 1 of them is from the community)

- Add related issues panel to standalone vulnerability page. !35625
- add add coverage fuzzing results to security dashboard. !36011
- Expose epics related to board issues in GraphQL. !36186
- Add the option to filter epics by milestone. !36193
- Add predefined network policies to the network policy list. !36257
- Prevent some abilities at namespace or group level when over storage limit. !36493
- Add variable expansion to cross pipeline artifacts. !36578
- Add MR approval settings column to the compliance dashboard. !36589
- Add Geo replication columns and tables for terraform states. !36594
- Allow Users to Create and Rename User Lists. !36598
- Add GraphQL API to temporarily increase storage. !36605
- Geo: Add migrations for registry and states tables for vulnerability export replication. !36620
- Prevent certain policies at Merge Request level when namespace exceeds storage limit. !36713
- Block some project abilities when namespace over storage limit. !36734
- Add vulnerabilityGrades to GraphQL API. !36861
- Add setting for max indexed file size in Elasticsearch. !36925
- Show up to date SPDX licenses for license compliance. !36926
- Add Vulnerabilities::HistoricalStatistic model. !36955
- Adjust historical vulnerability statistics after vulnerability update. !36970
- Removed Projects Page in Admin UI with restoration button. !37014 (Ashesh Vidyut)
- Add coverage fuzzing to security dashboard(backend). !37173
- Add docs about denied licenses and update feature flag. !37191
- Extend configuration end point to return json when format is given. !37217
- Solicit feedback for Security Dashboards. !37317
- Add _links to epic API entity. !37395
- Delete historical vulnerability statistics entries older than 90 days. !37436
- Expose status of temporary storage increase. !37511
- Support writing variables to CI config. !37516
- Add source and destination branch data to Compliance Dashboard. !37628
- Add source and destination branch data to compliance entity. !37630
- Enable security scanner alerts. !37655
- Toggle epic confidential. !37678
- Add info and unknown counts along other severity counts. !37763
- Allow setting a default role for Group SSO. !37801
- Count pipelines that have security jobs. !37809
- Add info icons to explain lead / cycle time calculations. !37903
- Provision for csv download for merge commits in a group. !37980
- Added cluster agent GraphQL mutation and create service. !37997
- Add health status in issuable list. !38040
- Better burndown chart axis formatting. !38113
- Add vulnerabilitiesCountByDay to Group and InstanceSecurityDashboard GraphQL API. !38197
- Display Strategy Information for New Feature Flags. !38227
- Add `resolvedOnDefaultBranch` field to VulnerabilityType on GraphQL API. !38300
- Support project-level iteration creation via GraphQL. !38345
- Add excluding filter qualifier for Advanced Search queries. !38400
- Implement a GraphQL mutation for MR creation flow in SAST Config. !38406
- Add ability to update issue board configuration options using GraphQL. !38413
- Add GraphQL mutation to set the epic of an issue. !38494
- Add Merge Commit CSV export button in Compliance Dashboard. !38513
- Index trial groups in Elasticsearch. !38541
- Add cron worker to clean up expired subscriptions from Elasticsearch. !38551
- Add value stream analytics filter bar. !38576
- Offline copy of SPDX catalogue. !38691
- Add GraphQL query for a single iteration. !38692
- Track unique visitors in Compliance related pages. !38851
- Add API endpoint to revoke PATs. !39072
- Add SAST Configuration UI. !39085
- Allow using of negated filters in board epic issues GraphQL query. !39089
- Add commented_by to approval_settings endpoint. !39237
- Add support for updating SAST config. !39269
- Enable creating multiple value streams. !39299
- Enable on-demand DAST scan feature flag by default. !39411
- Expose scopedPath and scopedUrl to Iteration type in GraphQL. !39543
- Enable breadcrumbs in security dashboard. !39635
- API to retrieve group push rules. !39642
- Add size field to graphql query to extract information about SAST Config UI. !39736

### Other (23 changes, 2 of them are from the community)

- Geo - Admin Area > Geo > Uploads search is limited to 1000 records. !36391
- Clarify that Unleash client app name must be the running environment name. !37255
- Remove :skip_web_ui_code_owner_validations feature flag. !37367
- Replace $gray-300 hex value, remap usages to $gray-200. !37586
- Replace GlDeprecatedButton with GlButton. !37602
- Update Load Performance Testing k6 version to 0.27.0. !37680
- Switch to faraday_middleware-aws-sigv4 gem for signing Elasticsearch request in AWS. !38016
- Replace deprecated button with new button. !38074
- Modify iteration quick action tooltip. !38091 (Marcin Sedlak-Jakubowski)
- Add text to export button. !38189
- Geo - Admin Area > Geo > Projects/Designs search is limited to 1000 records. !38347
- Replace GlDeprecatedButton with GlButton in Requirements form. !38422
- Updating $gray-600 hex value and replacing instances with $gray-400. !38448
- Update css class to gl- classes. !38640
- Replace deprecated button with new button. !38695
- Replace -700 hex value, replace usages with -500. !38793
- Remove blacklist terminology from License Compliance. !39071
- Migrate merge immediately dialog away from deprecated button. !39284
- Change location fingerprint calculation for container scanning. !39445
- Remove a card-small class from HAML files under /ee. !39551 (Takuya Noguchi)
- Migrate checkout step summary buttons away from legacy buttons. !39561
- Store/Update new location fingerprint for container scanning vulnerabilities. !39696
- Replace -800 hex value, replace usages with -700. !39734


## 13.2.8 (2020-09-02)

- No changes.

## 13.2.7 (2020-09-02)

### Security (2 changes)

- Sanitize vulnerability history comment.
- Fix displaying epics visibility in issue sidebar.


## 13.2.6 (2020-08-18)

- No changes.

## 13.2.5 (2020-08-17)

- No changes.

## 13.2.4 (2020-08-11)

### Performance (1 change)

- Preload all associations in Vulnerability GraphQL API. !38556


## 13.2.3 (2020-08-05)

- No changes.

## 13.2.2 (2020-07-29)

- No changes.

## 13.2.0 (2020-07-22)

### Security (1 change)

- Ensure passwords and access tokens don't appear in SCIM errors.

### Removed (3 changes)

- Remove reference to sast:container. !32061
- Revert Add scanner name. !33442
- Stop recording connection pool metrics for load balancing hosts. !33749

### Fixed (91 changes, 2 of them are from the community)

- Stop recording JSON parser errors due to third party license scanning integrations. !26944
- Improve Requirements Management empty state. !30716 (Marcin Sedlak-Jakubowski)
- Display warning for issues moved from service desk on frontend. !31803
- Add truncation for the environment dropdown. !32267
- Add negated params filter to epics search. !32296
- Clean up serialized objects in audit_events. !32434
- Migrate dismissal data from Vulnerability Feedback to Vulnerabilities. !32444
- Prevent last Group Managed Account owner with access from accidental unlinking. !32473
- Fix issues with editing epic on Boards sidebar. !32503 (Eulyeon Ko)
- Dependency List shows only vulnerabilities from Gemnasium analyzer instead of all Dependency Scanning reports. !32560
- Ensure users can unlink Group SAML when the group has SAML disabled. !32655
- Fix Elasticsearch query error for ES 7.7. !32813
- Display epic issues with null relative position. !33105
- Fix description diff delete button not hidden after clicked. !33127
- Fix Elasticsearch illegal_argument_exception when searching for large files. !33176
- Support nuget dependencies in the API. !33389
- Fix GraphQL query to fetch vulnerable projects of subgroups. !33410
- Preserve order when applying scoped labels by title. !33420
- Revert breaking changes to allow conan_sources.tgz and conan_export.tgz files in the Conan repository. !33435
- Improve regex for geo auth keys checker. !33447
- Fix confidentiality note on epic's comment field to display the correct warning text. !33486
- Geo - Does not sync files on Object Storage when syncing object storage is enabled, but the Object Storage is disabled for the data type. !33561
- Fix creating merge requests with approval rules. !33582
- Specify group url in notification email. !33613
- Fix column overlap on long texts. !33614
- Display validation errors when issue link creation fails. !33638
- Geo - Does not try to unlink file when it not possible to get the file path while cleaning orphaned registries. !33658
- Tilt contribution analytics x-axis chart titles. !33692
- Geo: Fix synchronization disabled on primary UI. !33760
- Change the linkType argument for issueLinks query to enum. !33828
- Allow admins to see project despite of ip restriction set on a group level. !34086
- Return empty scans when head_pipeline is missing. !34193
- Render security dashboard for projects without pipeline available. !34219
- Include Epics in Roadmap whose parents are not part of Roadmap. !34243
- Geo - Fix Gitlab::Geo::Replication::BaseTransfer for orphaned registries. !34292
- Authorize access to view license scan reports. !34324
- Fix errors when pushing with an expired license. !34458
- Enable active class on group packages sidebar navigation items. !34518
- Fix tooltip on vulnerability issue in security dashboard. !34560
- Fix issue with displaying Code Owner error messages in the UI. !34600
- Clear hard failure when updating mirror via UI. !34614
- Fix column styling in the vulnerability list. !34619
- Fix creating/updating issues with epic_iid parameter on API. !34641
- Fix alignment of analytics dropdowns. !34721
- Allow auditor user to access project private features. !34794
- Refresh vulnerability state and timestamp when changed by another user. !34837
- Remove SELECT N+1 on software license policies. !34866
- Remove correct feature flag strategy when removing strategy that is not persisted. !34889
- Geo - Fix repositories deletion after project removal. !34963
- Remove spacing interval between soft deleted projects. !35046
- Geo - Does not sync expired job artifacts. !35082
- Fix passing date params in VSA Summary request. !35152
- Fixes a bug that would prevent the dependencies list from rendering for user that aren't authorized to see the vulnerabilities. !35171
- Fix failing filtered search when re-submitting epic tokens. !35205
- Fix visual regression for MR approve button. !35213
- Forbid deleting a feature flag user list associated with a strategy. !35275
- Geo: Fix incorrect Package File progress bar total count. !35294
- Fix display of IP addresses in audit logs. !35356
- Fix character escaping on approvals summary. !35564
- Change required value for user callout props. !35620
- Fix alignment for the project manager in the security dashboard. !35665
- Geo - Does not sync LFS objects from fork networks. !35692
- Fix usage graph not exceeding 100%. !35758
- Fix pagination on Group Audit Events. !35767
- Always show delete button on feature flag strategies. !35786
- Display occurrences in Pipeline Security view when scanner information is missing. !35795
- The conan package presenter will now only read conan packages. !35971
- Recalculate CI extra minutes when monthly minutes default to nil. !36046
- Fix overlapping identifer string. !36108
- Fix 404 errors when "No epic" selected. !36137
- Fix overflow of Identifier content on pipeline's Security tab. !36159
- Fix zero-downtime reindexing docs count. !36173
- Fix avatar popover not appearing for delayed data. !36254
- Fix bug with IndexStatus not being set on indexing project. !36266
- Always run the stop_dast_environment. !36372
- Fix passing filter params to VSA time summary queries. !36441
- Show error when attempting to delete feature flag user list that is in use. !36487
- Geo: Fix Attachments and Job artifacts showing "Synchronization disabled". !36492
- Change default vendor name to GitLab if not defined in the security schema. !36519
- Fix difference between button sizes in the instance level security dashboard. !36668
- Fix BulkIndexer flush returning nil values after failure. !36716
- Always sort Elasticsearch searches by relevance not updated_at. !36774
- Do not render export button when instance level security dashbaord is uninitialized. !36843
- Geo - Fix Button Icon Alignment. !36867
- Correct SystemCheck name for Elasticsearch. !36903
- Fallback to `created_at` when `merged_at` is missing in Insights charts. !36930
- Geo - Update version errors. !36984
- Present only issues visible to user in Vulnerabilitiy Issue Links API. !36987
- Fix: Geo file downloads can block Sidekiq threads.
- Create issue from vulnerability has link to branch.
- Allow to remove subepics when user downgrades its license.

### Changed (73 changes)

- Update header for security config page and change to GlTable. !31471
- Display expiring subscription banner on more pages. !31497
- Remove license management from CI/CD settings. !31553
- Elasticsearch integration started using aliases instead of using indices directly. !32107
- Geo Form Validations. !32263
- Move Group-level IP address restriction feature to GitLab Premium. !32396
- Update Compliance Dashboard to use a table layout. !32440
- Add link to Node URL. !32471
- Display Project and Subgroup milestones on Roadmap. !32496
- Enable CI Minutes-related Feature Flags by default. !32581
- Remove partial word matching from code search. !32771
- Add authentication information to usage ping. !32790
- Add tooltip with description to unknown severity badge icon. !33131
- Update group audit events to use the new searchable table. !33305
- Improve the clarity of the MR approvals tooltip UI. !33329
- Dont display subscription banner if auto_renew nil. !33422
- Change approved to merged in Contribution Analytics. !33535
- Geo: Add rake task to check replication status. !33834
- Changes the displayed summary text in security reports in merge requests. !33857
- Update merge train settings checkbox text. !34073
- Update project audit events to use the new searchable table. !34176
- Analytics Insights page: Load charts individually, instead of waiting for all data to load before displaying the page. !34290
- Add polling to metrics widget. !34314
- Added CI_HAS_OPEN_REQUIREMENTS environment variable. !34419
- Add evidence and scanner fields to standalone vulnerability page. !34498
- Geo Node Form - Redesign. !34561
- Renamed Browser Performance Testing feature to be clearer, CI report now also shows unchanged values. !34634
- Update the "show labels" toggle on boards to persist using localStorage. !34728
- Omit already-trialed namespaces from trial select options. !34770
- Render storage graph when there is a limit set. !34931
- Back Project Severity Status component with GraphQL data. !35031
- Make registry table as SSOT to verify Projects and Wikis. !35095
- Add scanner type to vulnerability row. !35150
- Switch to use default report name for license_scanning job. !35159
- Ensure all newly paid groups are indexed. !35172
- Return null in securityReportSummary when the report didn't run. !35218
- Highlight expired SSH or PAT credentials in the credential inventory. !35229
- Show revoked date in credentials inventory for personal access tokens. !35251
- Add identifiers column to pipeline security tab. !35284
- Make cluster health dashboard available to all self-hosted paid tiers users. !35333
- Automatically enable Elasticsearch indexing with 'gitlab:elastic:index'. !35342
- Update storage views to show snippets size. !35419
- Add line number to SAST and Secret Detection. !35536
- Change "Restrict membership by email" field from a comma separated list to the GitLab UI Token Selector component. !35543
- Moves compliance framework to GitLab Premium. !35597
- Add snippets_size to group usage statistics graph. !35608
- Refactor empty states to reflect better messages. !35624
- Update pipeline minute warning button style. !35675
- Add identifier column to the project security dashoard. !35760
- Use IP address from request on audit events. !35834
- Expand Security & Compliance tab when viewing Vulnerabilities Details page. !35855
- Change the index on project_id column of vulnerability_statistics table to be unique. !35861
- Geo Settings Form - Redesign. !35879
- Default new feature flag strategies to all users. !35883
- Remove feature flag strategy help text from the UI. !35887
- Update pipeline security tab filter label and docs. !35893
- Introduce new messaging to include a 30 day grace period for subscription expiration. !35897
- Create TODOs for merge train errors. !35951
- Colorize security summaries in merge requests. !36035
- Add the scan vendor into the scanner column of the vulnerability list. !36145
- Provide CI data to the security configuration page to enable SAST job. !36225
- Change "Restrict access by IP address" field from a comma separated list to the GitLab UI Token Selector component. !36240
- Allow searching word tokens with letters, numbers and underscores in advanced global search. !36255
- Count health status only for opened issues. !36359
- Allow to link vulnerability with issues from other projects. !36410
- Add "Manage" column and tweak "Status" wording in the Security Configuration page. !36432
- Update Project deletion text based on deletion mode. !36461
- Add Prometheus Metrics for Index Pause Sidekiq Queue. !36473
- Autocomplete confidential only epics & issues. !36687
- Add scanner vendor to pipeline scanner column. !36764
- Rename Strategies to Focus on Affected Users. !36833
- Include Elasticsearch query params in Performance Bar. !36899
- add gl-coverage-fuzzing-report.json to artifacts. !37110

### Performance (25 changes)

- Fix N+1 queries for Elastic Web Search projects scope. !30346
- Fix N+1 queries for Elastic Search merge_requests scope. !30546
- Improve performance of Advanced Search API (Issues scope) by preloading more associations. !30778
- Update index_ci_builds_on_name_and_security_type_eq_ci_build index to support secret-detection. !31785
- Fix N+1 queries for Elastic Search projects scope. !32688
- Fix N+1 queries for Elastic Search milestones scope. !33327
- Geo - Make registry table SSOT for LFS objects. !33432
- Harden operations_dashboard_default_dashboard usage query. !33952
- Harden users_created usage data queries. !33956
- Harden security ci build job queries. !33966
- Optimize queries in MergeRequestsComplianceFinder. !34482
- Save composer.json to package metadata. !34494
- Geo: Make registry table SSOT for job artifacts. !34590
- Optimize permission checking when finding subgroup epics. !35061
- Show count of all epics on group page no matter if user can see them or not. !35129
- Speed up Advanced global search regex for file path segments. !35292
- Optimize issues_with_health_status usage ping counter. !35298
- Fix N+1 queries for Elastic Search commits scope. !35449
- Don't index the same project in Elasticsearch in parallel. !35842
- Geo: Make registry table SSOT for uploads. !35921
- Avoid N+1 of group associations in Search. !36544
- Prevent 2nd Elasticsearch query for project searches. !36672
- Fix N+1 in the RootController#index. !36805
- Make Registry table SSOT for projects and wikis. !36901
- Make Registry table SSOT for designs. !36999

### Added (133 changes, 5 of them are from the community)

- Add list limit metric to API. !27324
- Implement Go module proxy MVC (package manager for Go). !27746 (Ethan Reesor)
- Improve Vulnerability Management with Standalone Vulnerabilities. !28212
- Add viewer and linker for go.mod and go.sum. !28262 (Ethan Reesor @firelizzard)
- Add usage statistics for modsecurity total packets/anomalous packets. !28535
- Keep artifacts referenced by release evidence. !29350
- Add periodic worker for collecting network policy usage. !30328
- REST API membership responses for group owner enqueries include group managed account emails. !30584
- Add table to Issues Analytics. !30603
- Add ability to pause and resume Elasticsearch indexing. !30621
- Show the status of stand-alone secrets analyzer on the configuration page. !31167
- Support transferring and displaying image uploads on Status Page. !31269
- Add Pipeline.securityReportSummary to GraphQL. !31550
- Create test reports table. !31643
- Show usage graph for each storage type. !31649
- Add requirements filtering on author username and search by title. !31857
- Add ability to download patch from vulnerability page. !32000
- Add callout for user count threshold. !32404
- Make group/namespace name in email a link to group overview page. !32461
- Add api endpoint to retrieve resource weight events. !32542
- Add ability to select Epic while creating a New Issue. !32572
- Expose test reports on GraphQL. !32599
- Allow approval rules to be reset to project defaults. !32657
- Save setting for auto-fix feature. !32690
- Geo - Make Geo::RegistryConsistencyWorker clean up unused registries. !32695
- Add new epic creation page. !32701
- Add policy for auto_fix. !32783
- Send email notifications on Issue Iteration change. !32817
- Add support for bulk editing health status and epic on issues. !32875
- Add quick actions for iterations in issues. !32904
- Add validation to maven package version. !32925 (Bola Ahmed Buari)
- Add Elasticsearch to Sidekiq ServerMetrics. !32937
- Added CI parser for requirements reports. !33031
- Add state events to burnup chart data. !33048
- Introduce `userNotesCount` field for VulnerabilityType on GraphQL API. !33058
- Bulk edit health status. !33065
- Add project audit events API. !33155 (Julien Millau)
- Introduce `issueLinks` field for VulnerabilityType on GraphQL API. !33173
- Add Elasticsearch metrics in Rack middleware. !33233
- Adds NuGet project and license URL to the package details page. !33268
- Internationalize templates titles. !33271
- Adds a new Dependencies tab for NuGet packages on the package details page. !33303
- Support AWS IAM role for ECS tasks in Elasticsearch client. !33456
- Allow to specify multiple domains when restricting group membership by email domain. !33498
- Add MR approval stats to group contribution analytics. !33601
- Create sticky section in security dashboard layout. !33651
- Add Network Policy Management to the Threat Monitoring page. !33667
- Show secret_detection in report types. !33682
- Adds NuGet package icon to package details page. !33701
- Allow to specify `period_field` in Insights config. !33753
- Ability to make PAT expiration optional in self managed instances. !33783
- Add secret detection for GraphQL API. !33797
- Show test report status badge on Requirements list. !33848
- Pin selection summary/list header to the page top. !33875
- Persist user preferences for boards. !33892
- Add compliance frameworks to application settings table. !33923
- Fixes inconsistent package title icon colors. !33933
- Retry failed vulnerability export background jobs. !33986
- Geo Package Files UI. !34004
- Add report artifacts' links to release evidence. !34058
- Add cluster reindexing feature to our ES integration. !34069
- Add in-app notification for Personal Access Token expiry. !34101
- Add "New epic" button within epic page. !34109
- Add MR note to standalone vulnerability page. !34146
- Show issue link on security dashboard when vulnerability has an issue. !34157
- Persist individual requirement report results to test report. !34162
- Geo Package Files - Sync Counts. !34205
- Upgrade to `license_scanning` report v2.1. !34224
- Add group wiki REST API. !34232
- Epic bulk edit. !34256
- Display Saved User Lists by Feature Flags. !34294
- Add PHP Composer Package Support. !34339 (Jochen Roth @ochorocho, Giorgenes Gelatti)
- Allow Hiding/Collapsing of Milestone header on Roadmap. !34357
- Add csv export button to group security dashboard. !34374
- Prevent MR from merging if denied licenses are found. !34413
- Allow Users to Delete User Lists. !34425
- Alert Users That Lists Are Modified By API Only. !34559
- Add ability to view tokens without expiry enforcement. !34570
- Add support for gl-coverage-fuzzing-report.json and security dashboard parsing. !34648
- Geo: Enable Package File replication. !34702
- Add compliance_frameworks list to project API. !34709
- Add scanner name and identifiers to VulnerabilityType. !34766
- Add request/response to standalone vulnerability page. !34811
- Add scanner filter in Vulnerability GraphQL API. !34824
- Add Project.complianceFrameworks field to GraphQL schema. !34838
- Set checkboxes to be on by defualt for list. !34893
- Add coverage fuzzing CI template. !34984
- Add vendor to Vulnerability Scanners. !35004
- Admin UI change to trigger Elasticsearch in-cluster re-indexing. !35024
- Add vulnerability scanner query to GraphQL API. !35109
- Enable new version feature flags by default. !35192
- Add the MR author to MR's list on the compliance dashboard. !35206
- Add storage_size_limit to plan_limits table. !35219
- Add parsing Vendor name from Security Reports. !35222
- Add project count with overridden approval rules in merge request to usage ping. !35224
- Link documentation from GitLab for Jira app. !35227
- Add license approval rule section and enable feature by default. !35246
- Add Namespace API to set additionally purchased storage. !35257
- Added MR Load Performance Testing feature. !35260
- Add toggle to sort epic activity feed. !35302
- Show User List Details. !35369
- Let users modify feature flag user lists. !35373
- Update vulnerabilities and findings when report occurrences are updated. !35374
- Add Maintenance mode application settings fields. !35376
- Add running out of minutes warning to CI job pages. !35622
- Add scanned resources to security report. !35695
- Display comment icon on vulnerability list in Security Dashboard. !35863
- Allow merge when `License-Check` approve denied policies. !35885
- Add DAST URL MR Widget modal. !35945
- Return ID of newly created vulnerability issue link in API. !35947
- Add NULL value scannedResourcesCsvUrl to securityReportSummary. !35949
- Allow users to download the DAST scanned resources for a pipeline as a CSV. !36019
- Add security scanner alerts to project to project security dashboard. !36030
- Create GraphQL query to extract analyzers information. !36153
- Expose Vendor in Scanner in Vulnerability Findings API. !36184
- Add MVC for Opsgenie integration. !36199
- Update Usage Ping data to track Merge Requests with added rules. !36222
- Add filtering by scanner ID in Vulnerability Occurrences REST API. !36241
- Allow creating confidential epics. !36271
- Audit changes to project approval groups. !36393
- Expose temporary storage increase end date in api. !36495
- Add search history support for Requirements. !36554
- Add related issues widget to feature flags. !36617
- Setup group level Value Stream DB table. !36658
- Enforce presence of Value Stream when creating a stage. !36661
- Add ability to download fuzzing artifacts from pipeline page. !36676
- Scope instance-level MR settings to compliance-labeled projects. !36685
- Include ancestors in Iteration query. !36766
- Add button to Security Configuration page to enable SAST, and Auto DevOps prompt. !36796
- Add scanned_resources CSV path to Security Report Summary. !36810
- Add MR approval status to the MR compliance entity. !36824
- Enables Iterations by default. !36873
- Update Iteration status automatically. !36880

### Other (18 changes, 2 of them are from the community)

- Add license ID to license view. !19113
- Update deprecated Vue 3 slot syntax in ee/app/assets/javascripts/vue_shared/security_reports/components/modal.vue. !31966 (Gilang Gumilar)
- Added DB index on confidential epics column. !32443
- Allow ci minutes reset service to continue in case of failure. !32867
- Remove unused index for vulnerabiliy confidence levels. !33149
- Update vulnerabilities badge design in Dependency List. !33417
- Add geo_primary_replication_events to usage data. !33424
- Add new status page attributes to usage ping. !33790
- Remove optimized_elasticsearch_indexes_project feature flag. !33965
- Relocate Go models. !34338 (Ethan Reesor (@firelizzard))
- Limit child epics and epic issues page size. !34553
- Correct typo in "single sign-on", per specs. !35258
- Update UI links in EE features. !35489
- Replace .html with .md in documentation links. !35864
- Update more UI links in EE features. !36177
- Apply label color to shared Analytics label token. !36205
- Alert Opsgenie integration errors. !36648
- Resolve duplicate use of shorcuts-tree. !36732


## 13.1.10 (2020-09-02)

- No changes.

## 13.1.9 (2020-09-02)

### Security (2 changes)

- Sanitize vulnerability history comment.
- Fix displaying epics visibility in issue sidebar.


## 13.1.8 (2020-08-18)

- No changes.

## 13.1.7 (2020-08-17)

- No changes.

## 13.1.6 (2020-08-05)

- No changes.

## 13.1.5 (2020-07-23)

### Fixed (2 changes)

- Geo: Fix Attachments and Job artifacts showing "Synchronization disabled". !36492
- Fix: Geo file downloads can block Sidekiq threads.


## 13.1.3 (2020-07-06)

### Security (1 change)

- Maven packages upload endpoint is now properly using the uploaded file set by middleware.


## 13.1.2 (2020-07-01)

### Security (2 changes)

- Fixed pypi package API XSS.
- Fix project authorizations for instance security dashboard.


## 13.1.1 (2020-06-23)

- No changes.

## 13.1.0 (2020-06-22)

### Security (1 change)

- Ensure passwords and access tokens don't appear in SCIM errors.

### Removed (2 changes)

- Revert Add scanner name. !33442
- Stop recording connection pool metrics for load balancing hosts. !33749

### Fixed (35 changes, 2 of them are from the community)

- Stop recording JSON parser errors due to third party license scanning integrations. !26944
- Improve Requirements Management empty state. !30716 (Marcin Sedlak-Jakubowski)
- Display warning for issues moved from service desk on frontend. !31803
- Add truncation for the environment dropdown. !32267
- Add negated params filter to epics search. !32296
- Clean up serialized objects in audit_events. !32434
- Prevent last Group Managed Account owner with access from accidental unlinking. !32473
- Fix issues with editing epic on Boards sidebar. !32503 (Eulyeon Ko)
- Dependency List shows only vulnerabilities from Gemnasium analyzer instead of all Dependency Scanning reports. !32560
- Ensure users can unlink Group SAML when the group has SAML disabled. !32655
- Fix Elasticsearch query error for ES 7.7. !32813
- Display epic issues with null relative position. !33105
- Fix description diff delete button not hidden after clicked. !33127
- Fix Elasticsearch illegal_argument_exception when searching for large files. !33176
- Support nuget dependencies in the API. !33389
- Fix GraphQL query to fetch vulnerable projects of subgroups. !33410
- Preserve order when applying scoped labels by title. !33420
- Revert breaking changes to allow conan_sources.tgz and conan_export.tgz files in the Conan repository. !33435
- Improve regex for geo auth keys checker. !33447
- Fix confidentiality note on epic's comment field to display the correct warning text. !33486
- Geo - Does not sync files on Object Storage when syncing object storage is enabled, but the Object Storage is disabled for the data type. !33561
- Fix creating merge requests with approval rules. !33582
- Specify group url in notification email. !33613
- Fix column overlap on long texts. !33614
- Geo - Does not try to unlink file when it not possible to get the file path while cleaning orphaned registries. !33658
- Geo: Fix synchronization disabled on primary UI. !33760
- Change the linkType argument for issueLinks query to enum. !33828
- Allow admins to see project despite of ip restriction set on a group level. !34086
- Return empty scans when head_pipeline is missing. !34193
- Render security dashboard for projects without pipeline available. !34219
- Include Epics in Roadmap whose parents are not part of Roadmap. !34243
- Geo - Fix Gitlab::Geo::Replication::BaseTransfer for orphaned registries. !34292
- Fix errors when pushing with an expired license. !34458
- Enable active class on group packages sidebar navigation items. !34518
- Fix creating/updating issues with epic_iid parameter on API. !34641

### Changed (18 changes)

- Update header for security config page and change to GlTable. !31471
- Display expiring subscription banner on more pages. !31497
- Remove license management from CI/CD settings. !31553
- Elasticsearch integration started using aliases instead of using indices directly. !32107
- Geo Form Validations. !32263
- Move Group-level IP address restriction feature to GitLab Premium. !32396
- Add link to Node URL. !32471
- Display Project and Subgroup milestones on Roadmap. !32496
- Enable CI Minutes-related Feature Flags by default. !32581
- Remove partial word matching from code search. !32771
- Add authentication information to usage ping. !32790
- Add tooltip with description to unknown severity badge icon. !33131
- Improve the clarity of the MR approvals tooltip UI. !33329
- Change approved to merged in Contribution Analytics. !33535
- Update merge train settings checkbox text. !34073
- Analytics Insights page: Load charts individually, instead of waiting for all data to load before displaying the page. !34290
- Add polling to metrics widget. !34314
- Added CI_HAS_OPEN_REQUIREMENTS environment variable. !34419

### Performance (11 changes)

- Fix N+1 queries for Elastic Web Search projects scope. !30346
- Fix N+1 queries for Elastic Search merge_requests scope. !30546
- Improve performance of Advanced Search API (Issues scope) by preloading more associations. !30778
- Update index_ci_builds_on_name_and_security_type_eq_ci_build index to support secret-detection. !31785
- Fix N+1 queries for Elastic Search projects scope. !32688
- Fix N+1 queries for Elastic Search milestones scope. !33327
- Geo - Make registry table SSOT for LFS objects. !33432
- Harden operations_dashboard_default_dashboard usage query. !33952
- Harden users_created usage data queries. !33956
- Harden security ci build job queries. !33966
- Save composer.json to package metadata. !34494

### Added (54 changes, 3 of them are from the community)

- Add list limit metric to API. !27324
- Implement Go module proxy MVC (package manager for Go). !27746 (Ethan Reesor)
- Improve Vulnerability Management with Standalone Vulnerabilities. !28212
- Add viewer and linker for go.mod and go.sum. !28262 (Ethan Reesor @firelizzard)
- Add usage statistics for modsecurity total packets/anomalous packets. !28535
- REST API membership responses for group owner enqueries include group managed account emails. !30584
- Add table to Issues Analytics. !30603
- Add ability to pause and resume Elasticsearch indexing. !30621
- Show the status of stand-alone secrets analyzer on the configuration page. !31167
- Support transferring and displaying image uploads on Status Page. !31269
- Add Pipeline.securityReportSummary to GraphQL. !31550
- Create test reports table. !31643
- Show usage graph for each storage type. !31649
- Add requirements filtering on author username and search by title. !31857
- Add ability to download patch from vulnerability page. !32000
- Add callout for user count threshold. !32404
- Make group/namespace name in email a link to group overview page. !32461
- Add ability to select Epic while creating a New Issue. !32572
- Expose test reports on GraphQL. !32599
- Allow approval rules to be reset to project defaults. !32657
- Save setting for auto-fix feature. !32690
- Geo - Make Geo::RegistryConsistencyWorker clean up unused registries. !32695
- Add policy for auto_fix. !32783
- Send email notifications on Issue Iteration change. !32817
- Add support for bulk editing health status and epic on issues. !32875
- Add quick actions for iterations in issues. !32904
- Add Elasticsearch to Sidekiq ServerMetrics. !32937
- Added CI parser for requirements reports. !33031
- Add state events to burnup chart data. !33048
- Introduce `userNotesCount` field for VulnerabilityType on GraphQL API. !33058
- Add project audit events API. !33155 (Julien Millau)
- Introduce `issueLinks` field for VulnerabilityType on GraphQL API. !33173
- Add Elasticsearch metrics in Rack middleware. !33233
- Adds NuGet project and license URL to the package details page. !33268
- Adds a new Dependencies tab for NuGet packages on the package details page. !33303
- Allow to specify multiple domains when restricting group membership by email domain. !33498
- Add MR approval stats to group contribution analytics. !33601
- Create sticky section in security dashboard layout. !33651
- Add Network Policy Management to the Threat Monitoring page. !33667
- Show secret_detection in report types. !33682
- Adds NuGet package icon to package details page. !33701
- Ability to make PAT expiration optional in self managed instances. !33783
- Add secret detection for GraphQL API. !33797
- Show test report status badge on Requirements list. !33848
- Persist user preferences for boards. !33892
- Fixes inconsistent package title icon colors. !33933
- Retry failed vulnerability export background jobs. !33986
- Add MR note to standalone vulnerability page. !34146
- Show issue link on security dashboard when vulnerability has an issue. !34157
- Geo Package Files - Sync Counts. !34205
- Upgrade to `license_scanning` report v2.1. !34224
- Display Saved User Lists by Feature Flags. !34294
- Add csv export button to group security dashboard. !34374
- Alert Users That Lists Are Modified By API Only. !34559

### Other (9 changes, 2 of them are from the community)

- Update deprecated Vue 3 slot syntax in ee/app/assets/javascripts/vue_shared/security_reports/components/modal.vue. !31966 (Gilang Gumilar)
- Added DB index on confidential epics column. !32443
- Allow ci minutes reset service to continue in case of failure. !32867
- Remove unused index for vulnerabiliy confidence levels. !33149
- Update vulnerabilities badge design in Dependency List. !33417
- Add geo_primary_replication_events to usage data. !33424
- Add new status page attributes to usage ping. !33790
- Remove optimized_elasticsearch_indexes_project feature flag. !33965
- Relocate Go models. !34338 (Ethan Reesor (@firelizzard))


## 13.0.14 (2020-08-18)

- No changes.

## 13.0.13 (2020-08-17)

- No changes.

## 13.0.12 (2020-08-05)

- No changes.

## 13.0.11 (2020-08-05)

This version has been skipped due to packaging problems.

## 13.0.10 (2020-07-09)

### Fixed (1 change)

- Geo - Does not sync LFS objects from fork networks. !36202


## 13.0.9 (2020-07-06)

### Security (1 change)

- Maven packages upload endpoint is now properly using the uploaded file set by middleware.


## 13.0.8 (2020-07-01)

### Security (2 changes)

- Fixed pypi package API XSS.
- Fix project authorizations for instance security dashboard.


## 13.0.7 (2020-06-25)

- No changes.

## 13.0.6 (2020-06-10)

### Security (1 change)

- Do not set fallback mirror user.


## 13.0.4 (2020-06-03)

- No changes.

## 13.0.3 (2020-05-29)

- No changes.

## 13.0.1 (2020-05-27)

### Security (3 changes)

- Change the mirror user along with pull mirror settings.
- Allow only users with a verified email to be member of a group when the group has restricted membership based on email domain.
- Do not auto-confirm email in Trial registration.


## 13.0.0 (2020-05-22)

### Security (1 change)

- Apply CODEOWNERS validations to web requests. !31283

### Removed (1 change)

- Remove deprecated route for serving full-size Design Management design files. !30917

### Fixed (77 changes, 5 of them are from the community)

- Enforce CODEOWNER rules for renaming of files. !26513
- Preserve date filters in value stream and productivity analytics. !27102
- Fix 404s when clicking links in full code quality report. !27138
- Remove Admin > Settings > Templates link from sidenav when insufficient license. !27172
- Geo - Does not write to DB when using 2FA via OTP for admin mode. !27450
- Use group parent for subgroup labels requests. !27564
- Hidden stages should not appear in duration chart. !27568
- Maven packages API allows HEAD requests to package files when using Amazon S3 as a object storage backend. !27612
- Prevent renaming a locked file. !27623
- Use absolute URLs to ensure links to the source of SAST vulnerabilities resolve. !27747
- Prevent issues from being promoted twice. !27837
- Display error message in custom metric form validation when prometheus URL is blocked. !27863
- Append inapplicable rules when creating MR. !27886
- Fix passing project_ids to Value Stream Analytics. !27895
- Support inapplicable rules when creating MR. !27971
- Fix vsa label dropdown limit. !28073
- Fix analytics group and project loading spinners styling. !28094
- Include subgroups when populating group security dashboard. !28154
- Hide ability to create alert on custom metrics dashboard. !28180
- Fix epics not preserving their state on Group Import. !28203
- Fix invalid scoped label documentation URL when rendered in Markdown. !28268
- Fix create epic in tree after selecting Add issue. !28300
- Fix HTTP status code for Todos API when an epic cannot be found. !28310
- Allow SCIM to create an identity for an existing user. !28379
- Perform Geo actions on projects only. !28421
- Allow unsetting "Required pipeline configuration" for CI/CD. !28432
- Geo: Self-service framework does not associate geo_event_log row to geo_event. !28457
- Return overridden property in API response. !28521
- Fix billed users id and count from shared group. !28645
- Hide Request subtitle when Threat Monitoring has no data. !28760
- Fix repository settings page loading issues for some imported projects with pull mirroring. !28879
- Fix group_plan in group member data for system hooks. !29013
- Fix imageLoading bug when scrolling back to design. !29223
- Fix Elasticsearch rollout stale cache bug. !29233
- Resolve Creating an annotation on the design that is bigger that screen size is broken. !29351
- Fix incorrect dropdown styling for embedded metric charts. !29380 (Gilang Gumilar)
- Close all other sidebars when the boards list settings sidebar is opened. !29456
- Fix incorrect repositioning of design comment pins when mouse leaves viewport. !29464
- Fix board edit weight values 0 or None. !29606
- Fix lack-of padding on design view notes sidebar. !29654
- Remove duplicate QA attribute for burndown charts. !29719
- Add validation to Conan recipe that conforms with Conan.io. !29739 (Bola Ahmed Buari)
- Fix caching performance and some cache bugs with elasticsearch enabled check. !29751
- Fix wiki indexing for imported projects. !29952
- Fix filter todos by design. !29972 (Gilang Gumilar)
- Fix the error message on Security & Operations dashboard by fixing the API response. !30047
- Fix showing New requirement button to unauthenticated user. !30085 (Gilang Gumilar)
- Ignore invalid license_scanning reports. !30114
- Sort dependency scanning reports before merging. !30190
- Fix typos on Threat Management page. !30218
- Fix infinte loading spinner when visiting non-existent design. !30263
- Fix third party advisory links. !30271
- Fix dismissal state not being updated. !30503
- Add sort and order for policy violations. !30568
- If a parent group enforces SAML SSO, when adding a member to that group, its subgroup or its project the autocomplete shows only users who have identity with the SAML provider of the parent group. !30607
- Geo: Fix empty synchronisation status when nothing is synchronised. !30710
- Don't hide Open/Closed Icon for Issue. !30819
- No seat link sync for licenses without expiration. !30874
- Fix project insights page when projects.only parameter is used. !30988
- Fixes styling on vulnerability counts. !31076
- Hide child epic icon on Roadmap for accounts without child epics support. !31250
- Add license check for the 'send emails from Admin area' feature. !31434
- Avoid saving author object in audit_events table. !31456
- Fix 500 errors caused by globally searching for scopes which cannot be used without Elasticsearch. !31508
- Show .Net license scan results as links. !31552
- Fix incorrect notice text on insights page. !31570
- Add license restriction to HealthStatus. !31571
- Fix issues search to include the epic filter ANY. !31614
- Reduce 413 errors when making bulk indexing requests to Elasticsearch. !31653
- Fix CI minutes notification when unauthenticated. !31724
- Add LFS workhorse upload path to allowed upload paths. !31794
- Relax force pull mirror update restriction. !32075
- Show correct last successful update timestamp. !32078
- Fix missing dismissed_by field. !32147
- Fix empty unit display of time metrics. !32388
- Fixes file row commits not showing for certain projects.
- Validates ElasticSearch URLs are valid HTTP(S) URLs. (mbergeron)

### Deprecated (2 changes)

- Document planned deprecation of 'marked_for_deletion_at' attribute in Projects API in GitLab 13.0. !28993
- Document planned deprecation of 'projects' and 'shared_projects' attributes in Groups API in GitLab 13.0. !29113

### Changed (64 changes, 1 of them is from the community)

- Allow Value Stream Analytics custom stages to be manually ordered. !26074
- Create more intuitive Popover information for Geo Node Sync Status. !27033
- Make "Value Stream" the default page that appears when clicking the group-level "Analytics" sidebar item. !27277 (Gilang Gumilar)
- Update renewal banner messaging and styling. !27530
- Hide company question for new account signups. !27563
- Create more intuitive Verification Popover for Geo Node Syncs. !27624
- Disabled Primary Node Removal button when removal is not allowed. !27836
- Move issue/apic hierarchy items to a tooltip. !27969
- Update copy for Adding Licenses. !27970
- Sort events alphabetically on Value Stream Analytics Stage form. !28005
- Return 202 Accepted status code when fetching incompleted Vulnerability Export from API. !28314
- Use dropdown to change health status. !28547
- Change GraphQL arguments in group.timelogs query to use startTime and endTime. !28560
- Enable issue board focus mode for all tiers on Enterprise Edition. !28597
- Clarify detected license results in merge request: Group licenses by status. !28631
- Deleting packages from a deeper paginated page will no longer return you to the first page. !28638
- Sort Dependency List by severity by default. !28654
- Make Dependency List pipeline subheading more succinct. !28665
- Enable export issues feature for all tiers on Enterprise Edition. !28675
- Remove scoped labels documentation link. !28701
- Change summary text copy for license-compliance MR widget. !28732
- Update License Compliance docs url. !28853
- Differentiate between empty and disabled Geo sync. !28963
- Move deploy keys section back to repository settings. !29184
- Hide Pipeline Security tab from reporters. !29334
- Make Geo Selective Sync More Clear from the Node Details view. !29596
- Fix checkbox alignment and responsive word-break for secure table rows. !29659
- Add tracking to Subscription banner. !29735
- SSO Enforcement requires sign in within 7 days. !29786
- Geo - Better Out of Date Errors. !29800
- Replace non-standard term in Issues Analytics chart labels. !29810
- Change default icon for neutral-state items in merge request widget. !30008
- Remove tasks_by_type_chart feature flag. !30034
- Modify existing out of runner minutes banner to handle 3 different warning levels. !30088
- Resolve Allow multiple screenshots to be uploaded in copy paste. !30152
- Improve the running out of CI minutes email notification. !30188
- Change 'Whats New' dropdown item url. !30198
- Link Buy additional minutes button straight to funnel. !30248
- Improve design management image loads by avoiding refetching image urls for designs. !30280
- Change logic to find the current license. !30296
- Link license management button to license compliance policies section. !30344
- Sort license policy violations first. !30564
- Change UI requirements route from project/requirements to project/requirements_management/requirements. !30583
- Change default concurrency of merge trains to twenty. !30599
- Clarify security report findings in merge request widget. !30688
- Consolidate epic tree buttons. !30816
- Increase ProcessBookkeepingService batch to 10_000. !30817
- Modify GraphQL mutation for adding projects to Instance Security Dashboard to support only single project id. !30865
- Add subscription banner to group/subgroup pages. !30883
- Geo - Add Empty States. !31010
- Remove customizable_cycle_analytics feature flag. !31189
- Geo - Bring settings UI in-line with other Geo Views. !31257
- Cards in Epic Tree have two lines of content. !31300
- Add request information to vulnerability-detail modal. !31422
- Move registrations progress bar to a generic place and make it configurable. !31484
- Reduce epic health status noise in epic tree. !31555
- Modify GraphQL mutation for removing project from Instance Security Dashboard to use id instead of projectId. !31575
- Enable onboarding issues experiment on Welcome screen. !31656
- Expring Subscription banner has plan specific text. !31777
- Geo - Better visualize type of node on form. !31784
- Improve tooltips for compliance framework badges. !31883
- Allow developers to see ci minutes notifications. !31937
- Log Audit Event when Group SAML adds a user to a group. !32333
- Audit logs now uses filtered search.

### Performance (13 changes, 1 of them is from the community)

- Geo - Improve query to retrieve Job Artifacts, LFS Objects, and Uploads with files stored locally. !24891
- Geo - Use bulk insert to improve performance of RegistryBackfillService. !27720
- Improve Group Security Dashboard performance. !27959
- Fix N+1 queries in Audit Events controllers. !28399
- Move Clusters Application CertManager to batch counting. !28771
- Move Clusters Application Helm to batch counting. !28995
- Move Clusters Application Ingress to batch counting. !28999
- Move Clusters Application Knative to batch counting. !29003
- Preload path locks for TreeSummary. !29949
- Debounce pull mirror invocation. !30157
- Advanced Search API: Eager load more issue associations to reduce N+1 queries. !30233
- Make the ElasticCommitIndexer idempotent to enable job de-duplication. !31500 (mbergeron)
- Use data-interchange format based on .ndjson for Project import and export. !31601

### Added (129 changes, 13 of them are from the community)

- Support setting threshold for browser performance degradation through CI config. !21824
- Restrict page access when restricted level is public. !22522 (briankabiro)
- Add ability to expand epics in roadmap. !23600
- Prefer smaller image size for design cards in Design Management. !24828
- Warn users when they close a blocked issue. !25089
- Added setting to use a custom service desk email. !25240
- Add ability to explore zoomed in designs via click-and-drag. !25405
- Allow GMA groups to specify their own PAT expiry setting. !25963
- Add vulnerabilities field to QueryType. !26348
- On-demand Evidence creation. !26591
- Add API endpoint for new members' count in Group Activity Analytics. !26601
- Allow multiple root certificates for smartcard auth. !26812
- Add scanned URL count and link to scanned resources in DAST reports. !26825
- Add a button to export vulnerabilities in CSV format. !26838
- Add #resolved_on_default_branch to Vulnerability. !26906
- Migrate SAML to SCIM Identities. !26940
- Expose smaller sized Design Management design images in GraphQL. !26947
- Add Snowplow tracking for Container Registry events. !27001
- Geo - Support git clone/pull operations for repositories that are not yet replicated. !27072
- Add an indicator icon to issues on subepics when filtering by epic. !27212
- Add a count of the scanned resources to Security::Scan. !27260
- Track primary package file checksum counts. !27271
- Anonymize GitLab user/group names on Status Detail Pages. !27273
- Enable NetworkPolicy Statistics by default. !27365
- Separate approval setting entities into own class files. !27423 (Rajendra Kadam)
- Show custom 'media broken' icon for broken images in Design Management. !27460
- Display loading spinner when Design Card images are loading. !27475
- Updated link to Status Page docs. !27500
- Adds support for storing notes for vulnerabilities. !27515
- Add endpoints to fetch notes/discussions for vulnerability. !27585
- Support PyPi package upload. !27632
- Separate conan package entities into own class files. !27642 (Rajendra Kadam)
- Separate model only entities into own class files. !27665 (Rajendra Kadam)
- Add terraform report to merge request widget. !27700
- Add a DB column to allow GMA groups to specify their PAT expiry setting. !27769
- Separate user, project and entity helper modules into own class files. !27771 (Rajendra Kadam)
- Add rake task for reindexing Elasticsearch. !27772
- Separate group, member, group_detail and identity modules into own class files. !27797 (Rajendra Kadam)
- Indicate whether the alert is firing. !27825
- Support PyPi package installation. !27827
- Separate code review, design and group modules into own class files. !27860 (Rajendra Kadam)
- Add Health Status badge in Epic tree. !27869
- Separate nuget package entities into own class files. !27898 (Rajendra Kadam)
- Create issue link when creating issue from vulnerability. !27899
- Geo: Proxy SSH git operations for repositories that are not yet replicated. !27994
- Add pipeline statuses to Compliance Dashboard. !28001
- Add Usage Ping For Status Page. !28002
- Adds additional pipeline information to packages API result. !28040
- Allow to save issue health status. !28146
- Add a compliance framework setting to project. !28182
- Add project template for HIPAA Audit Protocol. !28187
- Create system note when health status is updated. !28232
- Pre-populate prometheus alert modal. !28291 (Gilang Gumilar)
- Usage ping for customized Value Stream Management stage count. !28308
- Add evidence to vulnerability details. !28315
- Added confidential column to epics table. !28428
- Geo GraphQL API: Add geoNode at root. !28454
- Refactor duplicate specs in ee user model. !28513 (Rajendra Kadam)
- Refactor duplicate specs in ee group model. !28538 (Rajendra Kadam)
- Lazy-loading design images with IntersectionObserver. !28555
- Create group-level audit event for Group SAML SSO sign in. !28575
- Renewal banner has auto-renew specific messaging. !28579
- Automatically embed metrics in issues for alerts from manually configured Prometheus instances. !28622
- Epic tree move child with drag and drop. !28629
- Show the number of scanned resources in the DAST vulnerability report. !28718
- Expose 'marked_for_deletion_on' attribute in Projects API. !28754
- Show policy violations in license compliance. !28862
- Migrate project snippets to the ghost user when the user is deleted. !28870 (George Thomas @thegeorgeous)
- Provide instance level setting to enable or disable 'default branch protection' at the group level for group owners. !28997
- Add spentAt field to TimelogType and deprecate date field. !29024
- Add hierarchy depth to roadmaps. !29105
- Add mutation to Dismiss Vulnerability GraphQL API. !29150
- Add "whats new" item to help dropdown. !29183
- Expose hasParent GraphQL field on epic. !29214
- Display indicator to rule name in approval rules. !29315
- Add status page url to setting form in UI. !29359
- Enable Standalone Vulnerabilities feature for improving Vulnerability Management. !29431
- Add `group_id` column into vulnerability_exports table. !29498
- Enable creation on custom index with rake. !29598 (mbergeron)
- Replace pipeline quota with usage quotas for user namespaces. !29806
- Add GraphQL mutation to update limit metric settings on board lists. !29897
- Adds PyPi installation instructions to package details page. !29935
- Survey Responses landing page. !29951
- Add limit metric to list type. !30028
- Add GraphQL query for Instance Security Dashboard projects. !30064
- Adds PyPi tab to the packages list page. !30078
- Export an instance-level vulnerabilities report. !30079
- Add GraphQL mutation for adding projects to Instance Security Dashboard. !30092
- Add GraphQL mutation for removing projects from Instance Security Dashboard. !30100
- Show specific success message when uploading a future license. !30161
- Show all licenses and highlight current license in license history. !30172
- Adds pipeline project name and link to package title. !30275
- Enable expiring subscription banner. !30304
- Handle subscription purchase flow via GitLab. !30324
- Add Approved By in filtered MR search. !30335
- Add autocompletion to Design View comment form. !30347
- Add confidential flag in epic create. !30370
- Add API endpoints to generate instance level security report exports. !30397
- Add scanner name, version and URL to Vulnerability Modal. !30458
- Introduce negative filters for code review analytics. !30506
- Add NuGet dependencies extraction to the GitLab Packages Repository. !30618
- Add vulnerability fields to GraphQL project, group, and global scope. !30663
- Add vulnerability history to graphQL. !30674
- Add package tags support to the GitLab NuGet Packages Repository. !30726
- Add `Group Name` and `Project Name` into vulnerability export CSV file. !30755
- Display banner to admins when there are users over license. !30813
- Geo Replication View. !30890
- Record impersonator information on audit event. !30970
- Measure project import and export service execution. !30977
- Adds package_name filter to group packages API. !30980
- Add Nuget metadatum support in GitLab Packages. !30994
- Show the You're running out of CI minutes warnings on relevant pages in GitLab. !31012
- Add spinner to roadmap. !31080
- Add standaloneVulnerabilitiesEnabled filter to group projects resolver for GraphQL. !31081
- Add push rules configuration for groups - frontend. !31085
- Add project import to group as audit event. !31103
- Add Web IDE terminal usage counter. !31158
- Add versions array to the package API payload. !31231
- Rate limit the 'Send emails from Admin Area' feature. !31308
- Add graphql endpoint for project packages list. !31344
- Add project filter. !31444
- Show specific content for future-dated licenses. !31463
- Add lead time and cycle time to value stream analytics. !31559
- Geo - Enable geo_file_registry_ssot_sync feature flag by default. !31671
- Geo - Enable geo_job_artifact_registry_ssot_sync feature flag by default. !31672
- Introduce a new API endpoint to generate group-level vulnerability exports. !31889
- Add number of projects with compliance framework to usage ping. !31923
- Adds versions tab and additional versions list to packages details page. !31940
- Add link to customer portal from license dashboard.

### Other (12 changes, 3 of them are from the community)

- Add verification related fields to packages_package_files table. !25411
- Refactor expected_paginated_array_response. !25500 (George Thomas @thegeorgeous)
- Monitoring for Elasticsearch incremental updates buffer queue. !27384
- Use warning icon for alert widget in monitoring dashboard. !27545
- Improved tests by removing duplicated specs. !28525 (Leandro Silva)
- Move service desk from Premium to Starter plan. !29980
- Change license history wording. !30148
- Make active_users param mandatory for SyncSeatLinkRequestWorker#perform. !30810
- Track group wiki storage in DB. !31121
- Replace undefined confidence with unknown severity for occurrences. !31200
- Replace undefined confidence with unknown severity for vulnerabilities. !31593
- Translate unauthenticated user string for Audit Event. !31856 (Sashi Kumar)

## 12.10.14 through 12.0.0

- See [changelogs/archive-12-ee.md](changelogs/archive-12-ee.md)

## 11.11.8 through 11.0.0

- See [changelogs/archive-11-ee.md](changelogs/archive-11-ee.md)

## 10.8.6 through 10.0.0

- See [changelogs/archive-10-ee.md](changelogs/archive-10-ee.md)

## 9.5.10 through 6.2.0

- See [changelogs/archive-ee.md](changelogs/archive-ee.md)
