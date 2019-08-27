<script>
import { mapActions } from 'vuex';
import { GlModal, GlLoadingIcon, GlButton, GlAlert } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';

import Service from '../service/elasticsearch_service';
import modalMixin from '../mixins/es_index_modal_mixin';

export default {
  components: {
    GlModal,
    GlLoadingIcon,
    GlButton,
    GlAlert,
  },
  mixins: [modalMixin],
  data() {
    return {
      switchSourceDescription: '',
    };
  },
  methods: {
    ...mapActions(['markIndexAsSearchSource', 'hideModal']),
    beforeShow() {
      this.switchSourceDescription = this.generateSwitchSourceDescription();
    },
    generateSwitchSourceDescription() {
      return sprintf(
        s__(
          'Elasticsearch|After switching the search source, all search results will be based on the data in the newly activated GitLab index. Are you sure you want to switch to %{codeIndexName}?',
        ),
        {
          codeIndexName: this.clickedIndex ? `<code>${this.clickedIndex.friendly_name}</code>` : '',
        },
        false,
      );
    },
    switchSource() {
      this.requestInFlight = true;
      Service.switchSearchSource(this.clickedIndex.id)
        .then(() => {
          this.requestInFlight = false;
          this.markIndexAsSearchSource(this.clickedIndex.id);
          this.hideModal();
        })
        .catch(e => {
          this.errorMessage = e.error || e;
          this.isAlertDismissed = false;
          this.requestInFlight = false;
        });
    },
  },
};
</script>

<template>
  <gl-modal ref="modal" modal-id="modal-switch-source" @close.prevent="hideModal">
    <template #modal-title>{{ s__('Elasticsearch|Switch search source') }}</template>

    <gl-alert
      v-if="errorMessage && !isAlertDismissed"
      @dismiss="isAlertDismissed = true"
      variant="danger"
      class="mb-4"
    >
      {{ errorMessage }}
    </gl-alert>

    <p v-html="switchSourceDescription"></p>

    <template #modal-footer>
      <div class="w-100">
        <div class="float-right">
          <button class="btn" @click.prevent="hideModal">{{ __('Cancel') }}</button>
          <gl-button variant="primary" :disabled="requestInFlight" @click="switchSource()">
            <gl-loading-icon v-if="requestInFlight" inline />
            {{ __('Switch') }}
          </gl-button>
        </div>
      </div>
    </template>
  </gl-modal>
</template>
