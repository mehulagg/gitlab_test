<script>
import { GlEmptyState } from '@gitlab/ui';
import { mapActions, mapState, mapGetters } from 'vuex';
import GroupsDropdownFilter from '../../shared/components/groups_dropdown_filter.vue';
import ProjectsDropdownFilter from '../../shared/components/projects_dropdown_filter.vue';
import DateRangeDropdown from '../../shared/components/date_range_dropdown.vue';
import SummaryTable from './summary_table.vue';
import StageTable from './stage_table.vue';

export default {
  name: 'CycleAnalytics',
  components: {
    GlEmptyState,
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
  },
  data() {
    return {
      multiProjectSelect: true,
      dateOptions: [7, 30, 90],
      groupsQueryParams: {
        min_access_level: 20,
      },
    };
  },
  computed: {
    ...mapState([
      'isLoading',
      'isLoadingStage',
      'isEmptyStage',
      'selectedGroup',
      'selectedProjectIds',
      'selectedStageName',
      'events',
      'stages',
      'summary',
      'dataTimeframe',
    ]),
    ...mapGetters(['getCurrentStage', 'getDefaultStage']),
    shouldRenderEmptyState() {
      return !this.selectedGroup;
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
      this.setSelectedStageName(stage.name);
      this.setStageDataEndpoint(this.getCurrentStage.slug);
      this.fetchStageData(this.getCurrentStage.name);
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
          @selected="onGroupSelect"
          :query-params="groupsQueryParams"
        />
        <projects-dropdown-filter
          class="js-projects-dropdown-filter ml-md-1 mt-1 mt-md-0 dropdown-select"
          v-if="selectedGroup"
          :group-id="selectedGroup.id"
          :key="selectedGroup.id"
          @selected="onProjectsSelect"
          :multi-select="multiProjectSelect"
        />
        <div
          class="ml-0 ml-md-auto mt-2 mt-md-0 d-flex flex-column flex-md-row align-items-md-center justify-content-md-end"
          v-if="selectedGroup"
        >
          <label class="text-bold mb-0 mr-1">{{ __('Timeframe') }}</label>
          <date-range-dropdown
            class="js-timeframe-dropdown"
            @selected="onTimeframeSelect"
            :available-days-in-past="dateOptions"
            :default-selected="dataTimeframe"
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
    <div class="cycle-analytics mt-0" v-else>
      <summary-table class="js-summary-table" :items="summary" />
      <stage-table
        class="js-stage-table"
        v-if="getCurrentStage"
        :currentStage="getCurrentStage"
        :stages="stages"
        :isLoadingStage="isLoadingStage"
        :isEmptyStage="isEmptyStage"
        :events="events"
        @selectStage="onStageSelect"
      />
    </div>
  </div>
</template>
