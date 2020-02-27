<script>
import { GlPopover, GlSprintf } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import Cookies from 'js-cookie';
import { parseBoolean, scrollToElement } from '~/lib/utils/common_utils';
import { s__ } from '~/locale';
import { glEmojiTag } from '~/emoji';
import Tracking from '~/tracking';

const trackingMixin = Tracking.mixin();

export default {
  dismissTrackValue: 10,
  clickTrackValue: 'click_button',
  components: {
    GlPopover,
    GlSprintf,
    Icon,
  },
  mixins: [trackingMixin],
  props: {
    target: {
      type: String,
      required: true,
    },
    cssClass: {
      type: String,
      required: true,
    },
    trackLabel: {
      type: String,
      required: true,
    },
    dismissKey: {
      type: String,
      required: true,
    },
    humanAccess: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      popoverDismissed: parseBoolean(Cookies.get(this.dismissKey)),
      tracking: {
        label: this.trackLabel,
        property: this.humanAccess,
      },
    };
  },
  computed: {
    suggestTitle() {
      if (this.trackLabel === 'suggest_gitlab_ci_yml')
        return s__(`suggestPipeline|1/2: Choose a template`);
      if (this.trackLabel === 'suggest_commit_first_project_gitlab_ci_yml')
        return s__(`suggestPipeline|2/2: Commit your changes`);
      return '';
    },
    suggestContent() {
      switch (this.trackLabel) {
        case 'suggest_gitlab_ci_yml':
          return s__(
            `suggestPipeline|We recommend the %{boldStart}Code Quality%{boldEnd} template, which will add a report widget to your Merge Requests. This way you’ll learn about code quality degradations much sooner. %{footerStart} Goodbye technical debt! %{footerEnd}`,
          );
        case 'suggest_commit_first_project_gitlab_ci_yml':
          return s__(
            `suggestPipeline|Commit the changes and your pipeline will automatically run for the first time.`,
          );
        default:
          return '';
      }
    },
    emoji() {
      if (this.trackLabel === 'suggest_gitlab_ci_yml') return glEmojiTag('wave');
      return '';
    },
  },
  mounted() {
    if (
      this.trackLabel === 'suggest_commit_first_project_gitlab_ci_yml' &&
      !this.popoverDismissed
    ) {
      scrollToElement(document.querySelector(this.target));
      this.track();
    }
  },
  methods: {
    onDismiss() {
      this.popoverDismissed = true;
      Cookies.set(this.dismissKey, this.popoverDismissed, { expires: 365 });
    },
    trackOnShow() {
      if (!this.popoverDismissed) this.track();
    },
  },
};
</script>

<template>
  <gl-popover
    v-if="!popoverDismissed"
    show
    :target="target"
    placement="rightbottom"
    trigger="manual"
    container="viewport"
    :css-classes="[cssClass]"
  >
    <template #title>
      <button
        class="btn-blank float-right mt-1"
        type="button"
        :aria-label="__('Close')"
        @click="onDismiss"
        :data-track-property="humanAccess"
        :data-track-value="$options.dismissTrackValue"
        :data-track-event="$options.clickTrackValue"
        :data-track-label="trackLabel"
      >
        <icon name="close" aria-hidden="true" />
      </button>
      {{ suggestTitle }}
    </template>

    <gl-sprintf :message="suggestContent">
      <template #bold="{content}">
        <strong> {{ content }} </strong>
      </template>
      <template #footer="{content}" class="mt-4">
        <div class="footer-text">
          {{ content }}
          <span v-html="emoji"></span>
        </div>
      </template>
    </gl-sprintf>
  </gl-popover>
</template>
