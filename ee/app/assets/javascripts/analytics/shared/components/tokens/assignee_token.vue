<script>
import {
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlDropdownDivider,
  GlLoadingIcon,
} from '@gitlab/ui';
// import { __ } from '~/locale';
// import { debounce } from 'lodash';
import { mapActions } from 'vuex';

// const SEARCH_DELAY = 500;

export default {
  components: {
    GlFilteredSearchToken,
    GlFilteredSearchSuggestion,
    GlDropdownDivider,
    GlLoadingIcon,
  },
  inheritAttrs: false,
  props: {
    config: {
      type: Object,
      required: true,
    },
    value: {
      type: Object,
      required: true,
    },
  },
  computed: {
    assignees() {
      return this.config.assignees;
    },
  },
  methods: {
    ...mapActions('filters', ['fetchAssignees']),
  },
  defaultSuggestions: [],
};
</script>

<template>
  <gl-filtered-search-token :config="config" v-bind="{ ...this.$attrs }" v-on="$listeners">
    <template #view="{ inputValue }">
      <!-- <gl-avatar
        v-if="activeUser"
        :size="16"
        :src="activeUser.avatar_url"
        shape="circle"
        class="gl-mr-2"
      /> -->
      <!-- <span>{{ activeUser ? activeUser.name : inputValue }}</span> -->
      <span>{{ inputValue }}</span>
    </template>
    <template #suggestions>
      <gl-filtered-search-suggestion :value="$options.anyTriggerAuthor">{{
        $options.anyTriggerAuthor
      }}</gl-filtered-search-suggestion>
      <gl-dropdown-divider />
      <gl-loading-icon v-if="config.isLoading" />
      <template v-else>
        <gl-filtered-search-suggestion
          v-for="author in assignees"
          :key="author.username"
          :value="author.username"
        >
          <div class="d-flex">
            <gl-avatar :size="32" :src="author.avatar_url" />
            <div>
              <div>{{ author.name }}</div>
              <div>@{{ author.username }}</div>
            </div>
          </div>
        </gl-filtered-search-suggestion>
      </template>
    </template>
  </gl-filtered-search-token>
</template>
