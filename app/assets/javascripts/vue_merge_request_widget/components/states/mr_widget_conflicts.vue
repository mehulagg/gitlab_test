<script>
import $ from 'jquery';
import _ from 'underscore';
import { s__, sprintf } from '~/locale';
import { mouseenter, debouncedMouseleave, togglePopover } from '~/shared/popover';
import StatusIcon from '../mr_widget_status_icon.vue';

export default {
  name: 'MRWidgetConflicts',
  components: {
    StatusIcon,
  },
  props: {
    /* TODO: This is providing all store and service down when it
      only needs a few props */
    mr: {
      type: Object,
      required: true,
      default: () => ({}),
    },
  },
  computed: {
    popoverTitle() {
      return s__(
        'mrWidget|This feature merges changes from the target branch to the source branch. You cannot use this feature since the source branch is protected.',
      );
    },
    showResolveButton() {
      return this.mr.conflictResolutionPath && this.mr.canPushToSourceBranch;
    },
    showMergeLocalButton() {
      return this.mr.canMerge && !this.mr.shouldBeRebased;
    },
    showPopover() {
      return this.showResolveButton && this.mr.sourceBranchProtected;
    },
    conflictsMessage() {
      if (this.mr.shouldBeRebased) {
        return this.showResolveButton
          ? s__(`mrWidget|There are merge conflicts which cannot be resolved automatically.`)
          : s__(
              `mrWidget|There are merge conflicts which cannot be resolved automatically. Please resolve the conflicts locally.`,
            );
      }

      return this.canMerge
        ? s__('mrWidget|There are merge conflicts.')
        : s__(`mrWidget|There are merge conflicts. Resolve these conflicts or ask someone
            with write access to this repository to merge it locally`);
    },
  },
  mounted() {
    if (this.showPopover) {
      const $el = $(this.$refs.popover);

      $el
        .popover({
          html: true,
          trigger: 'focus',
          container: 'body',
          placement: 'top',
          template:
            '<div class="popover" role="tooltip"><div class="arrow"></div><p class="popover-header"></p><div class="popover-body"></div></div>',
          title: s__(
            'mrWidget|This feature merges changes from the target branch to the source branch. You cannot use this feature since the source branch is protected.',
          ),
          content: sprintf(
            s__('mrWidget|%{link_start}Learn more about resolving conflicts%{link_end}'),
            {
              link_start: `<a href="${_.escape(
                this.mr.conflictsDocsPath,
              )}" target="_blank" rel="noopener noreferrer">`,
              link_end: '</a>',
            },
            false,
          ),
        })
        .on('mouseenter', mouseenter)
        .on('mouseleave', debouncedMouseleave(300))
        .on('show.bs.popover', () => {
          window.addEventListener('scroll', togglePopover.bind($el, false), { once: true });
        });
    }
  },
};
</script>
<template>
  <div class="mr-widget-body media">
    <status-icon :show-disabled-button="true" status="warning" />

    <div class="media media-body space-children">
      <span class="bold mr-auto" v-text="conflictsMessage"></span>
      <span v-if="showResolveButton" ref="popover">
        <a
          :href="mr.conflictResolutionPath"
          :disabled="showPopover"
          class="js-resolve-conflicts-button btn btn-default btn-sm"
        >
          {{ s__('mrWidget|Resolve conflicts') }}
        </a>
      </span>
      <button
        v-if="showMergeLocalButton"
        class="js-merge-locally-button btn btn-default btn-sm"
        data-toggle="modal"
        data-target="#modal_merge_info"
      >
        {{ s__('mrWidget|Merge locally') }}
      </button>
    </div>
  </div>
</template>
