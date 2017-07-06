import statusIcon from '../mr_widget_status_icon';

export default {
  name: 'MRWidgetConflicts',
  props: {
    mr: { type: Object, required: true },
  },
  components: {
    statusIcon,
  },
  template: `
    <div class="mr-widget-body media">
      <status-icon status="failed" />
      <div class="media-body">
        <span class="bold">
          There are merge conflicts<span v-if="!mr.canMerge">.</span>
          <span v-if="!mr.canMerge">
            Resolve these conflicts or ask someone with write access to this repository to merge it locally.
          </span>
        </span>
        <span v-if="mr.canMerge">
          <a
            v-if="mr.conflictResolutionPath"
            :href="mr.conflictResolutionPath"
            class="btn btn-default btn-xs js-resolve-conflicts-button">
            Resolve conflicts
          </a>
          <button
            type="button"
            class="btn btn-success btn-xs"
            disabled="true">
            Merge
          </button>
          <a
            v-if="mr.canMerge"
            class="btn btn-default btn-xs js-merge-locally-button"
            data-toggle="modal"
            href="#modal_merge_info">
            Merge locally
          </a>
        </span>
      </div>
    </div>
  `,
};
