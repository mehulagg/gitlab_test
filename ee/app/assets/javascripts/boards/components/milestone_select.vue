<script>
import MilestoneSelect from '~/milestone_select';
import { GlLoadingIcon } from '@gitlab/ui';

const ANY_MILESTONE_LABEL = 'Any Milestone';
const NO_MILESTONE_LABEL = 'No Milestone';

const ANY_MILESTONE_STR_VALUE = 'Any';
const NO_MILESTONE_STR_VALUE = 'None';

const NO_MILESTONE_INT_VALUE = -1;
const ANY_MILESTONE_INT_VALUE = null;

export default {
  components: {
    GlLoadingIcon,
  },
  props: {
    board: {
      type: Object,
      required: true,
    },
    milestonePath: {
      type: String,
      required: true,
    },
    canEdit: {
      type: Boolean,
      required: false,
      default: false,
    },
  },

  computed: {
    milestoneTitle() {
      if (this.noMilestone) return NO_MILESTONE_LABEL;
      return this.board.milestone ? this.board.milestone.title : ANY_MILESTONE_LABEL;
    },
    anyMilestone() {
      return this.milestoneId === ANY_MILESTONE_INT_VALUE;
    },
    noMilestone() {
      return this.milestoneId === NO_MILESTONE_INT_VALUE;
    },
    milestoneId() {
      return this.board.milestone_id;
    },
    milestoneTitleClass() {
      return this.milestoneTitle === ANY_MILESTONE_LABEL ? 'text-secondary' : 'bold';
    },
    selected() {
      if (this.noMilestone) return NO_MILESTONE_STR_VALUE;
      if (this.anyMilestone) return ANY_MILESTONE_STR_VALUE;
      return this.board.milestone ? this.board.milestone.name : '';
    },
  },
  mounted() {
    this.milestoneDropdown = new MilestoneSelect(null, this.$refs.dropdownButton, {
      handleClick: this.selectMilestone,
    });
  },
  methods: {
    selectMilestone(milestone) {
      let { id } = milestone;
      if (milestone.title === ANY_MILESTONE_LABEL) {
        id = ANY_MILESTONE_INT_VALUE;
      } else if (milestone.title === NO_MILESTONE_LABEL) {
        id = NO_MILESTONE_INT_VALUE;
      }
      this.board.milestone_id = id;
      this.board.milestone = {
        ...milestone,
        id,
      };
    },
  },
};
</script>

<template>
  <div class="block milestone">
    <div class="title append-bottom-10">
      Milestone
      <button v-if="canEdit" type="button" class="edit-link btn btn-blank float-right">Edit</button>
    </div>
    <div :class="milestoneTitleClass" class="value">{{ milestoneTitle }}</div>
    <div class="selectbox" style="display: none;">
      <input :value="milestoneId" name="milestone_id" type="hidden" />
      <div class="dropdown">
        <button
          ref="dropdownButton"
          :data-selected="selected"
          :data-milestones="milestonePath"
          :data-show-no="true"
          :data-show-any="true"
          :data-show-started="true"
          :data-show-upcoming="true"
          :data-use-id="true"
          class="dropdown-menu-toggle wide"
          data-toggle="dropdown"
          type="button"
        >
          Milestone <i aria-hidden="true" data-hidden="true" class="fa fa-chevron-down"> </i>
        </button>
        <div class="dropdown-menu dropdown-select dropdown-menu-selectable">
          <div class="dropdown-input">
            <input
              type="search"
              class="dropdown-input-field"
              placeholder="Search milestones"
              autocomplete="off"
            />
            <i aria-hidden="true" data-hidden="true" class="fa fa-search dropdown-input-search">
            </i>
            <i
              role="button"
              aria-hidden="true"
              data-hidden="true"
              class="fa fa-times dropdown-input-clear js-dropdown-input-clear"
            >
            </i>
          </div>
          <div class="dropdown-content"></div>
          <div class="dropdown-loading"><gl-loading-icon /></div>
        </div>
      </div>
    </div>
  </div>
</template>
