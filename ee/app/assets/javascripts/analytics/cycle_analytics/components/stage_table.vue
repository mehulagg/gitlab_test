<script>
import { mapState } from 'vuex';
import { GlTooltipDirective, GlLoadingIcon, GlEmptyState, GlSkeletonLoader } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import StageEventList from './stage_event_list.vue';
import StageTableHeader from './stage_table_header.vue';

const MIN_TABLE_HEIGHT = 568;
const SKELETON = {
  HEIGHT: 320,
  NAV_HEIGHT: 65,
  NAV_WIDTH: 385,
  NAV_Y_PADDING: 15,
  NAV_X_PADDING: 5,
  STAGE_X_POS: 415,
};

export default {
  name: 'StageTable',
  components: {
    GlLoadingIcon,
    GlEmptyState,
    GlSkeletonLoader,
    StageEventList,
    StageTableHeader,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    customStageFormActive: {
      type: Boolean,
      required: true,
    },
    noDataSvgPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      stageNavHeight: MIN_TABLE_HEIGHT,
      stageWidth: 0,
    };
  },
  computed: {
    ...mapState([
      'selectedStage',
      'currentStageEvents',
      'isLoading',
      'isLoadingValueStreamData',
      'isLoadingStage',
      'isEmptyStage',
    ]),
    isLoadingStageTable() {
      return Boolean(this.isLoading || this.isLoadingValueStreamData);
    },
    stageEventsHeight() {
      return `${this.stageNavHeight}px`;
    },
    stageName() {
      return this.selectedStage?.title || __('Related Issues');
    },
    shouldDisplayStage() {
      const { currentStageEvents = [], isLoading, isEmptyStage } = this;
      return currentStageEvents.length && !isLoading && !isEmptyStage;
    },
    stageHeaders() {
      return [
        {
          title: s__('ProjectLifecycle|Stage'),
          description: __('The phase of the development lifecycle.'),
          classes: 'stage-header pl-5',
        },
        {
          title: __('Median'),
          description: __(
            'The value lying at the midpoint of a series of observed values. E.g., between 3, 5, 9, the median is 5. Between 3, 5, 7, 8, the median is (5+7)/2 = 6.',
          ),
          classes: 'median-header',
        },
        {
          title: this.stageName,
          description: __('The collection of events added to the data gathered for that stage.'),
          classes: 'event-header pl-3',
          displayHeader: !this.customStageFormActive,
        },
        {
          title: __('Time'),
          description: __('The time taken by each data entry gathered by that stage.'),
          classes: 'total-time-header pr-5 text-right',
          displayHeader: !this.customStageFormActive,
        },
      ];
    },
  },
  updated() {
    this.$set(this, 'stageWidth', this.$refs.stagePanel.clientWidth);
    if (!this.isLoadingStageTable && this.$refs.stageNav) {
      this.$set(this, 'stageNavHeight', this.$refs.stageNav.clientHeight);
    }
  },
  skeletonConfig: SKELETON,
};
</script>
<template>
  <div ref="stagePanel" class="stage-panel-container">
    <div
      v-if="isLoadingStageTable"
      class="stage-panel-body gl-display-flex gl-flex-direction-column"
      :style="{ 'min-height': 320, width: '100%' }"
    >
      <gl-skeleton-loader
        :width="stageWidth"
        :height="$options.skeletonConfig.HEIGHT"
        preserve-aspect-ratio="xMinYMax meet"
      >
        <!-- LHS nav -->
        <!-- TODO: cleanup -->
        <rect
          :width="$options.skeletonConfig.NAV_WIDTH"
          :height="$options.skeletonConfig.NAV_HEIGHT"
          :x="$options.skeletonConfig.NAV_X_PADDING"
          :y="0"
          rx="4"
        />
        <rect
          :width="$options.skeletonConfig.NAV_WIDTH"
          :height="$options.skeletonConfig.NAV_HEIGHT"
          :x="$options.skeletonConfig.NAV_X_PADDING"
          :y="80"
          rx="4"
        />
        <rect
          :width="$options.skeletonConfig.NAV_WIDTH"
          :height="$options.skeletonConfig.NAV_HEIGHT"
          :x="$options.skeletonConfig.NAV_X_PADDING"
          :y="160"
          rx="4"
        />
        <rect
          :width="$options.skeletonConfig.NAV_WIDTH"
          :height="$options.skeletonConfig.NAV_HEIGHT"
          :x="$options.skeletonConfig.NAV_X_PADDING"
          :y="240"
          rx="4"
        />
        <!-- RHS pane -->
        <rect
          :width="stageWidth - $options.skeletonConfig.STAGE_X_POS"
          :height="$options.skeletonConfig.HEIGHT - $options.skeletonConfig.NAV_Y_PADDING"
          :x="$options.skeletonConfig.STAGE_X_POS - $options.skeletonConfig.NAV_Y_PADDING"
          :y="0"
          rx="4"
        />
      </gl-skeleton-loader>
    </div>
    <div v-else class="card stage-panel">
      <div class="card-header gl-border-b-0">
        <nav class="col-headers">
          <ul>
            <stage-table-header
              v-for="({ title, description, classes, displayHeader = true }, i) in stageHeaders"
              v-show="displayHeader"
              :key="`stage-header-${i}`"
              :header-classes="classes"
              :title="title"
              :tooltip-title="description"
            />
          </ul>
        </nav>
      </div>
      <div class="stage-panel-body">
        <nav ref="stageNav" class="stage-nav gl-pl-2">
          <slot name="nav"></slot>
        </nav>
        <div
          class="section stage-events overflow-auto"
          :style="{ 'min-height': $options.minTableHeight, height: stageEventsHeight }"
        >
          <slot name="content">
            <gl-loading-icon v-if="isLoadingStage" class="gl-mt-4" size="md" />
            <template v-else>
              <stage-event-list
                v-if="shouldDisplayStage"
                :stage="selectedStage"
                :events="currentStageEvents"
              />
              <gl-empty-state
                v-if="isEmptyStage"
                :title="__('We don\'t have enough data to show this stage.')"
                :description="selectedStage.emptyStageText"
                :svg-path="noDataSvgPath"
              />
            </template>
          </slot>
        </div>
      </div>
    </div>
  </div>
</template>
