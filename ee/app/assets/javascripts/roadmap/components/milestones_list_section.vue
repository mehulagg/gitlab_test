<script>
import { mapState, mapActions } from 'vuex';

import eventHub from '../event_hub';

import { EPIC_DETAILS_CELL_WIDTH, EPIC_ITEM_HEIGHT, TIMELINE_CELL_MIN_WIDTH } from '../constants';

import MilestoneTimeline from './milestone_timeline.vue';

export default {
  MilestoneTimeline,
  components: {
    MilestoneTimeline,
  },
  props: {
    presetType: {
      type: String,
      required: true,
    },
    milestones: {
      type: Array,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
    currentGroupId: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      offsetLeft: 0,
      showBottomShadow: false,
      roadmapShellEl: null,
    };
  },
  computed: {
    ...mapState(['bufferSize']),
    emptyRowContainerVisible() {
      return this.milestones.length < this.bufferSize;
    },
    sectionContainerStyles() {
      return {
        width: `${EPIC_DETAILS_CELL_WIDTH + TIMELINE_CELL_MIN_WIDTH * this.timeframe.length}px`,
      };
    },
    shadowCellStyles() {
      return {
        left: `${this.offsetLeft}px`,
      };
    },
  },
  mounted() {
    eventHub.$on('epicsListScrolled', this.handleEpicsListScroll);
    this.initMounted();
  },
  beforeDestroy() {
    eventHub.$off('epicsListScrolled', this.handleEpicsListScroll);
  },
  methods: {
    ...mapActions(['setBufferSize']),
    initMounted() {
      this.roadmapShellEl = this.$root.$el && this.$root.$el.firstChild;
      this.setBufferSize(Math.ceil((window.innerHeight - this.$el.offsetTop) / EPIC_ITEM_HEIGHT));

      // Wait for component render to complete
      this.$nextTick(() => {
        this.offsetLeft = (this.$el.parentElement && this.$el.parentElement.offsetLeft) || 0;

        // We cannot scroll to the indicator immediately
        // on render as it will trigger scroll event leading
        // to timeline expand, so we wait for another render
        // cycle to complete.
        this.$nextTick(() => {
          this.scrollToTodayIndicator();
        });
      });
    },
    /**
     * Scroll timeframe to the right of the timeline
     * by half the column size
     */
    scrollToTodayIndicator() {
      if (this.$el.parentElement) this.$el.parentElement.scrollBy(TIMELINE_CELL_MIN_WIDTH / 2, 0);
    },
    handleEpicsListScroll({ scrollTop, clientHeight, scrollHeight }) {
      this.showBottomShadow = Math.ceil(scrollTop) + clientHeight < scrollHeight;
    },
    getMilestoneItemProps(index) {
      return {
        key: index,
        props: {
          milestone: this.milestones[index],
          presetType: this.presetType,
          timeframe: this.timeframe,
          currentGroupId: this.currentGroupId,
        },
      };
    },
  },
};
</script>

<template>
  <div :style="sectionContainerStyles" class="milestones-list-section">
    <template>
      <div class="milestones-list-title">{{ __('Milestones') }}</div>
      <div class="milestones-list-items">
        <milestone-timeline
          :preset-type="presetType"
          :timeframe="timeframe"
          :milestones="milestones"
          :current-group-id="currentGroupId"
        />
      </div>
    </template>
    <div v-show="showBottomShadow" :style="shadowCellStyles" class="scroll-bottom-shadow"></div>
  </div>
</template>
