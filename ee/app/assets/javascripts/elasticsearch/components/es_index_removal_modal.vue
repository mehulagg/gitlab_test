<script>
import { mapState, mapGetters, mapActions } from 'vuex';
import { GlModal, GlLoadingIcon, GlButton, GlAlert } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';

import modalMixin from '../mixins/es_index_modal_mixin';

import Service from '../service/elasticsearch_service';

function warningString(index, string, params = {}) {
  const strongIndexName = index ? `<strong>${index.friendly_name}</strong>` : '';
  return sprintf(
    s__('Elasticsearch|You are going to remove %{strongIndexName}. %{string}'),
    { strongIndexName, string, ...params },
    false,
  );
}

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
      removeIndexDescription: '',
      removeIndexWarning: '',
      removalConfirmation: '',
    };
  },
  computed: {
    ...mapState(['indices']),
    ...mapGetters(['searchSourceIndex']),
    otherIndices() {
      return this.indices.filter(i => !i.clicked);
    },
    clickedSourceSeveralIndices() {
      return this.clickedIndex === this.searchSourceIndex && this.otherIndices.length > 1;
    },
    isConfirmed() {
      return this.clickedIndex
        ? this.removalConfirmation === this.clickedIndex.friendly_name
        : false;
    },
  },
  methods: {
    ...mapActions(['markIndexAsSearchSource', 'hideModal']),
    beforeShow() {
      this.removeIndexDescription = this.generateRemoveIndexDescription();
      this.removeIndexWarning = this.generateRemoveIndexWarning();
    },
    beforeHide() {
      this.removalConfirmation = '';
    },
    generateRemoveIndexDescription() {
      return sprintf(
        s__(
          'Elasticsearch|This action can lead to data loss. To prevent accidental actions we ask you to confirm your intention.%{lineBreak}' +
            'Please type %{codeIndexName} to proceed or close this modal to cancel.',
        ),
        {
          codeIndexName: this.clickedIndex ? `<code>${this.clickedIndex.friendly_name}</code>` : '',
          lineBreak: '</br>',
        },
        false,
      );
    },
    generateRemoveIndexWarning() {
      const strongStart = '<strong>';
      const strongEnd = '</strong>';

      let resString = [s__('Elasticsearch|Removed indices cannot be restored.')];

      if (this.clickedIndex === this.searchSourceIndex) {
        switch (this.indices.length) {
          case 1:
            resString = [
              s__(
                'Elasticsearch|As this is your only GitLab index, %{strongStart}Advanced Global Search will be disabled%{strongEnd} after removing this index. Removed indices cannot be restored.',
              ),
              { strongStart, strongEnd },
            ];
            break;
          case 2:
            resString = [
              s__(
                'Elasticsearch|By removing the GitLab index that is currently set as search source, %{secondIndexName} will become the new search source. Removed indices cannot be restored.',
              ),
              {
                secondIndexName: this.otherIndices.length
                  ? `<strong>${this.otherIndices[0].friendly_name}</strong>`
                  : '',
              },
            ];
            break;
          default:
            resString = [
              s__(
                'Elasticsearch|By removing the GitLab index that is currently set as search source, you will have to %{strongStart}select a new GitLab index to use as search source %{strongEnd}.',
              ),
              { strongStart, strongEnd },
            ];
            break;
        }
      }
      return warningString(this.clickedIndex, ...resString);
    },
    indexRemove() {
      this.requestInFlight = true;
      const params = [this.clickedIndex.id];
      if (this.clickedSourceSeveralIndices) {
        params.push(this.$refs.newSearchSourceId.value);
      }

      Service.removeIndex(...params)
        .then(() => {
          this.requestInFlight = false;
          // BE doesn't return the updated list of indices, so we have to remove index from the indices manually
          const data = this.indices.filter(index => index.id !== this.clickedIndex.id);
          this.updateIndices(data);
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
  <gl-modal ref="modal" modal-id="modal-index-remove" @close.prevent="hideModal">
    <template #modal-title>{{ s__('Elasticsearch|Remove GitLab index') }}</template>

    <gl-alert
      v-if="errorMessage && !isAlertDismissed"
      @dismiss="isAlertDismissed = true"
      variant="danger"
      class="mb-4"
    >
      {{ errorMessage }}
    </gl-alert>

    <p class="text-danger font-weight-normal" v-html="removeIndexWarning"></p>

    <template v-if="clickedSourceSeveralIndices">
      <label class="text-danger font-weight-normal">
        {{ s__('Elasticsearch|Which GitLab index should become the new search source?') }}

        <select
          ref="newSearchSourceId"
          name="new-search-source"
          class="form-control mb-4 mt-1 w-50"
        >
          <option
            v-for="i in otherIndices"
            :key="i.id"
            :value="i.id"
            :selected="i.id === otherIndices[0].id"
            >{{ i.friendly_name }}</option
          >
        </select>
      </label>
    </template>

    <p v-html="removeIndexDescription"></p>

    <input
      ref="nameConfirmation"
      v-model="removalConfirmation"
      type="text"
      class="form-control"
      autocomplete="off"
    />

    <template #modal-footer>
      <div class="w-100">
        <div class="float-right" id="tooltipcontainer">
          <button class="btn" @click.prevent="hideModal">{{ __('Cancel') }}</button>
          <gl-button
            :disabled="!isConfirmed || requestInFlight || undefined"
            variant="danger"
            @click="indexRemove()"
          >
            <gl-loading-icon v-if="requestInFlight" inline />
            {{ __('Remove') }}
          </gl-button>
        </div>
      </div>
    </template>
  </gl-modal>
</template>
