<script>
import { GlTooltipDirective, GlLoadingIcon } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import iconNoData from 'icons/_icon_no_data.svg';
import iconLock from 'icons/_icon_lock.svg';
import stageCodeComponent from './stage_code_component.vue';
import stageComponent from './stage_component.vue';
import stageReviewComponent from './stage_review_component.vue';
import stageStagingComponent from './stage_staging_component.vue';
import stageTestComponent from './stage_test_component.vue';

export default {
  name: 'StageTable',
  components: {
    Icon,
    GlLoadingIcon,
    'stage-issue-component': stageComponent,
    'stage-plan-component': stageComponent,
    'stage-code-component': stageCodeComponent,
    'stage-test-component': stageTestComponent,
    'stage-review-component': stageReviewComponent,
    'stage-staging-component': stageStagingComponent,
    'stage-production-component': stageComponent,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    stages: {
      type: Array,
      required: true,
    },
    currentStage: {
      type: Object,
      required: true,
    },
    isLoadingStage: {
      type: Boolean,
      required: true,
    },
    isEmptyStage: {
      type: Boolean,
      required: true,
    },
    events: {
      type: Array,
      required: true,
    },
  },
  computed: {
    iconNoData() {
      return iconNoData;
    },
    iconLock() {
      return iconLock;
    },
  },
  methods: {
    selectStage(stage) {
      this.$emit('selectStage', stage);
    },
  },
};
</script>
<template>
  <div class="stage-panel-container">
    <div class="card stage-panel">
      <div class="card-header">
        <nav class="col-headers">
          <ul>
            <li class="stage-header">
              <span class="stage-name align-middle">{{ s__('ProjectLifecycle|Stage') }}</span>
              <icon
                class="align-middle"
                :size="14"
                name="question"
                v-gl-tooltip
                container=".stage-name"
                :title="__('The phase of the development lifecycle.')"
              />
            </li>
            <li class="median-header">
              <span class="stage-name align-middle">{{ __('Median') }}</span>
              <icon
                class="align-middle"
                :size="14"
                name="question"
                v-gl-tooltip
                :title="
                  __(
                    'The value lying at the midpoint of a series of observed values. E.g., between 3, 5, 9, the median is 5. Between 3, 5, 7, 8, the median is (5+7)/2 = 6.',
                  )
                "
              />
            </li>
            <li class="event-header">
              <span class="stage-name align-middle">{{
                currentStage ? currentStage.legend : __('Related Issues')
              }}</span>
              <icon
                class="align-middle"
                :size="14"
                name="question"
                v-gl-tooltip
                :title="__('The collection of events added to the data gathered for that stage.')"
              />
            </li>
            <li class="total-time-header">
              <span class="stage-name align-middle">{{ __('Total Time') }}</span>
              <icon
                class="align-middle"
                :size="14"
                name="question"
                v-gl-tooltip
                :title="__('The time taken by each data entry gathered by that stage.')"
              />
            </li>
          </ul>
        </nav>
      </div>
      <div class="stage-panel-body">
        <nav class="stage-nav">
          <ul>
            <li
              class="stage-nav-item"
              v-for="stage in stages"
              :key="stage.name"
              :class="{ active: stage.name === currentStage.name }"
              @click="selectStage(stage)"
            >
              <div class="stage-nav-item-cell stage-name">{{ stage.title }}</div>
              <div class="stage-nav-item-cell stage-median">
                <template v-if="stage.isUserAllowed">
                  <span v-if="stage.value">{{ stage.value }}</span>
                  <span class="stage-empty" v-else>{{ __('Not enough data') }}</span>
                </template>
                <template v-else>
                  <span class="not-available">{{ __('Not available') }}</span>
                </template>
              </div>
            </li>
          </ul>
        </nav>
        <div class="section stage-events">
          <gl-loading-icon class="mt-4" size="md" v-if="isLoadingStage" />
          <template v-if="currentStage && !currentStage.isUserAllowed">
            <div class="no-access-stage-container">
              <div class="no-access-stage">
                <div class="icon-lock">
                  <span v-html="iconLock"></span>
                </div>
                <h4>{{ __('You need permission.') }}</h4>
                <p>{{ __('Want to see the data? Please ask an administrator for access.') }}</p>
              </div>
            </div>
          </template>
          <template v-else>
            <template v-if="isEmptyStage && !isLoadingStage">
              <div class="empty-stage-container">
                <div class="empty-stage">
                  <div class="icon-no-data">
                    <span v-html="iconNoData"></span>
                  </div>
                  <h4>{{ __("We don't have enough data to show this stage.") }}</h4>
                  <p>{{ currentStage.emptyStageText }}</p>
                </div>
              </div>
            </template>
            <template v-if="events.length && !isLoadingStage && !isEmptyStage">
              <component :is="currentStage.component" :stage="currentStage" :items="events" />
            </template>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>
