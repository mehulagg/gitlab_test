<script>
import { GlTable, GlButton, GlModalDirective, GlIcon, GlPopover } from '@gitlab/ui';
import { s__, __ } from '~/locale';
import { mapState, mapActions } from 'vuex';
import { ADD_CI_VARIABLE_MODAL_ID } from '../constants';

export default {
  modalId: ADD_CI_VARIABLE_MODAL_ID,
  fields: [
    {
      key: 'variable_type',
      label: s__('CiVariables|Type'),
    },
    {
      key: 'key',
      label: s__('CiVariables|Key'),
      sortable: true,
    },
    {
      key: 'value',
      label: s__('CiVariables|Value'),
      tdClass: 'qa-ci-variable-input-value',
    },
    {
      key: 'protected',
      label: s__('CiVariables|Protected'),
    },
    {
      key: 'masked',
      label: s__('CiVariables|Masked'),
    },
    {
      key: 'environment_scope',
      label: s__('CiVariables|Environments'),
    },
    {
      key: 'actions',
      label: '',
    },
  ],
  components: {
    GlTable,
    GlButton,
    GlIcon,
    GlPopover,
  },
  directives: {
    GlModalDirective,
  },
  computed: {
    ...mapState(['variables', 'valuesHidden', 'isGroup', 'isLoading', 'isDeleting']),
    valuesButtonText() {
      return this.valuesHidden ? __('Reveal values') : __('Hide values');
    },
    tableIsNotEmpty() {
      return this.variables && this.variables.length > 0;
    },
    fields() {
      if (this.isGroup) {
        return this.$options.fields.filter(field => field.key !== 'environment_scope');
      }
      return this.$options.fields;
    },
  },
  mounted() {
    this.fetchVariables();
  },
  methods: {
    ...mapActions(['fetchVariables', 'toggleValues', 'editVariable']),
    colWidths(key) {
      if (key === 'variable_type') {
        return { width: '70px' };
      }

      if (key === 'protected' || key === 'masked') {
        return { width: '100px' };
      }

      if (key === 'environment_scope') {
        return { width: '20%' };
      }

      if (key === 'actions') {
        return { width: '50px' };
      }

      return { width: '40%' };
    },
  },
};
</script>

<template>
  <div class="ci-variable-table">
    <gl-table
      :fields="fields"
      :items="variables"
      tbody-tr-class="js-ci-variable-row"
      sort-by="key"
      sort-direction="asc"
      stacked="lg"
      fixed
      show-empty
    >
      <template #table-colgroup="scope">
        <col v-for="field in scope.fields" :key="field.key" :style="colWidths(field.key)" />
      </template>
      <template #cell(key)="data">
        <span :id="`ci-variable-key-${data.item.id}`" class="d-inline-block mw-100 text-truncate">{{
          data.item.key
        }}</span>
        <gl-popover :target="`ci-variable-key-${data.item.id}`" triggers="hover" placement="top">
          {{ data.item.key }}
          <gl-button class="btn-transparent btn-clipboard" :data-clipboard-text="data.item.key">
            <gl-icon name="copy-to-clipboard" />
          </gl-button>
        </gl-popover>
      </template>
      <template #cell(value)="data">
        <span v-if="valuesHidden">*********************</span>
        <div v-else>
          <span
            :id="`ci-variable-value-${data.item.id}`"
            class="d-inline-block mw-100 text-truncate"
            >{{ data.value }}</span
          >
          <gl-popover
            :target="`ci-variable-value-${data.item.id}`"
            triggers="hover"
            placement="top"
          >
            {{ data.item.value }}
            <gl-button class="btn-transparent btn-clipboard" :data-clipboard-text="data.item.value">
              <gl-icon name="copy-to-clipboard" />
            </gl-button>
          </gl-popover>
        </div>
      </template>
      <template #cell(environment_scope)="data">
        <span :id="`ci-variable-env-${data.item.id}`" class="d-inline-block mw-100 text-truncate">{{
          data.item.environment_scope
        }}</span>
        <gl-popover :target="`ci-variable-env-${data.item.id}`" triggers="hover" placement="top">
          {{ data.item.environment_scope }}
          <gl-button
            class="btn-transparent btn-clipboard"
            :data-clipboard-text="data.item.environment_scope"
          >
            <gl-icon name="copy-to-clipboard" />
          </gl-button>
        </gl-popover>
      </template>
      <template #cell(actions)="data">
        <gl-button
          ref="edit-ci-variable"
          v-gl-modal-directive="$options.modalId"
          @click="editVariable(data.item)"
        >
          <gl-icon :size="12" name="pencil" />
        </gl-button>
      </template>
      <template #empty>
        <p ref="empty-variables" class="text-center empty-variables">
          {{ __('There are no variables yet.') }}
        </p>
      </template>
    </gl-table>
    <div
      class="ci-variable-actions d-flex justify-content-end"
      :class="{ 'justify-content-center': !tableIsNotEmpty }"
    >
      <gl-button
        v-if="tableIsNotEmpty"
        ref="secret-value-reveal-button"
        data-qa-selector="reveal_ci_variable_value"
        class="append-right-8"
        @click="toggleValues(!valuesHidden)"
        >{{ valuesButtonText }}</gl-button
      >
      <gl-button
        ref="add-ci-variable"
        v-gl-modal-directive="$options.modalId"
        data-qa-selector="add_ci_variable"
        variant="success"
        >{{ __('Add Variable') }}</gl-button
      >
    </div>
  </div>
</template>
