import statusIcon from '../mr_widget_status_icon';

export default {
  name: 'MRWidgetLocked',
  props: {
    mr: { type: Object, required: true },
  },
  components: {
    statusIcon,
  },
  template: `
    <div class="mr-widget-body mr-state-locked media">
      <div class="mr-widget-icon">
        <i
          class="fa fa-spinner fa-spin"
          aria-hidden="true" />
      </div>
      <div class="media-body">
        <h4>
          This merge request is in the process of being merged, during which time it is locked and cannot be closed
        </h4>
        <section class="mr-info-list">
          <p>
            The changes will be merged into
            <span class="label-branch">
              <a :href="mr.targetBranchPath">{{mr.targetBranch}}</a>
            </span>
          </p>
        </section>
      </div>
    </div>
  `,
};
