<script>
import Icon from '~/vue_shared/components/icon.vue';
import { GlBadge, GlButton } from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';

import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';
import ProjectSelector from '~/vue_shared/components/project_selector/project_selector.vue';

export default {
  components: {
    GlBadge,
    GlButton,
    ProjectSelector,
    ProjectAvatar,
    Icon,
  },
  props: {},
  computed: {
    ...mapState('projectSelector', [
      'projects',
      'projectTokens',
      'isLoadingProjects',
      'selectedProjects',
      'projectSearchResults',
      'searchCount',
      'searchQuery',
      'messages',
    ]),
    isSearchingProjects() {
      return this.searchCount > 0;
    },
  },
  created() {
    // @TODO - check how we are going to set these endpoints
    this.setProjectEndpoints({
      list: '/-/operations/list',
      add: '/-/operations',
    });
    // @TODO - check if this should happen here or have them passed in via a prop
    this.fetchProjects();
  },
  methods: {
    ...mapActions('projectSelector', [
      'fetchSearchResults',
      'addProjectsToDashboard',
      'fetchProjects',
      'setProjectEndpoints',
      'clearSearchResults',
      'toggleSelectedProject',
      'setSearchQuery',
      'removeProject',
    ]),
    addProjects() {
      this.addProjectsToDashboard();
      this.clearSearchResults();
    },
    searched(query) {
      this.setSearchQuery(query);
      this.fetchSearchResults();
    },
    projectClicked(project) {
      this.toggleSelectedProject(project);
    },
    projectRemoved(project) {
      this.removeProject(project.remove_path);
    },
  },
};
</script>

<template>
  <section class="container">
    <div class="row justify-content-center mt-md-4">
      <div class="col col-lg-7">
        <h2 class="h5 border-bottom mb-4 pb-3">Add or remove projects from your dashboard</h2>
        <div class="d-flex flex-column flex-md-row">
          <project-selector
            class="flex-grow mr-md-2"
            :project-search-results="projectSearchResults"
            :selected-projects="selectedProjects"
            :show-no-results-message="messages.noResults"
            :show-loading-indicator="isSearchingProjects"
            :show-minimum-search-query-message="messages.minimumQuery"
            :show-search-error-message="messages.searchError"
            @searched="searched"
            @projectClicked="projectClicked"
          />
          <div>
            <gl-button
              variant="success"
              :disabled="selectedProjects.length < 1"
              @click="addProjects"
            >
              Add projects
            </gl-button>
          </div>
        </div>
      </div>
    </div>
    <div class="row justify-content-center mt-md-3">
      <div class="col col-lg-7">
        <h3 class="h5 text-secondary border-bottom mb-3 pb-2">
          Projects added <gl-badge>{{ projects.length }}</gl-badge>
        </h3>
        <ul v-if="projects.length > 0" class="list-unstyled">
          <li v-for="project in projects" :key="project.id" class="d-flex align-items-center py-1">
            <project-avatar class="flex-shrink-0" :project="project" :size="32" />
            <span>
              {{ project.name_with_namespace }}
            </span>
            <gl-button
              v-gl-tooltip
              class="ml-auto bg-transparent border-0 p-0 text-secondary"
              title="title will go here"
              @click="projectRemoved(project)"
            >
              <icon name="remove" />
            </gl-button>
          </li>
        </ul>
        <p v-else class="text-secondary">
          Select a project to add by using the project search field above.
        </p>
      </div>
    </div>
  </section>
</template>
