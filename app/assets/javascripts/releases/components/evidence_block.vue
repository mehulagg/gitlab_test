<script>
import { GlLink, GlTooltipDirective } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import { truncateSha } from '~/lib/utils/text_utility';
import Icon from '~/vue_shared/components/icon.vue';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import ExpandButton from '~/vue_shared/components/expand_button.vue';

export default {
  name: 'EvidenceBlock',
  components: {
    ClipboardButton,
    ExpandButton,
    GlLink,
    Icon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    release: {
      type: Object,
      required: true,
    },
  },
  methods: {
    evidenceTitle(index) {
      return sprintf(__(`%{tag}-evidence-${index}.json`), { tag: this.release.tagName });
    },
    evidenceUrl(index) {
      return this.release.assets.evidence[index].file_path;
    },
    sha(index) {
      return this.release.assets.evidence[index].evidence_sha;
    },
    shortSha(index) {
      return truncateSha(this.release.assets.evidence[index].evidence_sha);
    },
  },
};
</script>

<template>
  <div>
    <div class="card-text prepend-top-default">
      <b>
        {{ __('Evidence collection') }}
      </b>
    </div>
    <div
      v-for="(evidence, index) in this.release.assets.evidence"
      v-bind:key="index"
      class="d-flex align-items-baseline"
    >
      <gl-link
        v-gl-tooltip
        class="monospace"
        :title="__('Download evidence JSON')"
        :download="evidenceTitle(index)"
        :href="evidenceUrl(index)"
      >
        <icon name="review-list" class="align-top append-right-4" /><span>
          {{ evidenceTitle(index) }}
        </span>
      </gl-link>

      <expand-button>
        <template slot="short">
          <span class="js-short monospace">{{ shortSha }}</span>
        </template>
        <template slot="expanded">
          <span class="js-expanded monospace gl-pl-1">{{ sha }}</span>
        </template>
      </expand-button>
      <clipboard-button
        :title="__('Copy commit SHA')"
        :text="sha"
        css-class="btn-default btn-transparent btn-clipboard"
      />
    </div>
  </div>
</template>
