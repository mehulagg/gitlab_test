<script>
import { s__, __, sprintf } from '~/locale';
import _ from 'underscore';

const LINK_ATTRS = 'target="_blank" rel="noopener noreferrer"';

export default {
  name: 'IssueMergeRequestLinks',
  props: {
    milestones: {
      type: Array,
      required: true,
    },
    issuesUrl: {
      type: String,
      required: true,
    },
    mergeRequestsUrl: {
      type: String,
      required: true,
    },
  },
  computed: {
    linkText() {
      let issueLinks;
      let mrLinks;
      let footerText;
      if (this.milestones.length === 1) {
        const [milestone] = this.milestones;
        footerText = s__('Releases|View %{issueLinks} or %{mrLinks} in this release');

        const getMilestonesLinks = (baseUrl, title) => this.getLink(milestone, baseUrl, title);
        issueLinks = getMilestonesLinks(this.issuesUrl, __('Issues'));
        mrLinks = getMilestonesLinks(this.mergeRequestsUrl, __('Merge Requests'));
      } else {
        footerText = s__(
          'Releases|View Issues for milestones %{issueLinks}. View Merge Requests for milestones %{mrLinks}.',
        );

        const getMilestonesLinks = baseUrl =>
          this.milestones.map(m => this.getLink(m, baseUrl, m.title)).join(', ');
        issueLinks = getMilestonesLinks(this.issuesUrl);
        mrLinks = getMilestonesLinks(this.mergeRequestsUrl);
      }

      return sprintf(footerText, { issueLinks, mrLinks }, false);
    },
  },
  methods: {
    getQueryParam(milestone) {
      return `milestone_title=${encodeURIComponent(_.escape(milestone.title))}`;
    },
    getLink(milestone, href, linkText) {
      return `<a href="${_.escape(href)}&${this.getQueryParam(milestone)}" ${LINK_ATTRS}>${_.escape(
        linkText,
      )}</a>`;
    },
  },
};
</script>
<template>
  <div v-html="linkText"></div>
</template>
