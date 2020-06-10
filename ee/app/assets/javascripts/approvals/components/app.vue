<script>
import { mapState, mapActions } from 'vuex';
import { GlLoadingIcon, GlDeprecatedButton, GlAlert } from '@gitlab/ui';
import ModalRuleCreate from './modal_rule_create.vue';
import ModalRuleRemove from './modal_rule_remove.vue';

export default {
  components: {
    GlAlert,
    ModalRuleCreate,
    ModalRuleRemove,
    GlDeprecatedButton,
    GlLoadingIcon,
  },
  props: {
    isMrEdit: {
      type: Boolean,
      default: true,
      required: false,
    },
  },
  computed: {
    ...mapState({
      settings: 'settings',
      hasLoaded: state => state.approvals.hasLoaded,
      errorMessage: state => state.approvals.errorMessage,
    }),
    createModalId() {
      return `${this.settings.prefix}-approvals-create-modal`;
    },
    removeModalId() {
      return `${this.settings.prefix}-approvals-remove-modal`;
    },
    targetBranch() {
      if (this.settings.prefix === 'mr-edit' && !this.settings.mrSettingsPath) {
        return this.settings.mrCreateTargetBranch;
      }
      return null;
    },
  },
  mounted() {
    return this.fetchRules(this.targetBranch);
  },
  methods: {
    ...mapActions(['fetchRules']),
    ...mapActions({ openCreateModal: 'createModal/open' }),
  },
};
</script>

<template>
  <div class="js-approval-rules">
    <gl-alert
      v-if="errorMessage"
      :primary-button-text="__('Retry')"
      :dismissible="false"
      variant="danger"
      @primaryAction="fetchRules(targetBranch)"
    >
      {{ errorMessage }}
    </gl-alert>
    <gl-loading-icon v-else-if="!hasLoaded" size="lg" />
    <template v-else>
      <div class="border-bottom">
        <slot name="rules"></slot>
      </div>
      <div v-if="settings.canEdit && settings.allowMultiRule" class="border-bottom py-3 px-2">
        <div v-if="settings.allowMultiRule" class="d-flex">
          <gl-deprecated-button
            class="ml-auto btn-info btn-inverted"
            data-qa-selector="add_approvers_button"
            @click="openCreateModal(null)"
          >
            {{ __('Add approval rule') }}
          </gl-deprecated-button>
        </div>
      </div>
      <slot name="footer"></slot>
    </template>
    <modal-rule-create :modal-id="createModalId" :is-mr-edit="isMrEdit" />
    <modal-rule-remove :modal-id="removeModalId" />
  </div>
</template>
