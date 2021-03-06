<script>
import { GlFormGroup, GlFormInput, GlLink } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { __ } from '~/locale';
import { validateCapacity } from '../validations';
import { VALIDATION_FIELD_KEYS, REVERIFICATION_MORE_INFO, BACKFILL_MORE_INFO } from '../constants';

export default {
  name: 'GeoNodeFormCapacities',
  components: {
    GlFormGroup,
    GlFormInput,
    GlLink,
  },
  props: {
    nodeData: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      formGroups: [
        {
          id: 'node-repository-capacity-field',
          label: __('Repository sync capacity'),
          key: VALIDATION_FIELD_KEYS.REPOS_MAX_CAPACITY,
          conditional: 'secondary',
        },
        {
          id: 'node-file-capacity-field',
          label: __('File sync capacity'),
          key: VALIDATION_FIELD_KEYS.FILES_MAX_CAPACITY,
          conditional: 'secondary',
        },
        {
          id: 'node-container-repository-capacity-field',
          label: __('Container repositories sync capacity'),
          key: VALIDATION_FIELD_KEYS.CONTAINER_REPOSITORIES_MAX_CAPACITY,
          conditional: 'secondary',
        },
        {
          id: 'node-verification-capacity-field',
          label: __('Verification capacity'),
          key: VALIDATION_FIELD_KEYS.VERIFICATION_MAX_CAPACITY,
        },
        {
          id: 'node-reverification-interval-field',
          label: __('Re-verification interval'),
          description: __('Minimum interval in days'),
          key: VALIDATION_FIELD_KEYS.MINIMUM_REVERIFICATION_INTERVAL,
          conditional: 'primary',
        },
      ],
    };
  },
  computed: {
    ...mapState(['formErrors']),
    visibleFormGroups() {
      return this.formGroups.filter(group => {
        if (group.conditional) {
          return this.nodeData.primary
            ? group.conditional === 'primary'
            : group.conditional === 'secondary';
        }
        return true;
      });
    },
    sectionDescription() {
      return this.nodeData.primary
        ? __('Set the synchronization and verification capacity for the secondary node.')
        : __(
            'Set the number of concurrent requests this secondary node will make to the primary node while backfilling.',
          );
    },
    sectionLink() {
      return this.nodeData.primary ? REVERIFICATION_MORE_INFO : BACKFILL_MORE_INFO;
    },
  },
  methods: {
    ...mapActions(['setError']),
    checkCapacity(formGroup) {
      this.setError({
        key: formGroup.key,
        error: validateCapacity({ data: this.nodeData[formGroup.key], label: formGroup.label }),
      });
    },
  },
};
</script>

<template>
  <div>
    <h2 class="gl-font-size-h2 gl-my-5">{{ __('Performance and resource management') }}</h2>
    <p class="gl-mb-5">
      {{ sectionDescription }}
      <gl-link :href="sectionLink" target="_blank">{{ __('More information') }}</gl-link>
    </p>
    <gl-form-group
      v-for="formGroup in visibleFormGroups"
      :key="formGroup.id"
      :label="formGroup.label"
      :label-for="formGroup.id"
      :description="formGroup.description"
      :state="Boolean(formErrors[formGroup.key])"
      :invalid-feedback="formErrors[formGroup.key]"
    >
      <gl-form-input
        :id="formGroup.id"
        v-model="nodeData[formGroup.key]"
        :class="{ 'is-invalid': Boolean(formErrors[formGroup.key]) }"
        class="col-sm-3"
        type="number"
        @update="checkCapacity(formGroup)"
      />
    </gl-form-group>
  </div>
</template>
