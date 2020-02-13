<script>
import { GlTable, GlButton, GlModalDirective, GlIcon } from '@gitlab/ui';
import { __ } from '~/locale';
import { mapState, mapActions } from 'vuex';

export default {
  fields: [
    {
      key: 'variable_type',
      label: __('Type'),
    },
    {
      key: 'key',
      label: __('Key'),
    },
    {
      key: 'value',
      label: __('Value'),
      tdClass: 'qa-ci-variable-input-value',
    },
    {
      key: 'protected',
      label: __('Protected'),
    },
    {
      key: 'masked',
      label: __('Masked'),
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
      if (this.variables) return this.variables.length > 0;
    },
  },
  mounted() {
    this.fetchVariables();

    if (!this.isGroup) {
      this.addEnvironmentScopeField();
    }
  },
  methods: {
    ...mapActions(['fetchVariables', 'deleteVariable', 'toggleValues', 'editVariable']),
    valueHandler(value) {
      return this.valuesHidden ? '*****************' : value;
    },
    // only display environment scope on projects, not groups
    addEnvironmentScopeField() {
      this.$options.fields.splice(5, 0, {
        key: 'environment_scope',
        label: __('Environment Scope'),
      });
    },
    deleteAction(index) {
      // remove item from variables array first so data transform doesn't show
      const variableToDelete = this.variables.splice(index, 1)[0];
      this.deleteVariable(variableToDelete);
    },
  },
};
</script>

<template>
  <div class="ci-variable-table">
    <gl-table
      :fields="$options.fields"
      :items="variables"
      :responsive="true"
      show-empty
      tbody-tr-class="js-ci-variable-row"
    >
      <template v-slot:cell(value)="data">
        <span v-if="valuesHidden">*****************</span>
        <span v-else>{{ data.value }}</span>
      </template>
      <template v-slot:cell(actions)="data">
        <gl-button
          v-gl-modal-directive="'add-ci-variable'"
          class="js-edit-ci-variable"
          @click="editVariable(data.item)"
        >
          <gl-icon name="pencil" />
        </gl-button>
        <gl-button
          class="js-delete-ci-variable"
          category="secondary"
          variant="danger"
          @click="deleteAction(data.index)"
        >
          <gl-icon name="remove" />
        </gl-button>
      </template>
      <template v-slot:empty>
        <p class="settings-message text-center empty-variables">
          {{
            __(
              'There are currently no variables, add a variable with the Add Variable button below.',
            )
          }}
        </p>
      </template>
    </gl-table>
    <div class="ci-variable-actions d-flex justify-content-end">
      <gl-button
        v-if="tableIsNotEmpty"
        data-qa-selector="reveal_ci_variable_value"
        class="append-right-8 js-secret-value-reveal-button"
        @click="toggleValues(!valuesHidden)"
        >{{ valuesButtonText }}</gl-button
      >
      <gl-button
        v-gl-modal-directive="'add-ci-variable'"
        class="js-add-ci-variable"
        data-qa-selector="add_ci_variable"
        variant="success"
        >{{ __('Add Variable') }}</gl-button
      >
    </div>
  </div>
</template>
