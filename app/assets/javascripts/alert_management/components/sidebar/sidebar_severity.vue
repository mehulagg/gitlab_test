<script>
import {
  GlIcon,
  GlDropdown,
  GlDropdownItem,
  GlLoadingIcon,
  GlTooltip,
  GlSprintf,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import { ALERTS_SEVERITY_LABELS } from '../../constants';
import updateAlertSeverity from '../../graphql/mutations/update_alert_severity.graphql';
import SeverityIcon from '../severity/severity_icon.vue';

export default {
  severityLabels: ALERTS_SEVERITY_LABELS,
  components: {
    GlIcon,
    GlDropdown,
    GlDropdownItem,
    GlLoadingIcon,
    GlTooltip,
    GlSprintf,
    SeverityIcon,
  },
  props: {
    alert: {
      type: Object,
      required: true,
    },
    isEditable: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      isDropdownShowing: false,
      isUpdating: false,
    };
  },
  computed: {
    dropdownClass() {
      return this.isDropdownShowing ? 'show' : 'd-none';
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
    isSelected(severity) {
      return this.severity === severity;
    },
    updateAlertSeverity(severity) {
      this.isUpdating = true;
      this.$apollo
        .mutate({
          mutation: updateAlertSeverity,
          variables: {
            iid: this.alert.iid,
            severity: severity.toUpperCase(),
            projectPath: this.projectPath,
          },
        })
        .then(() => {
          this.hideDropdown();
        })
        .catch(() => {
          this.$emit(
            'alert-sidebar-error',
            s__(
              'AlertManagement|There was an error while updating the severity of the alert. Please try again.',
            ),
          );
        })
        .finally(() => {
          this.isUpdating = false;
        });
    },
  },
};
</script>

<template>
  <div class="block alert-severity">
    <div ref="severity" class="sidebar-collapsed-icon" @click="$emit('toggle-sidebar')">
      <gl-icon
        :size="14"
        :name="`severity-${alert.severity.toLowerCase()}`"
        :class="`icon-${alert.severity.toLowerCase()}`"
      />

      <gl-loading-icon v-if="isUpdating" />
      <p v-else class="collapse-truncated-title px-1">
        {{ $options.severityLabels[alert.severity] }}
      </p>
    </div>
    <gl-tooltip :target="() => $refs.severity" boundary="viewport" placement="left">
      <gl-sprintf :message="s__('AlertManagement|Alert severity: %{severity}')">
        <template #severity>
          {{ alert.severity.toLowerCase() }}
        </template>
      </gl-sprintf>
    </gl-tooltip>

    <div class="hide-collapsed">
      <p class="title gl-display-flex justify-content-between">
        {{ s__('AlertManagement|Severity') }}
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

      <div class="dropdown dropdown-menu-selectable" :class="dropdownClass">
        <gl-dropdown
          ref="dropdown"
          :text="$options.severityLabels[alert.severity]"
          class="w-100"
          toggle-class="dropdown-menu-toggle"
          variant="outline-default"
          @keydown.esc.native="hideDropdown"
          @hide="hideDropdown"
        >
          <div class="dropdown-title">
            <span class="severity-title">{{ s__('AlertManagement|Assign severity') }}</span>
            <button
              class="dropdown-title-button dropdown-menu-close"
              :aria-label="__('Close')"
              type="button"
              @click="hideDropdown"
            >
              <i aria-hidden="true" class="fa fa-times dropdown-menu-close-icon"> </i>
            </button>
          </div>
          <div class="dropdown-content dropdown-body">
            <gl-dropdown-item
              v-for="(label, field) in $options.severityLabels"
              :key="field"
              data-testid="severityDropdownItem"
              class="gl-vertical-align-middle"
              :active="label.toUpperCase() === alert.severity"
              :active-class="'is-active'"
              @click="updateAlertSeverity(label)"
            >
              {{ label }}
            </gl-dropdown-item>
          </div>
        </gl-dropdown>
      </div>

      <gl-loading-icon v-if="isUpdating" :inline="true" />
      <p
        v-else-if="!isDropdownShowing"
        class="value m-0"
        :class="{ 'no-value': !$options.severityLabels[alert.severity] }"
      >
        <span v-if="$options.severityLabels[alert.severity]" class="gl-text-gray-700"
          ><severity-icon :severity="alert.severity"
        /></span>
        <span v-else>
          {{ s__('AlertManagement|None') }}
        </span>
      </p>
    </div>
  </div>
</template>
