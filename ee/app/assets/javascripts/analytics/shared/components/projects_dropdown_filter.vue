<script>
import { __ } from '~/locale';
import $ from 'jquery';
import _ from 'underscore';
import Icon from '~/vue_shared/components/icon.vue';
import { GlLoadingIcon, GlButton } from '@gitlab/ui';
import Api from '~/api';

export default {
  name: 'ProjectsDropdownFilter',
  components: {
    Icon,
    GlLoadingIcon,
    GlButton,
  },
  props: {
    groupId: {
      type: Number,
      required: true,
    },
    multiSelect: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      loading: true,
      selectedProjects: [],
    };
  },
  computed: {
    selectedProjectsLabel() {
      return this.selectedProjects.length
        ? this.explodeProjectNames()
        : this.selectedProjectsPlaceholder;
    },
    selectedProjectsPlaceholder() {
      return this.multiSelect ? __('Select projects') : __('Select a project');
    },
  },
  mounted() {
    $(this.$refs.projectsDropdown).glDropdown({
      selectable: true,
      filterable: true,
      filterRemote: true,
      fieldName: 'project_id',
      multiSelect: this.multiSelect,
      search: {
        fields: ['name'],
      },
      clicked: this.onClick,
      data: this.fetchData,
      renderRow: group => this.rowTemplate(group),
      text: project => project.name,
    });
  },
  methods: {
    getSelectedProjects(selectedProject, $el) {
      const active = $el.hasClass('is-active');
      return active
        ? this.selectedProjects.concat([selectedProject])
        : this.selectedProjects.filter(project => project.id !== selectedProject.id);
    },
    setSelectedProjects($el) {
      const selectedProject = {
        id: $el.data('id'),
        name: $el.data('name'),
        path: $el.data('path'),
      };
      this.selectedProjects = this.multiSelect
        ? this.getSelectedProjects(selectedProject, $el)
        : [selectedProject];
    },
    onClick({ $el, e }) {
      e.preventDefault();
      this.setSelectedProjects($el);
      this.$emit('selected', this.selectedProjects);
    },
    fetchData(term, callback) {
      this.loading = true;
      return Api.groupProjects(this.groupId, term, {}, projects => {
        this.loading = false;
        callback(projects);
      });
    },
    rowTemplate(project) {
      return `
          <li>
            <a href='#' class='dropdown-menu-link' data-id="${project.id}" data-name="${
        project.name
      }" data-path="${project.path_with_namespace}">
              ${_.escape(project.name)}
            </a>
          </li>
        `;
    },
    explodeProjectNames() {
      return this.selectedProjects.map(project => project.name).join(', ');
    },
  },
};
</script>

<template>
  <div>
    <div ref="projectsDropdown" class="dropdown dropdown-projects">
      <gl-button
        class="dropdown-menu-toggle wide shadow-none bg-white"
        type="button"
        data-toggle="dropdown"
        aria-expanded="false"
      >
        {{ selectedProjectsLabel }}
        <icon name="chevron-down" />
      </gl-button>
      <div class="dropdown-menu dropdown-menu-selectable dropdown-menu-full-width">
        <div class="dropdown-title">{{ __('Projects') }}</div>
        <div class="dropdown-input">
          <input class="dropdown-input-field" type="search" :placeholder="__('Search projects')" />
          <icon name="search" class="dropdown-input-search" data-hidden="true" />
        </div>
        <div class="dropdown-content"></div>
        <div class="dropdown-loading">
          <gl-loading-icon />
        </div>
      </div>
    </div>
  </div>
</template>
