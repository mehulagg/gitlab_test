<script>
import { s__, sprintf } from '~/locale';
import _ from 'underscore';

export default {
  name: 'IssueMergeRequestLinks',
  props: {
    milestones: {
      type: Array,
      required: true,
    },
  },
  computed: {
    issuesHref() {
      return 'http://example.com';
    },
    mergeRequestsHref() {
      return 'http://example.com';
    },
    linkText() {
      const linkAttrs = 'target="_blank" rel="noopener noreferrer"';

      return sprintf(
        s__(
          'Releases|View %{issuesLinkStart}Issues%{linkEnd} or %{mrsLinkStart}Merge Requests%{linkEnd} in this release',
        ),
        {
          issuesLinkStart: `<a href="${_.escape(this.issuesHref)}" ${linkAttrs}>`,
          mrsLinkStart: `<a href="${_.escape(this.mergeRequestsHref)}" ${linkAttrs}>`,
          linkEnd: '</a>',
        },
        false,
      );
    },
  },
};
</script>
<template>
  <div v-html="linkText"></div>
</template>
