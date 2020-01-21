<script>
import { __ } from '~/locale';
import { mapActions, mapState } from 'vuex';
import {
  GlModal,
  GlFormSelect,
  GlFormGroup,
  GlFormInput,
  GlFormCheckbox,
  GlLink,
  GlIcon,
} from '@gitlab/ui';

export default {
  components: {
    GlModal,
    GlFormGroup,
    GlFormSelect,
    GlFormInput,
    GlFormCheckbox,
    GlLink,
    GlIcon,
  },
  computed: {
    ...mapState([
      'projectId',
      'environments',
      'typeOptions',
      'variable',
      'variableBeingEdited',
      'showInputValue',
      'isGroup',
    ]),
    canSubmit() {
      return this.variableData.key !== '' && this.variableData.secret_value !== '';
    },
    canMask() {
      const regex = RegExp('^[a-zA-Z0-9_+=/@:-]{8,}$');
      return regex.test(this.variableData.secret_value);
    },
    variableData() {
      return this.variableBeingEdited ? this.variableBeingEdited : this.variable;
    },
    modalActionText() {
      return this.variableBeingEdited ? __('Update Variable') : __('Add variable');
    },
    primaryAction() {
      return {
        text: this.modalActionText,
        attributes: [{ variant: 'success' }, { disabled: !this.canSubmit }],
      };
    },
    cancelAction() {
      return {
        text: __('Cancel'),
      };
    },
  },
  methods: {
    ...mapActions([
      'addVariable',
      'updateVariable',
      'resetEditing',
      'displayInputValue',
      'clearModal',
    ]),
    modalAction() {
      if (this.variableBeingEdited) {
        this.updateVariable(this.variableBeingEdited);
      } else {
        this.addVariable();
      }
    },
    resetModalHandler() {
      // eslint-disable-next-line
      this.variableBeingEdited ? this.resetEditing() : this.clearModal();
    },
  },
};
</script>

<template>
  <gl-modal
    modal-id="add-ci-variable"
    :title="modalActionText"
    :action-primary="primaryAction"
    :action-cancel="cancelAction"
    @ok="modalAction"
    @hidden="resetModalHandler"
  >
    <form action="">
      <gl-form-group label="Type" label-for="type">
        <gl-form-select id="type" v-model="variableData.variable_type" :options="typeOptions" />
      </gl-form-group>

      <div class="d-flex">
        <gl-form-group label="Key" label-for="key" class="w-50 append-right-15">
          <gl-form-input
            id="key"
            v-model="variableData.key"
            type="text"
            data-qa-selector="variable_key"
          />
        </gl-form-group>

        <gl-form-group label="Value" label-for="value" class="w-50">
          <gl-form-input
            id="value"
            v-model="variableData.secret_value"
            type="text"
            data-qa-selector="variable_value"
          />
        </gl-form-group>
      </div>

      <gl-form-group v-if="!isGroup" label="Environment scope" label-for="env">
        <gl-form-select id="env" v-model="variableData.environment_scope" :options="environments" />
      </gl-form-group>

      <gl-form-group label="Flags" label-for="flags">
        <gl-form-checkbox v-model="variableData.protected">
          {{ __('Protect variable') }}
          <gl-link href="/help/ci/variables/README#protected-environment-variables">
            <gl-icon name="question" :size="12" />
          </gl-link>
          <p class="prepend-top-4 clgray">
            {{ __('Allow variables to run on protected branches and tags.') }}
          </p>
        </gl-form-checkbox>

        <gl-form-checkbox
          v-model="variableData.masked"
          :disabled="!canMask"
          data-qa-selector="variable_masked"
          class="js-masked-ci-variable"
        >
          {{ __('Mask variable') }}
          <gl-link href="/help/ci/variables/README#masked-variables">
            <gl-icon name="question" :size="12" />
          </gl-link>
          <p class="prepend-top-4 append-bottom-0 clgray">
            {{
              __('Variables will be masked in job logs. Requires value to meet regexp requriments.')
            }}
            <gl-link href="/help/ci/variables/README#masked-variables">{{
              __('More information')
            }}</gl-link>
          </p>
        </gl-form-checkbox>
      </gl-form-group>
    </form>
  </gl-modal>
</template>
