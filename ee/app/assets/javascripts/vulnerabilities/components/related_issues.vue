<script>
import axios from 'axios';
import RelatedIssuesStore from 'ee/related_issues/stores/related_issues_store';
import RelatedIssuesBlock from 'ee/related_issues/components/related_issues_block.vue';
import { issuableTypesMap, PathIdSeparator } from 'ee/related_issues/constants';
import createFlash from '~/flash';
import { sprintf, __, s__ } from '~/locale';
import { joinPaths, isSafeURL, isAbsolute } from '~/lib/utils/url_utility';

// Get the issue in the format expected by the descendant components.
const getFormattedIssue = issue => ({
  ...issue,
  reference: `#${issue.iid}`,
  path: issue.web_url,
});

export default {
  name: 'VulnerabilityRelatedIssues',
  components: { RelatedIssuesBlock },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    canAdmin: {
      type: Boolean,
      required: false,
      default: false,
    },
    helpPath: {
      type: String,
      required: false,
      default: '',
    },
    projectPath: {
      type: String,
      required: true,
    },
  },
  data() {
    this.store = new RelatedIssuesStore();

    return {
      state: this.store.state,
      isFetching: false,
      isSubmitting: false,
      isFormVisible: false,
      inputValue: '',
    };
  },
  created() {
    this.fetchRelatedIssues();
  },
  methods: {
    toggleFormVisibility() {
      this.isFormVisible = !this.isFormVisible;
    },
    resetForm() {
      this.isFormVisible = false;
      this.store.setPendingReferences([]);
      this.inputValue = '';
    },
    addRelatedIssue({ pendingReferences }) {
      this.processAllReferences(pendingReferences);
      this.isSubmitting = true;
      const errors = [];

      // The endpoint can only accept one issue, so we need to do a separate call for each pending reference.
      const requests = this.state.pendingReferences.map(reference => {
        let issueId = reference;
        let projectId = this.projectPath.replace(/^\/(.+)$/, '$1'); // Remove the leading slash, i.e. '/root/test' -> 'root/test'.

        const issueRegex = /^#?(\d+)$/; // Matches '123' and '#123'.
        const linkRegex = /\/(.+\/.+)\/-\/issues\/(\d+)/; // Matches '/username/project/-/issues/123'.

        // If the reference is an issue number, parse out just the issue number.
        if (issueRegex.test(reference)) {
          [, issueId] = issueRegex.exec(reference);
        }
        // If the reference is an absolute URL that matches the issues URL format, parse out the project link and issue
        // number.
        else if (isSafeURL(reference) && isAbsolute(reference) && linkRegex.test(reference)) {
          const { pathname } = new URL(reference);
          [, projectId, issueId] = linkRegex.exec(pathname);
        }

        return axios
          .post(this.endpoint, { target_issue_iid: issueId, target_project_id: projectId })
          .then(({ data }) => {
            const issue = getFormattedIssue(data.issue);
            // When adding an issue, the issue returned by the API doesn't have the vulnerabilityLinkId property; it's
            // instead in a separate ID property. We need to add it back in, or else the issue can't be deleted until
            // the page is refreshed.
            issue.vulnerabilityLinkId = issue.vulnerabilityLinkId ?? data.id;
            const index = this.state.pendingReferences.indexOf(reference);
            this.removePendingReference(index);
            this.store.addRelatedIssues(issue);
          })
          .catch(({ response }) => {
            errors.push({
              issueReference: reference,
              errorMessage: response.data?.message ?? __('Unknown Error'),
            });
          });
      });

      return Promise.all(requests).then(() => {
        this.isSubmitting = false;

        if (errors.length) {
          // createFlash() can only show one dialog at a time and doesn't accept HTML, so we need to combine all the
          // error message into one string.
          const errorMessages = errors.map(errorConfig =>
            sprintf(
              s__('VulnerabilityManagement|Could not link %{issueReference}: %{errorMessage}.'),
              errorConfig,
            ),
          );

          createFlash(errorMessages.join(' '));
        } else {
          this.isFormVisible = false;
        }
      });
    },
    removeRelatedIssue(idToRemove) {
      const issue = this.state.relatedIssues.find(x => x.id === idToRemove);

      axios
        .delete(joinPaths(this.endpoint, issue.vulnerabilityLinkId.toString()))
        .then(() => {
          this.store.removeRelatedIssue(issue);
        })
        .catch(() => {
          createFlash(
            s__(
              'VulnerabilityManagement|Something went wrong while trying to unlink the issue. Please try again later.',
            ),
          );
        });
    },
    fetchRelatedIssues() {
      this.isFetching = true;

      axios
        .get(this.endpoint)
        .then(({ data }) => {
          const issues = data.map(x => getFormattedIssue(x));
          this.store.setRelatedIssues(issues);
        })
        .catch(() => {
          createFlash(__('An error occurred while fetching issues.'));
        })
        .finally(() => {
          this.isFetching = false;
        });
    },
    addPendingReferences({ untouchedRawReferences, touchedReference = '' }) {
      this.store.addPendingReferences(untouchedRawReferences);
      this.inputValue = `${touchedReference}`;
    },
    removePendingReference(indexToRemove) {
      this.store.removePendingRelatedIssue(indexToRemove);
    },
    processAllReferences(value = '') {
      const rawReferences = value.split(/\s+/).filter(reference => reference.trim().length > 0);
      this.addPendingReferences({ untouchedRawReferences: rawReferences });
    },
  },
  autoCompleteSources: gl?.GfmAutoComplete?.dataSources,
  issuableType: issuableTypesMap.ISSUE,
  pathIdSeparator: PathIdSeparator.Issue,
};
</script>

<template>
  <related-issues-block
    :help-path="helpPath"
    :is-fetching="isFetching"
    :is-submitting="isSubmitting"
    :related-issues="state.relatedIssues"
    :can-admin="canAdmin"
    :pending-references="state.pendingReferences"
    :is-form-visible="isFormVisible"
    :input-value="inputValue"
    :auto-complete-sources="$options.autoCompleteSources"
    :issuable-type="$options.issuableType"
    :path-id-separator="$options.pathIdSeparator"
    :show-categorized-issues="false"
    @toggleAddRelatedIssuesForm="toggleFormVisibility"
    @addIssuableFormInput="addPendingReferences"
    @addIssuableFormBlur="processAllReferences"
    @addIssuableFormSubmit="addRelatedIssue"
    @addIssuableFormCancel="resetForm"
    @pendingIssuableRemoveRequest="removePendingReference"
    @relatedIssueRemoveRequest="removeRelatedIssue"
  >
    <template #headerText>{{ __('Related issues') }}</template>
  </related-issues-block>
</template>
