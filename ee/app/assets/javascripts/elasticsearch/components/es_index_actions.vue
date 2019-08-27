<script>
import { mapActions } from 'vuex';
import { GlButton, GlTooltip, GlLoadingIcon } from '@gitlab/ui';
import * as modalTypes from '../store/modal_types';

export default {
  components: {
    GlButton,
    GlTooltip,
    GlLoadingIcon,
  },
  props: {
    index: {
      type: Object,
      required: true,
    },
  },
  data: () => {
    return {
      isStartingIndexing: false,
    };
  },
  methods: {
    ...mapActions(['markIndexAsClicked', 'showModal']),
    onRemoveIndex() {
      this.markIndexAsClicked(this.index.id);
      this.showModal(modalTypes.REMOVE);
    },
    onSwitchSource() {
      this.markIndexAsClicked(this.index.id);
      this.showModal(modalTypes.SWITCH_SEARCH);
    },
    editIndex() {
      this.$router.push(`/admin/elasticsearch/edit/${this.index.id}`);
    },
  },
};
</script>
<template>
  <div>
    <template v-if="!index.active_search_source">
      <gl-button
        ref="searchSource"
        class="btn btn-sm ml-2 btn-info qa-index-use-as-search-source"
        :title="s__('Elasticsearch|Use as search source')"
        @click="onSwitchSource"
      >
        <strong>{{ s__('Elasticsearch|Use as search source') }}</strong>
      </gl-button>
      <gl-tooltip :target="() => $refs.searchSource">
        {{ s__('Elasticsearch|This index will be used for all search results in your GitLab instance.') }}
      </gl-tooltip>
    </template>

    <!--    <gl-button-->
    <!--      v-if="index.isFirstIndex"-->
    <!--      class="btn btn-sm btn-success ml-2 qa-index-start-indexing"-->
    <!--      @click="startIndexing"-->
    <!--      :title="s__('Elasticsearch|Start indexing')"-->
    <!--    >-->
    <!--      <gl-loading-icon v-if="isStartingIndexing" inline color="light" />-->
    <!--      <strong>{{ s__('Elasticsearch|Start indexing') }}</strong>-->
    <!--    </gl-button>-->

    <gl-button
      class="btn btn-sm ml-2 btn-inverted qa-index-edit"
      @click="editIndex"
      :title="__('Edit')"
      >{{ __('Edit') }}</gl-button
    >
    <gl-button
      v-if="!index.active_search_source"
      class="btn btn-sm ml-2 btn-inverted btn-danger qa-index-remove"
      :title="__('Remove')"
      @click="onRemoveIndex"
      >{{ __('Remove') }}</gl-button
    >
  </div>
</template>
