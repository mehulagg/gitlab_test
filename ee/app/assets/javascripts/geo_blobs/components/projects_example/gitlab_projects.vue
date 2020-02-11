<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { __ } from '~/locale';
import query from '../../graphql/projects_example/group.query.graphql';
import GitlabProjectIssues from './gitlab_project_issues.vue';

export default {
  name: 'GitLabProjects',
  components: {
    GlDropdown,
    GlDropdownItem,
    GitlabProjectIssues,
  },
  apollo: {
    group: {
      query,
      variables() {
        return {
          fullPath: 'gitlab-org',
        };
      },
    },
  },
  data() {
    return {
      group: null,
      selectedProject: null,
    };
  },
  computed: {
    dropdownTitle() {
      if (!this.group) {
        return __('Loading ...');
      } else if (!this.selectedProject) {
        return __('Select Project');
      }

      return this.selectedProject.name;
    },
    projects() {
      if (!this.group) {
        return [];
      }

      return this.group.projects.nodes;
    },
  },
};
</script>

<template>
  <section>
    <header class="m-3">
      <label for="dropdown">{{ __('Project:') }}</label>
      <gl-dropdown :text="dropdownTitle">
        <gl-dropdown-item
          v-for="project in projects"
          :key="project.fullPath"
          @click="selectedProject = project"
          >{{ project.name }}</gl-dropdown-item
        >
      </gl-dropdown>
      <gitlab-project-issues v-if="selectedProject" :project="selectedProject" />
    </header>
  </section>
</template>

<style lang="scss" scoped></style>
