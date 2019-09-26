<script>
import { GlEmptyState } from '@gitlab/ui';
import { GlStackedColumnChart } from '@gitlab/ui/dist/charts';
import { mapActions, mapState, mapGetters } from 'vuex';
import { featureAccessLevel } from '~/pages/projects/shared/permissions/constants';
import GroupsDropdownFilter from '../../shared/components/groups_dropdown_filter.vue';
import ProjectsDropdownFilter from '../../shared/components/projects_dropdown_filter.vue';
import DateRangeDropdown from '../../shared/components/date_range_dropdown.vue';
import SummaryTable from './summary_table.vue';
import StageTable from './stage_table.vue';

// TODO: replace this test data with an endpoint
import { __ } from '~/locale';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { getTimeframeWindowFrom, getDateInPast, dateInWords } from '~/lib/utils/datetime_utility';

// const timeWindow = getTimeframeWindowFrom(new Date(), -30);
const today = new Date('2019-09-26T00:00:00.00Z');
const dataRange = [...Array(7).keys()]
  .map(i => {
    const d = getDateInPast(today, i);
    return dateInWords(new Date(d), true, true);
  })
  .reverse();

function randomInt(range) {
  return Math.floor(Math.random() * Math.floor(range));
}

const typeOfWork = convertObjectPropsToCamelCase(
  {
    label_id: __('Bug'),
    series: [...dataRange.map(key => [key, randomInt(100)])],
  },
  {
    label_id: __('Feature'),
    series: [...dataRange.map(key => [key, randomInt(100)])],
  },
  {
    label_id: __('Backstage'),
    series: [...dataRange.map(key => [key, randomInt(100)])],
  },
  { deep: true },
);

export default {
  name: 'CycleAnalytics',
  components: {
    GlEmptyState,
    GlStackedColumnChart,
    GroupsDropdownFilter,
    ProjectsDropdownFilter,
    DateRangeDropdown,
    SummaryTable,
    StageTable,
  },
  props: {
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
    noDataSvgPath: {
      type: String,
      required: true,
    },
    noAccessSvgPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      multiProjectSelect: true,
      dateOptions: [7, 30, 90],
      groupsQueryParams: {
        min_access_level: featureAccessLevel.EVERYONE,
      },
      typeOfWork: {
        dataset: typeOfWork,
        range: dataRange,
      },
    };
  },
  computed: {
    ...mapState([
      'isLoading',
      'isLoadingStage',
      'isEmptyStage',
      'isAddingCustomStage',
      'selectedGroup',
      'selectedProjectIds',
      'selectedStageName',
      'events',
      'stages',
      'summary',
      'dataTimeframe',
    ]),
    ...mapGetters(['currentStage', 'defaultStage', 'hasNoAccessError', 'currentGroupPath']),
    shouldRenderEmptyState() {
      return !this.selectedGroup;
    },
    hasCustomizableCycleAnalytics() {
      return gon && gon.features ? gon.features.customizableCycleAnalytics : false;
    },
    typeOfWorkDataset() {
      return [
        [58, 49, 38, 23, 27, 68, 38, 35, 7, 64, 65, 31],
        [8, 6, 34, 19, 9, 7, 17, 25, 14, 7, 10, 32],
      ];
    },
  },
  methods: {
    ...mapActions([
      'setCycleAnalyticsDataEndpoint',
      'setStageDataEndpoint',
      'setSelectedGroup',
      'fetchCycleAnalyticsData',
      'setSelectedProjects',
      'setSelectedTimeframe',
      'fetchStageData',
      'setSelectedStageName',
      'showCustomStageForm',
      'hideCustomStageForm',
    ]),
    onGroupSelect(group) {
      this.setCycleAnalyticsDataEndpoint(group.path);
      this.setSelectedGroup(group);
      this.fetchCycleAnalyticsData();
    },
    onProjectsSelect(projects) {
      const projectIds = projects.map(value => value.id);
      this.setSelectedProjects(projectIds);
      this.fetchCycleAnalyticsData();
    },
    onTimeframeSelect(days) {
      this.setSelectedTimeframe(days);
      this.fetchCycleAnalyticsData();
    },
    onStageSelect(stage) {
      this.hideCustomStageForm();
      this.setSelectedStageName(stage.name);
      this.setStageDataEndpoint(this.currentStage.slug);
      this.fetchStageData(this.currentStage.name);
    },
    onShowAddStageForm() {
      this.showCustomStageForm();
    },
  },
};
</script>

<template>
  <div>
    <div class="page-title-holder d-flex align-items-center">
      <h3 class="page-title">{{ __('Cycle Analytics') }}</h3>
    </div>
    <div class="mw-100">
      <div
        class="mt-3 py-2 px-3 d-flex bg-gray-light border-top border-bottom flex-column flex-md-row justify-content-between"
      >
        <groups-dropdown-filter
          class="js-groups-dropdown-filter dropdown-select"
          :query-params="groupsQueryParams"
          @selected="onGroupSelect"
        />
        <projects-dropdown-filter
          v-if="selectedGroup"
          :key="selectedGroup.id"
          class="js-projects-dropdown-filter ml-md-1 mt-1 mt-md-0 dropdown-select"
          :group-id="selectedGroup.id"
          :multi-select="multiProjectSelect"
          @selected="onProjectsSelect"
        />
        <div
          v-if="selectedGroup"
          class="ml-0 ml-md-auto mt-2 mt-md-0 d-flex flex-column flex-md-row align-items-md-center justify-content-md-end"
        >
          <label class="text-bold mb-0 mr-1">{{ __('Timeframe') }}</label>
          <date-range-dropdown
            class="js-timeframe-filter"
            :available-days-in-past="dateOptions"
            :default-selected="dataTimeframe"
            @selected="onTimeframeSelect"
          />
        </div>
      </div>
    </div>
    <gl-empty-state
      v-if="shouldRenderEmptyState"
      :title="__('Cycle Analytics can help you determine your team’s velocity')"
      :description="
        __(
          'Start by choosing a group to see how your team is spending time. You can then drill down to the project level.',
        )
      "
      :svg-path="emptyStateSvgPath"
    />
    <div v-else class="cycle-analytics mt-0">
      <gl-empty-state
        v-if="hasNoAccessError"
        class="js-empty-state"
        :title="__('You don’t have access to Cycle Analytics for this group')"
        :svg-path="noAccessSvgPath"
        :description="
          __(
            'Only \'Reporter\' roles and above on tiers Premium / Silver and above can see Cycle Analytics.',
          )
        "
      />
      <summary-table class="js-summary-table" :items="summary" />
      <stage-table
        v-if="currentStage"
        class="js-stage-table"
        :current-stage="currentStage"
        :stages="stages"
        :is-loading-stage="isLoadingStage"
        :is-empty-stage="isEmptyStage"
        :is-adding-custom-stage="isAddingCustomStage"
        :events="events"
        :no-data-svg-path="noDataSvgPath"
        :no-access-svg-path="noAccessSvgPath"
        :can-edit-stages="hasCustomizableCycleAnalytics"
        @selectStage="onStageSelect"
        @showAddStageForm="onShowAddStageForm"
      />
    </div>
    <div>
      <h2>{{ __('Type of work') }}</h2>
      <p>{{ __('Showing data for __ groups and __ projects from __ to __') }}</p>
      <div class="col-6">
        <header>
          <h3>{{ __('Tasks by type') }}</h3>
        </header>
        <section>
          <gl-stacked-column-chart
            :data="typeOfWorkDataset"
            :group-by="typeOfWork.range"
            x-axis-type="category"
            x-axis-title="January - December 2018"
            y-axis-title="Commits"
            :series-names="['Fun 1', 'Fun 2']"
          />
        </section>
      </div>
    </div>
  </div>
</template>
