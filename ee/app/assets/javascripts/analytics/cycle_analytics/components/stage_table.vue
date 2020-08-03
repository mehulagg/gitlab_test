<script>
import { mapState } from 'vuex';
import { GlTooltipDirective, GlLoadingIcon, GlEmptyState, GlSkeletonLoading } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import StageEventList from './stage_event_list.vue';
import StageTableHeader from './stage_table_header.vue';

export default {
  name: 'StageTable',
  components: {
    GlLoadingIcon,
    GlEmptyState,
    GlSkeletonLoading,
    StageEventList,
    StageTableHeader,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    currentStage: {
      type: Object,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: true,
    },
    isEmptyStage: {
      type: Boolean,
      required: true,
    },
    customStageFormActive: {
      type: Boolean,
      required: true,
    },
    currentStageEvents: {
      type: Array,
      required: true,
    },
    noDataSvgPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      stageNavHeight: 0,
    };
  },
  computed: {
    ...mapState(['customStageFormInitialData']),
    stageEventsHeight() {
      return `${this.stageNavHeight}px`;
    },
    stageName() {
      return this.currentStage ? this.currentStage.title : __('Related Issues');
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
  mounted() {
    // this.$set(this, 'stageNavHeight', this.$refs.stageNav.clientHeight);
  },
  minSkeletonHeight: '620px',
  minSkeletonLines: 3,
};
</script>
<template>
  <div class="stage-panel-container">
    <gl-skeleton-loading
      v-if="isLoading"
      class="gl-mx-6 gl-my-6"
      :lines="$options.minSkeletonLines"
    />
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
        <div class="section stage-events overflow-auto" :style="{ height: stageEventsHeight }">
          <slot name="content">
            <gl-loading-icon v-if="isLoading" class="gl-mt-4" size="md" />
            <template v-else>
              <stage-event-list
                v-if="shouldDisplayStage"
                :stage="currentStage"
                :events="currentStageEvents"
              />
              <gl-empty-state
                v-if="isEmptyStage"
                :title="__('We don\'t have enough data to show this stage.')"
                :description="currentStage.emptyStageText"
                :svg-path="noDataSvgPath"
              />
            </template>
          </slot>
        </div>
      </div>
    </div>
  </div>
</template>
