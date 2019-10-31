<script>
import { GlTabs, GlTab, GlFormInput, GlDropdown, GlDropdownItem } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import { mapActions, mapState } from 'vuex';
import _ from 'underscore';
import { ACTION_TYPES } from '../store/constants';

export default {
  name: 'GeoDesignsFilterBar',
  components: {
    GlTabs,
    GlTab,
    GlFormInput,
    GlDropdown,
    GlDropdownItem,
    Icon,
  },
  data() {
    return {
      actionTypes: ACTION_TYPES,
    };
  },
  computed: {
    ...mapState(['currentFilterIndex', 'filterOptions', 'searchFilter']),
    search: {
      get() {
        return this.searchFilter;
      },
      set: _.debounce(function debounceSearch(newVal) {
        this.setSearch(newVal);
      }, 500),
    },
  },
  methods: {
    ...mapActions(['setFilter', 'setSearch', 'designsBatchAction']),
  },
};
</script>

<template>
  <gl-tabs :value="currentFilterIndex" @input="setFilter">
    <gl-tab
      v-for="(filter, index) in filterOptions"
      :key="index"
      :title="filter"
      title-item-class="text-capitalize"
    />
    <template v-slot:tabs-end>
      <div class="d-flex align-items-center ml-auto">
        <gl-form-input v-model="search" type="text" :placeholder="__(`Filter by name...`)" />
        <gl-dropdown class="ml-2">
          <template v-slot:button-content>
            <span>
              <icon name="cloud-gear" />
              {{ __('Batch operations') }}
              <icon name="chevron-down" />
            </span>
          </template>
          <gl-dropdown-item
            @click="designsBatchAction(actionTypes.RESYNC)"
          >{{ __('Resync all designs') }}</gl-dropdown-item>
        </gl-dropdown>
      </div>
    </template>
  </gl-tabs>
</template>
