<script>
import { GlIcon, GlDropdown, GlDropdownItem, GlLoadingIcon, GlTooltip, GlButton } from '@gitlab/ui';
import { s__ } from '~/locale';
import createFlash from '~/flash';
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
    GlButton,
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
    tooltipText() {
      let tooltipText = s__('AlertManagement|Alert severity');

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
          this.isUpdating = false;
        })
        .catch(() => {
          createFlash(
            s__(
              'AlertManagement|There was an error while updating the severity of the alert. Please try again.',
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
  <div class="block alert-severity">
    <div ref="severity" class="sidebar-collapsed-icon" @click="onClickCollapsedIcon">
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
      {{ tooltipText }}
    </gl-tooltip>

    <div class="hide-collapsed">
      <p class="title d-flex justify-content-between">
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

      <div
        class="dropdown dropdown-menu-selectable"
        :class="{ show: isDropdownShowing, 'd-none': !isDropdownShowing }"
      >
        <gl-dropdown
          ref="dropdown"
          :text="$options.severityLabels[alert.severity]"
          class="w-100"
          @keydown.esc.native="hideDropdown"
          @hide="hideDropdown"
        >
          <div class="dropdown-title">
            <span class="health-title">{{ s__('AlertManagement|Assign alert severity') }}</span>
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
              v-for="(label, field) in $options.severityLabels"
              :key="field"
              data-testid="severityDropdownItem"
              class="gl-vertical-align-middle"
              @click="updateAlertSeverity(label)"
            >
              <span class="d-flex">
                <gl-icon
                  class="flex-shrink-0 append-right-4"
                  :class="{ invisible: label.toUpperCase() !== alert.severity }"
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
        :class="{ 'no-value': !$options.severityLabels[alert.severity] }"
      >
        <span v-if="$options.severityLabels[alert.severity]" class="text-plain"
          ><severity-icon :severity="alert.severity"
        /></span>
        <span v-else>
          {{ s__('AlertManagement|None') }}
        </span>
      </p>
    </div>
  </div>
</template>
