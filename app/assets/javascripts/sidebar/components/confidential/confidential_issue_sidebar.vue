<script>
import { mapState } from 'vuex';
import { __ } from '~/locale';
import Flash from '~/flash';
import tooltip from '~/vue_shared/directives/tooltip';
import Icon from '~/vue_shared/components/icon.vue';
import eventHub from '~/sidebar/event_hub';
import EditForm from './edit_form.vue';
import recaptchaModalImplementor from '~/vue_shared/mixins/recaptcha_modal_implementor';
import updateIssueConfidentialMutation from './queries/update_issue_confidential.mutation.graphql';
import { mapState, mapActions } from 'vuex';

export default {
  components: {
    EditForm,
    Icon,
  },
  directives: {
    tooltip,
  },
  mixins: [recaptchaModalImplementor],
  props: {
    iid: {
      required: true,
      type: String,
    },
    fullPath: {
      required: true,
      type: String,
    },
    isEditable: {
      required: true,
      type: Boolean,
    },
  },
  data() {
    return {
      edit: false,
      loading: false,
    };
  },
  computed: {
    ...mapState({ confidential: ({ noteableData }) => noteableData.confidential }),
    confidentialityIcon() {
      return this.confidential ? 'eye-slash' : 'eye';
    },
    tooltipLabel() {
      return this.confidential ? __('Confidential') : __('Not confidential');
    },
  },
  created() {
    eventHub.$on('updateConfidentialAttribute', this.updateConfidentialAttribute)
    eventHub.$on('closeConfidentialityForm', this.toggleForm);
  },
  beforeDestroy() {
    eventHub.$off('updateConfidentialAttribute', this.updateConfidentialAttribute)
    eventHub.$off('closeConfidentialityForm', this.toggleForm);
  },
  methods: {
    ...mapActions(['setConfidentiality']),
    toggleForm() {
      this.edit = !this.edit;
    },
    closeForm() {
      this.edit = false;
    },
    updateConfidentialAttribute() {
      // find a way to FF
      this.loading = true;
      const confidential = !this.confidential;

      this.$apollo
        .mutate({
          mutation: updateIssueConfidentialMutation,
          variables: {
            input: {
              projectPath: this.fullPath,
              iid: this.iid,
              confidential,
            },
          },
        })
        .then(({ data }) => {
          this.loading = false;
          this.toggleForm();
          this.setConfidentiality(data.issueSetConfidential.issue.confidential);
        })
        .catch(error => {
          this.loading = false;
          if (error.name === 'SpamError') {
            this.openRecaptcha();
          } else {
            Flash(__('Something went wrong trying to change the confidentiality of this issue'));
          }
        });
    },
  },
};
</script>

<template>
  <div class="block issuable-sidebar-item confidentiality">
    <div
      ref="collapseIcon"
      v-tooltip
      :title="tooltipLabel"
      class="sidebar-collapsed-icon"
      data-container="body"
      data-placement="left"
      data-boundary="viewport"
      @click="toggleForm"
    >
      <icon :name="confidentialityIcon" aria-hidden="true" />
    </div>
    <div class="title hide-collapsed">
      {{ __('Confidentiality') }}
      <a
        v-if="isEditable"
        ref="editLink"
        class="float-right confidential-edit"
        href="#"
        data-track-event="click_edit_button"
        data-track-label="right_sidebar"
        data-track-property="confidentiality"
        @click.prevent="toggleForm"
        >{{ __('Edit') }}</a
      >
    </div>
    <div class="value sidebar-item-value hide-collapsed">
      <edit-form
        v-if="edit"
        :is-confidential="confidential"
        :update-confidential-attribute="updateConfidentialAttribute"
        :loading="loading"
      />
      <div v-if="!confidential" class="no-value sidebar-item-value">
        <icon :size="16" name="eye" aria-hidden="true" class="sidebar-item-icon inline" />
        {{ __('Not confidential') }}
      </div>
      <div v-else class="value sidebar-item-value hide-collapsed">
        <icon
          :size="16"
          name="eye-slash"
          aria-hidden="true"
          class="sidebar-item-icon inline is-active"
        />
        {{ __('This issue is confidential') }}
      </div>
    </div>

    <recaptcha-modal v-if="showRecaptcha" :html="recaptchaHTML" @close="closeRecaptcha" />
  </div>
</template>
