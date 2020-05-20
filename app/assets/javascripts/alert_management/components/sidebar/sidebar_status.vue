<script>
import { GlIcon, GlDropdown, GlDropdownItem, GlLoadingIcon, GlTooltip, GlButton } from '@gitlab/ui';
import { s__ } from '~/locale';
import createFlash from '~/flash';
import updateAlertStatus from '../../graphql/mutations/update_alert_status.graphql';

export default {
  statuses: {
    TRIGGERED: s__('AlertManagement|Triggered'),
    ACKNOWLEDGED: s__('AlertManagement|Acknowledged'),
    RESOLVED: s__('AlertManagement|Resolved'),
  },
  components: {
    GlIcon,
    GlDropdown,
    GlDropdownItem,
    GlLoadingIcon,
    GlTooltip,
    GlButton,
  },
  props: {
    projectPath: {
      type: String,
      required: true,
    },
    alert: {
      type: Object,
      required: true,
    },
    isEditable: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  data() {
    return {
      isDropdownShowing: false,
      isUpdating: false,
    };
  },
  computed: {
    tooltipText() {
      let tooltipText = s__('AlertManagement|Alert status');

      if (this.status) {
        tooltipText += `: ${this.statusText}`;
      }

      return tooltipText;
    },
  },
  methods: {
    hideDropdown() {
      this.isDropdownShowing = false;
    },
    toggleFormDropdown() {
      this.isDropdownShowing = !this.isDropdownShowing;
      const { dropdown } = this.$refs.dropdown.$refs;
      if (dropdown && this.isDropdownShowing) {
        dropdown.show();
      }
    },
    isSelected(status) {
      return this.status === status;
    },
    updateAlertStatus(status) {
      this.isUpdating = true;
      this.$apollo
        .mutate({
          mutation: updateAlertStatus,
          variables: {
            iid: this.alert.iid,
            status: status.toUpperCase(),
            projectPath: this.projectPath,
          },
        })
        .then(() => {
          this.hideDropdown();
          this.isUpdating = false;
        })
        .catch(() => {
          createFlash(
            s__(
              'AlertManagement|There was an error while updating the status of the alert. Please try again.',
            ),
          );
          this.isUpdating = false;
        });
    },
    onClickCollapsedIcon() {
      this.$emit('toggle-sidebar');
    },
  },
};
</script>

<template>
  <div class="block alert-status">
    <div ref="status" class="sidebar-collapsed-icon" @click="onClickCollapsedIcon">
      <gl-icon name="severity-critical" :size="14" />

      <gl-loading-icon v-if="isUpdating" />
      <p v-else class="collapse-truncated-title px-1">{{ $options.statuses[alert.status] }}</p>
    </div>
    <gl-tooltip :target="() => $refs.status" boundary="viewport" placement="left">
      {{ tooltipText }}
    </gl-tooltip>

    <div class="hide-collapsed">
      <p class="title d-flex justify-content-between">
        {{ s__('AlertManagement|Status') }}
        <a
          v-if="isEditable"
          ref="editButton"
          class="btn-link"
          href="#"
          @click="toggleFormDropdown"
          @keydown.esc="hideDropdown"
        >
          {{ s__('AlertManagement|Edit') }}
        </a>
      </p>

      <div
        class="dropdown dropdown-menu-selectable"
        :class="{ show: isDropdownShowing, 'd-none': !isDropdownShowing }"
      >
        <gl-dropdown
          ref="dropdown"
          :text="$options.statuses[alert.status]"
          class="w-100"
          @keydown.esc.native="hideDropdown"
          @hide="hideDropdown"
        >
          <div class="dropdown-title">
            <span class="alert-title">{{ s__('AlertManagement|Assign alert status') }}</span>
            <gl-button
              :aria-label="__('Close')"
              variant="link"
              class="dropdown-title-button dropdown-menu-close"
              icon="close"
              @click="hideDropdown"
            />
          </div>
          <div class="dropdown-content dropdown-body">
            <gl-dropdown-item
              v-for="(label, field) in $options.statuses"
              :key="field"
              data-testid="statusDropdownItem"
              class="gl-vertical-align-middle"
              @click="updateAlertStatus(label)"
            >
              <span class="d-flex">
                <gl-icon
                  class="flex-shrink-0 append-right-4"
                  :class="{ invisible: label.toUpperCase() !== alert.status }"
                  name="mobile-issue-close"
                />
                {{ label }}
              </span>
            </gl-dropdown-item>
          </div>
        </gl-dropdown>
      </div>

      <gl-loading-icon v-if="isUpdating" :inline="true" />
      <p
        v-else-if="!isDropdownShowing"
        class="value m-0"
        :class="{ 'no-value': !$options.statuses[alert.status] }"
      >
        <span v-if="$options.statuses[alert.status]" class="text-plain">{{
          $options.statuses[alert.status]
        }}</span>
        <span v-else>
          {{ s__('AlertManagement|None') }}
        </span>
      </p>
    </div>
  </div>
</template>
