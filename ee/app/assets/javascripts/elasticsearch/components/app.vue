<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';

import EsEmptyState from './es_empty_state.vue';
import EsList from './es_list.vue';
import EsIndexRemovalModal from './es_index_removal_modal.vue';
import EsIndexSwitchSearchSourceModal from './es_index_switch_search_source_modal.vue';
import EsIndexIndexingModal from './es_index_indexing_modal.vue';

import Service from '../service/elasticsearch_service';

export default {
  components: {
    EsEmptyState,
    EsList,
    EsIndexRemovalModal,
    EsIndexSwitchSearchSourceModal,
    EsIndexIndexingModal,
    GlLoadingIcon,
  },
  data() {
    return {
      indexingAction: 'pause',
      alertMessage: '',
      isLoading: true,
    };
  },
  computed: {
    ...mapState(['indices']),
    ...mapGetters(['isRemoveModalVisible', 'isSwitchSearchModalVisible', 'isIndexingModalVisible']),
  },
  created() {
    Service.getIndices()
      .then(({ data }) => {
        this.updateIndices(data);
      })
      .catch(() => {})
      .finally(() => {
        this.isLoading = false;
      });
    Service.getApplicationSettings()
      .then(({ data }) => {
        this.setIndexingStatus(data.elasticsearch_indexing);
      })
      .catch(() => {});
  },
  methods: {
    ...mapActions(['updateIndices', 'setIndexingStatus']),
  },
};
</script>

<template>
  <div class="elasticsearch-container">
    <gl-loading-icon
      v-if="isLoading"
      :label="s__('Elasticsearch|Loading GitLab indices')"
      size="sm"
      class="loading-animation prepend-top-20 append-bottom-20"
    />
    <template v-else>
      <es-empty-state v-if="!indices.length" />
      <es-list v-else :indices="indices" />
    </template>
    <es-index-removal-modal :visible="isRemoveModalVisible" ref="removalModal" />
    <es-index-switch-search-source-modal
      :visible="isSwitchSearchModalVisible"
      ref="switchSourceModal"
    />
    <es-index-indexing-modal
      :visible="isIndexingModalVisible"
      ref="indexingModal"
      :action="indexingAction"
    />
  </div>
</template>
