<script>
import { GlButton, GlDropdown, GlDropdownItem, GlTabs, GlTab } from '@gitlab/ui';
import { __ } from '~/locale';

const mock = require('./alerts.json');

export default {
  statuses: {
    triggered: __('Triggered'),
    acknowledged: __('Acknowledged'),
    ignored: __('Ignored'),
  },
  components: {
    GlButton,
    GlDropdown,
    GlDropdownItem,
    GlTab,
    GlTabs,
  },
  data() {
    return {
      alertDetails: mock.alerts,
    };
  },
};
</script>
<template>
  <div>
    <div class="d-flex justify-content-between mt-4">
      <h5>Reported {{ alertDetails[0].startedAt }}</h5>
      <gl-button category="primary" variant="success">{{ __("Create Issue") }}</gl-button>
    </div>
    <hr />
    <h1>{{ alertDetails[0].title }}</h1>
    <div class="d-flex justify-content-between">
      <div>
        <gl-tabs>
          <gl-tab title="Overview">
            <ul>
              <li>{{ __("Start time:") }}</li>
              <li>{{ __("End time:") }}</li>
              <li>{{ __("Events:") }}</li>
            </ul>
          </gl-tab>
          <gl-tab title="Full Detail Alerts">
            <ul>
              <li>{{ __("description:") }}</li>
            </ul>
          </gl-tab>
        </gl-tabs>
      </div>
      <div>
        <gl-dropdown :text="alertDetails[0].status">
          <gl-dropdown-item
            v-for="(label, field) in $options.statuses"
            :key="field"
            class="align-middle"
            >{{ label }}
          </gl-dropdown-item>
        </gl-dropdown>
      </div>
    </div>
  </div>
</template>
