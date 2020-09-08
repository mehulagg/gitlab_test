<script>
import { GlButton, GlCard, GlFormGroup, GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { s__ } from '~/locale';

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
    prop: 'initialSelection',
    event: 'set-profile',
  },
  props: {
    settings: {
      type: Object,
      required: true,
    },
    profiles: {
      type: Array,
      required: false,
      default: () => [],
    },
    initialSelection: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      selectedProfileId: this.initialSelection,
    };
  },
  computed: {
    selectedProfile() {
      return this.selectedProfileId
        ? this.profiles.find(({ id }) => this.selectedProfileId === id)
        : null;
    },
    profileText() {
      return this.selectedProfile
        ? this.settings.selectedProfileDropdownLabel(this.selectedProfile)
        : s__('OnDemandScans|Select one of the existing profiles');
    },
  },
  methods: {
    setProfile({ id }) {
      this.selectedProfileId = id;
      this.$emit('set-profile', id);
    },
  },
};
</script>

<template>
  <gl-card>
    <template #header>
      <div class="row">
        <div class="col-7">
          <h3 class="gl-font-lg gl-display-inline">{{ settings.i18n.title }}</h3>
        </div>
        <div class="col-5 gl-text-right">
          <gl-button
            :href="profiles.length ? settings.libraryPath : null"
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
        {{ settings.i18n.formGroupLabel }}
      </template>
      <gl-dropdown
        v-model="selectedProfileId"
        :text="profileText"
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
      <footer
        v-if="selectedProfileId && settings.summary.length > 0"
        data-testid="selected-profile-summary"
      >
        <hr />
        <div
          v-for="(row, rowIndex) in settings.summary"
          :key="`summaryRow_${rowIndex}`"
          class="row"
        >
          <div
            v-for="([label, getter], cellIndex) in row"
            :key="`cell_${rowIndex}_${cellIndex}`"
            class="col-md-6"
          >
            <div class="row">
              <div class="col-md-3">{{ label }}:</div>
              <div class="col-md-9 gl-font-weight-bold">
                {{ getter(selectedProfile) }}
              </div>
            </div>
          </div>
        </div>
      </footer>
    </gl-form-group>
    <template v-else>
      <p class="gl-text-gray-700">
        {{ settings.i18n.noProfilesText }}
      </p>
      <gl-button
        :href="settings.newProfilePath"
        variant="success"
        category="secondary"
        data-testid="create-profile-link"
      >
        {{ settings.i18n.newProfileLabel }}
      </gl-button>
    </template>
  </gl-card>
</template>
