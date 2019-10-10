<script>
import { GlEmptyState, GlLoadingIcon } from '@gitlab/ui';
import dateFormat from 'dateformat';
import { mapActions, mapState } from 'vuex';
import { sprintf, s__ } from '~/locale';
import { getDateInPast } from '~/lib/utils/datetime_utility';
import TreemapChart from 'ee/vue_shared/components/charts/treemap/treemap_chart.vue';
import GroupsDropdownFilter from '../../shared/components/groups_dropdown_filter.vue';
import ProjectsDropdownFilter from '../../shared/components/projects_dropdown_filter.vue';
import FileQuantityDropdown from './file_quantity_dropdown.vue';
import TreemapChart from 'ee/vue_shared/components/charts/treemap/treemap_chart.vue';
import { featureAccessLevel } from '~/pages/projects/shared/permissions/constants';
import { PROJECTS_PER_PAGE, DEFAULT_FILE_QUANTITY, DEFAULT_DAYS_IN_PAST } from '../constants';
import { dateFormats } from '../../shared/constants';
import createStore from '../store';

export default {
  name: 'CodeAnalytics',
  store: createStore(),
  components: {
    GlEmptyState,
    GroupsDropdownFilter,
    ProjectsDropdownFilter,
    FileQuantityDropdown,
    TreemapChart,
    GlLoadingIcon,
  },
  props: {
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
    endpoint: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      multiProjectSelect: false,
    };
  },
  computed: {
    ...mapState([
      'isLoading',
      'selectedGroup',
      'selectedProject',
      'selectedFileQuantity',
      'codeHotspotsData',
    ]),
    shouldRenderEmptyState() {
      return !this.selectedGroup || !this.selectedProject;
    },
    displayFileQuantityFilter() {
      return this.selectedGroup && this.selectedProject;
    },
    chartTitleDescription() {
      const now = new Date(Date.now());
      const startDate = new Date(getDateInPast(now, DEFAULT_DAYS_IN_PAST));

      return sprintf(
        s__('CodeAnalytics|Showing data about commits from %{startDate} to %{endDate}'),
        {
          startDate: dateFormat(startDate, dateFormats.defaultDate),
          endDate: dateFormat(now, dateFormats.defaultDate),
        },
      );
    },
  },
  created() {
    this.setEndpoint(this.endpoint);
  },
  mounted() {
    this.setSelectedFileQuantity(DEFAULT_FILE_QUANTITY);
  },
  methods: {
    ...mapActions([
      'setSelectedGroup',
      'setSelectedProject',
      'setSelectedFileQuantity',
      'setEndpoint',
      'fetchCodeHotspotsData',
    ]),
    onGroupSelect(group) {
      this.setSelectedGroup(group);
    },
    onProjectSelect(projects) {
      const project = projects.length ? projects[0] : null;
      this.setSelectedProject(project);

      if (project) this.fetchCodeHotspotsData();
    },
    onFileQuantitySelect(fileQuantity) {
      this.setSelectedFileQuantity(fileQuantity);
      this.fetchCodeHotspotsData();
    },
  },
  groupsQueryParams: {
    min_access_level: featureAccessLevel.EVERYONE,
  },
  projectsQueryParams: {
    per_page: PROJECTS_PER_PAGE,
    with_shared: false,
    order_by: 'last_activity_at',
  },
};
</script>

<template>
  <div>
    <div class="page-title-holder d-flex align-items-center">
      <h3 class="page-title">{{ __('Code Analytics') }}</h3>
    </div>
    <div class="mw-100">
      <div
        class="mt-3 py-2 px-3 d-flex bg-gray-light border-top border-bottom flex-column flex-md-row justify-content-start"
      >
        <groups-dropdown-filter
          class="dropdown-select"
          :query-params="$options.groupsQueryParams"
          @selected="onGroupSelect"
        />
        <projects-dropdown-filter
          v-if="selectedGroup"
          :key="selectedGroup.id"
          class="ml-md-1 mt-1 mt-md-0 dropdown-select"
          :group-id="selectedGroup.id"
          :query-params="$options.projectsQueryParams"
          :multi-select="multiProjectSelect"
          @selected="onProjectSelect"
        />
        <div
          v-if="displayFileQuantityFilter"
          class="ml-0 ml-md-auto mt-2 mt-md-0 d-flex flex-column flex-md-row align-items-md-center justify-content-md-end"
        >
          <label class="text-bold mb-0 mr-2">{{ s__('CodeAnalytics|Max files') }}</label>
          <file-quantity-dropdown
            :selected="selectedFileQuantity"
            @selected="onFileQuantitySelect"
          />
        </div>
      </div>
    </div>
    <gl-loading-icon v-if="isLoading" size="md" class="my-4 py-4" />
    <template v-else>
      <gl-empty-state
        v-if="shouldRenderEmptyState"
        :title="__('Identify the most frequently changed files in your repository')"
        :description="
          __(
            'Identify areas of the codebase associated with a lot of churn, which can indicate potential code hotspots.',
          )
        "
        :svg-path="emptyStateSvgPath"
      />
      <div
        v-else-if="!codeHotspotsData.length"
        class="bs-callout bs-callout-info"
      >{{ __('There is no data available. Please change your selection.') }}</div>
      <template v-else>
        <div class="mt-5">
          <h4>{{ s__('CodeAnalytics|Code hotspots') }}</h4>
          <div>{{ chartTitleDescription }}</div>
        </div>
        <div class="position-relative mt-4">
          <treemap-chart
            :data="codeHotspotsData"
            :legend-title="s__('CodeAnalytics|Number of commits (Darker means more)')"
            :tooltip-content-title="s__('CodeAnalytics|Commits')"
          />
        </div>
      </template>
    </template>
  </div>
</template>
