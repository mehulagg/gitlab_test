<script>
  import { GlTabs, GlTab, GlFormInput, GlDropdown, GlDropdownItem } from '@gitlab/ui'
  import Icon from '~/vue_shared/components/icon.vue';
  import { __ } from '~/locale';

  export default {
    name: 'GeoDesignsFilterBar',
    components: {
      GlTabs,
      GlTab,
      GlFormInput,
      GlDropdown,
      GlDropdownItem,
      Icon
    },
    data() {
      return {
        tabs: [__('All'), __('Synced'), __('Pending'), __("Failed"), __('Never')],
        currentTab: 0
      }
    },
  }
</script>

<template>
  <gl-tabs v-model="currentTab">
    <gl-tab v-for="(tab, index) in tabs" :key="index" :title="tab"/>
    <template v-slot:tabs-end>
      <div class="d-flex align-items-center ml-auto">
        <gl-form-input type="text" :placeholder="__(`Filter by name...`)" />
        <gl-dropdown class="ml-2">
          <template v-slot:button-content>
            <span><icon name="cloud-gear" /> {{ __("Batch operations") }} <icon name="chevron-down" /></span>
          </template>
          <gl-dropdown-item>{{ __("Resync all designs") }}</gl-dropdown-item>
          <gl-dropdown-item>{{ __("Reverify all designs") }}</gl-dropdown-item>
        </gl-dropdown>
      </div>
    </template>
  </gl-tabs>
</template>