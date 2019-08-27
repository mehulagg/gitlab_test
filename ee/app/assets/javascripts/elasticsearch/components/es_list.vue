<script>
import { mapState, mapActions } from 'vuex';
import { GlButton, GlAlert } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';

import EsIndex from './es_index.vue';
import * as modalTypes from '../store/modal_types';

export default {
  data() {
    return {
      isAlertDismissed: false,
      modalTypes: { ...modalTypes },
    };
  },
  components: {
    GlButton,
    GlAlert,
    Icon,
    EsIndex,
  },
  props: {
    indices: {
      type: Array,
      required: false,
      default: () => [],
    },
    alertMessage: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    ...mapState(['isIndexing', 'infoMessage']),
    showInfoMessage() {
      return this.infoMessage && this.infoMessage.text && !this.isAlertDismissed;
    },
  },
  methods: {
    ...mapActions(['showModal']),
    routeToNewIndex() {
      this.$router.push({ name: 'newIndexPath' });
    },
  },
};
</script>

<template>
  <div class="elasticsearch-indices">
    <div class="d-flex align-items-center">
      <h2 class="page-title flex-fill">
        <span class="title-text">{{ s__('Elasticsearch|GitLab indices') }}</span>
      </h2>

      <gl-button
        class="btn qa-reindex-link"
        :title="s__('Elasticsearch|Reindex')"
        @click="showModal(modalTypes.REINDEX)"
      >
        <icon name="repeat" />
        {{ s__('Elasticsearch|Reindex') }}
      </gl-button>

      <gl-button
        v-if="isIndexing"
        class="btn ml-2 qa-pause-index-link"
        :title="s__('Elasticsearch|Pause indexing')"
        @click="showModal(modalTypes.PAUSE_INDEXING)"
      >
        <icon name="pause" />
        {{ s__('Elasticsearch|Pause indexing') }}
      </gl-button>
      <gl-button
        v-else
        variant="success"
        class="btn ml-2 qa-resume-index-link"
        :title="s__('Elasticsearch|Pause indexing')"
        @click="showModal(modalTypes.RESUME_INDEXING)"
      >
        <icon name="play" />
        {{ s__('Elasticsearch|Resume indexing') }}
      </gl-button>

      <gl-button
        class="btn ml-2 btn-inverted btn-success qa-new-index-link"
        :title="s__('Elasticsearch|Add GitLab index')"
        @click="routeToNewIndex"
        data-qa-selector="es_list_new"
      >
        {{ s__('Elasticsearch|Add GitLab index') }}
      </gl-button>
    </div>

    <hr class="mt-0" />

    <gl-alert
      v-if="showInfoMessage"
      @dismiss="isAlertDismissed = true"
      :variant="infoMessage.type"
      class="mb-4"
    >
      {{ infoMessage.text }}
    </gl-alert>

    <div class="elasticsearch-indices-listing" data-qa-selector="es_list">
      <es-index v-for="index in indices" :key="index.id" :index="index" />
    </div>
  </div>
</template>
