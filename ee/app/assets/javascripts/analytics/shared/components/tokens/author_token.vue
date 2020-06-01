<script>
// {
// formattedKey: __('Author'),
// key: 'author',
// type: 'string',
// param: 'username',
// symbol: '@',
// icon: 'pencil',
// tag: '@author',
// },
import {
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlDropdownDivider,
  GlLoadingIcon,
} from '@gitlab/ui';
// import { __ } from '~/locale';
import { debounce } from 'lodash';
import { mapActions } from 'vuex';

const SEARCH_DELAY = 500;

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
    authors() {
      return this.config.authors;
    },
    searchAuthors: debounce(function debounceSearch({ data }) {
      console.log('data', data);
      if (data?.length) this.fetchAuthors(data);
    }, SEARCH_DELAY),
    activeUser() {
      return false;
    },
  },
  methods: {
    ...mapActions('filters', ['fetchAuthors']),
  },
  defaultSuggestions: [],
};
</script>

<template>
  <gl-filtered-search-token :config="config" v-bind="{ ...this.$attrs }" v-on="$listeners">
    <!-- TODO: might need to do something like -->
    <!-- v-bind="{ ...$props, ...$attrs }" -->
    <!-- v-on="$listeners" @input="searchAuthors"> -->
    <template #view="{ inputValue }">
      <!-- <gl-avatar
        v-if="activeUser"
        :size="16"
        :src="activeUser.avatar_url"
        shape="circle"
        class="gl-mr-2"
      /> -->
      <span>{{ activeUser ? activeUser.name : inputValue }}</span>
    </template>
    <template #suggestions>
      <gl-filtered-search-suggestion :value="$options.anyTriggerAuthor">{{
        $options.anyTriggerAuthor
      }}</gl-filtered-search-suggestion>
      <gl-dropdown-divider />
      <gl-loading-icon v-if="config.isLoading" />
      <template v-else>
        <gl-filtered-search-suggestion
          v-for="author in authors"
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
  <!-- <gl-filtered-search-token :config="config" v-bind="{ ...this.$attrs }" v-on="$listeners">
    <template #view="{ inputValue }">
      <template v-if="config.symbol">{{ config.symbol }}</template>
      {{ inputValue }}
    </template>
    <template #suggestions>
      <gl-filtered-search-suggestion
        v-for="suggestion in $options.defaultSuggestions"
        :key="suggestion.value"
        :value="suggestion.value"
        >{{ suggestion.text }}</gl-filtered-search-suggestion
      >
      <gl-dropdown-divider v-if="config.isLoading || filteredLabels.length" />
      <gl-loading-icon v-if="config.isLoading" />
      <template v-else>
        <gl-filtered-search-suggestion
          v-for="label in filteredLabels"
          ref="labelItem"
          :key="label.id"
          :value="label.value"
        >
          <div class="d-flex">
            <span
              class="d-inline-block mr-2 gl-w-16 gl-h-16 border-radius-small"
              :style="{
                backgroundColor: label.color,
              }"
            ></span>
            <span>{{ label.title }}</span>
          </div>
        </gl-filtered-search-suggestion>
      </template>
    </template>
  </gl-filtered-search-token> -->
</template>
