<script>
import { GlButton, GlCard, GlFormGroup, GlDropdown, GlDropdownItem } from '@gitlab/ui';

const MODEL = {
  PROP: 'selectedProfileId',
  EVENT: 'set-profile',
};

export default {
  name: 'OnDemandScansProfileSelector',
  components: {
    GlButton,
    GlCard,
    GlFormGroup,
    GlDropdown,
    GlDropdownItem,
  },
  model: {
    prop: MODEL.PROP,
    event: MODEL.EVENT,
  },
  props: {
    libraryPath: {
      type: String,
      required: true,
    },
    newProfilePath: {
      type: String,
      required: true,
    },
    profiles: {
      type: Array,
      required: false,
      default: () => [],
    },
    selectedProfileId: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    selectedProfile() {
      return this.selectedProfileId
        ? this.profiles.find(({ id }) => this.selectedProfileId === id)
        : null;
    },
  },
  methods: {
    setProfile({ id }) {
      this.$emit(MODEL.EVENT, id);
    },
  },
};
</script>

<template>
  <gl-card>
    <template #header>
      <div class="row">
        <div class="col-7">
          <h3 class="gl-font-lg gl-display-inline">
            <slot name="title"></slot>
          </h3>
        </div>
        <div class="col-5 gl-text-right">
          <gl-button
            :href="profiles.length ? libraryPath : null"
            :disabled="!profiles.length"
            variant="success"
            category="secondary"
            size="small"
            data-testid="manage-profiles-link"
          >
            {{ s__('OnDemandScans|Manage profiles') }}
          </gl-button>
        </div>
      </div>
    </template>
    <gl-form-group v-if="profiles.length">
      <template #label>
        <slot name="label"></slot>
      </template>
      <gl-dropdown
        :text="
          selectedProfile
            ? selectedProfile.dropdownLabel
            : s__('OnDemandScans|Select one of the existing profiles')
        "
        class="mw-460"
        data-testid="profiles-dropdown"
      >
        <gl-dropdown-item
          v-for="profile in profiles"
          :key="profile.id"
          :is-checked="selectedProfileId === profile.id"
          is-check-item
          @click="setProfile(profile)"
        >
          {{ profile.profileName }}
        </gl-dropdown-item>
      </gl-dropdown>
      <div v-if="selectedProfile && $scopedSlots.summary" data-testid="selected-profile-summary">
        <hr />
        <slot name="summary" :profile="selectedProfile"></slot>
      </div>
    </gl-form-group>
    <template v-else>
      <p class="gl-text-gray-700">
        <slot name="no-profiles"></slot>
      </p>
      <gl-button
        :href="newProfilePath"
        variant="success"
        category="secondary"
        data-testid="create-profile-link"
      >
        <slot name="new-profile"></slot>
      </gl-button>
    </template>
  </gl-card>
</template>
