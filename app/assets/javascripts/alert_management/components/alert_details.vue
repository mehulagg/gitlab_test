<script>
import { GlNewDropdown, GlNewDropdownItem, GlTabs, GlTab } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  statuses: {
    triggered: s__('AlertManagement|Triggered'),
    acknowledged: s__('AlertManagement|Acknowledged'),
    ignored: s__('AlertManagement|Ignored'),
  },
  components: {
    GlNewDropdown,
    GlNewDropdownItem,
    GlTab,
    GlTabs,
  },
};
</script>
<template>
  <div>
    <div class="d-flex justify-content-between mt-3">
      <div class="align-self-center">
        <gl-new-dropdown right>
          <gl-new-dropdown-item
            v-for="(label, field) in $options.statuses"
            :key="field"
            class="align-middle"
            >{{ label }}
          </gl-new-dropdown-item>
        </gl-new-dropdown>
      </div>
    </div>
    <div class="d-flex justify-content-between">
      <gl-tabs>
        <gl-tab title="Overview">
          <ul class="pl-3">
            <li class="font-weight-bold mb-3 mt-2">
              {{ s__('AlertManagement|Start time:') }}
            </li>
            <li class="font-weight-bold my-3">
              {{ s__('AlertManagement|End time:') }}
            </li>
            <li class="font-weight-bold my-3">
              {{ s__('AlertManagement|Events:') }}
            </li>
          </ul>
        </gl-tab>
        <gl-tab title="Full Detail Alerts" />
      </gl-tabs>
    </div>
  </div>
</template>
