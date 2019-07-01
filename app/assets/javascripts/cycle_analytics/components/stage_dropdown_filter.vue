<script>
import { sprintf, s__, n__, __ } from '~/locale';
import $ from 'jquery';
import _ from 'underscore';
import Icon from '~/vue_shared/components/icon.vue';
import { GlButton } from '@gitlab/ui';
import Api from '~/api';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';

export default {
  name: 'StageDropdownFilter',
  components: {
    Icon,
    GlButton,
  },
  props: {
    stages: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      selectedStages: [],
    };
  },
  computed: {
    selectedStagesLabel() {
      return this.selectedStages.length
        ? sprintf(
            n__(
              'CycleAnalytics|%{stageName}',
              'CycleAnalytics|%d stages selected',
              this.selectedStages.length,
            ),
            { stageName: capitalizeFirstCharacter(this.selectedStages[0].name) },
          )
        : __('All stages');
    },
  },
  mounted() {
    $(this.$refs.stagesDropdown).glDropdown({
      selectable: true,
      multiSelect: true,
      clicked: this.onClick,
      data: this.formatData,
      renderRow: group => this.rowTemplate(group),
      text: stage => stage.name,
    });
  },
  methods: {
    getSelectedStages(selectedStage, $el) {
      const active = $el.hasClass('is-active');
      return active
        ? this.selectedStages.concat([selectedStage])
        : this.selectedStages.filter(stage => stage.name !== selectedStage.name);
    },
    setSelectedStages($el) {
      const selectedStage = {
        name: $el.data('name'),
      };
      this.selectedStages = this.getSelectedStages(selectedStage, $el);
    },
    onClick({ $el, e }) {
      e.preventDefault();
      this.setSelectedStages($el);
      this.$emit('selected', this.selectedStages);
    },
    formatData(term, callback) {
      callback(this.stages);
    },
    rowTemplate(stage) {
      return `
          <li>
            <a href='#' class='dropdown-menu-link' data-name="${stage.name}">
              ${_.escape(capitalizeFirstCharacter(stage.name))}
            </a>
          </li>
        `;
    },
    explodeStageNames() {
      return this.selectedStages.map(stage => capitalizeFirstCharacter(stage.name)).join(', ');
    },
  },
};
</script>

<template>
  <div>
    <div ref="stagesDropdown" class="dropdown dropdown-stages">
      <gl-button
        class="dropdown-menu-toggle wide shadow-none bg-white"
        type="button"
        data-toggle="dropdown"
        aria-expanded="false"
      >
        {{ selectedStagesLabel }}
        <icon name="chevron-down" />
      </gl-button>
      <div class="dropdown-menu dropdown-menu-selectable dropdown-menu-full-width">
        <div class="dropdown-title text-left">{{ __('Stages') }}</div>
        <div class="dropdown-content"></div>
      </div>
    </div>
  </div>
</template>
