<script>
import { mapState, mapActions } from 'vuex';
import { GlModal, GlLoadingIcon, GlButton, GlAlert } from '@gitlab/ui';
import modalMixin from '../mixins/es_index_modal_mixin';

import Service from '../service/elasticsearch_service';

import * as modalTypes from '../store/modal_types';

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
      reindexAfterResuming: true,
    };
  },
  computed: {
    ...mapState(['isIndexing', 'modalType']),
    shouldReindex() {
      return this.modalType === modalTypes.REINDEX;
    },
    shouldPause() {
      return this.modalType === modalTypes.PAUSE_INDEXING && this.isIndexing;
    },
    shouldResume() {
      return this.modalType === modalTypes.RESUME_INDEXING && !this.isIndexing;
    },
  },
  methods: {
    ...mapActions(['setIndexingStatus', 'hideModal', 'setInfoMessage']),
    togglePause() {
      this.requestInFlight = true;
      Service.toggleIndexingGlobally(!this.isIndexing)
        .then(() => {
          if (!this.isIndexing && this.reindexAfterResuming) {
            return this.reindex();
          }
          this.hideModal();
          this.requestInFlight = false;
          this.setIndexingStatus(!this.isIndexing);
          return undefined;
        })
        .catch(e => {
          this.errorMessage = e.error || e;
          this.isAlertDismissed = false;
          this.requestInFlight = false;
        });
    },
    reindex() {
      this.requestInFlight = true;
      return Service.reindexGlobally()
        .then(() => {
          this.setIndexingStatus(true);
          this.setInfoMessage({
            text: 'Your data is now being reindexed.',
            type: 'success',
          });
          this.hideModal();
          this.requestInFlight = false;
        })
        .catch(e => {
          this.errorMessage = e.error || e;
          this.isAlertDismissed = false;
          this.requestInFlight = false;
        });
    },
    handleActionClick() {
      if (this.shouldReindex) {
        this.reindex();
      } else {
        this.togglePause();
      }
    },
  },
};
</script>
<template>
  <gl-modal ref="modal" modal-id="modal-index-indexing" @close.prevent="hideModal">
    <template #modal-title>
      <template v-if="shouldReindex">{{ s__('Elasticsearch|Reindex') }}</template>
      <template v-else-if="shouldResume">{{ s__('Elasticsearch|Resume indexing') }}</template>
      <template v-else-if="shouldPause">{{ s__('Elasticsearch|Pause indexing') }}</template>
    </template>

    <gl-alert
      v-if="errorMessage && !isAlertDismissed"
      @dismiss="isAlertDismissed = true"
      variant="danger"
      class="mb-4"
    >
      {{ errorMessage }}
    </gl-alert>

    <template v-if="shouldReindex">
      <p>
        {{
          s__(
            'Elasticsearch|Reindexing your data can take a long time, it is recommended to only trigger a reindex when you are certain there is data missing in your index.',
          )
        }}
      </p>
    </template>

    <template v-else-if="shouldResume">
      <p>
        {{
          s__(
            'Elasticsearch|As your indexing was paused, there might be data missing in your GitLab index. To fill these gaps, you could reindex your data after you resume the indexing again.',
          )
        }}
      </p>

      <div class="form-group">
        <label class="label-wrapper">
          <input v-model="reindexAfterResuming" name="reindex" type="checkbox" />
          <span class="mr-1 bold inline">{{
            s__('Elasticsearch|Reindex data after resuming to index')
          }}</span>
        </label>
      </div>
    </template>

    <template v-else-if="shouldPause">
      <p>
        {{
          s__(
            'Elasticsearch|If you pause the indexing, your search results will not be complete until you reindex again.',
          )
        }}
      </p>
    </template>

    <template #modal-footer>
      <div class="w-100">
        <div class="float-right">
          <button class="btn" @click.prevent="hideModal">{{ __('Cancel') }}</button>
          <gl-button
            :variant="shouldPause ? 'warning' : 'success'"
            :disabled="requestInFlight"
            @click="handleActionClick"
          >
            <gl-loading-icon v-if="requestInFlight" inline />

            <template v-if="shouldReindex">
              {{ s__('Elasticsearch|Reindex') }}
            </template>
            <template v-else-if="shouldResume">
              {{ s__('Elasticsearch|Resume indexing') }}
            </template>
            <template v-else-if="shouldPause">
              {{ s__('Elasticsearch|Pause indexing') }}
            </template>
          </gl-button>
        </div>
      </div>
    </template>
  </gl-modal>
</template>
