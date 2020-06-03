<script>
import { numberToHumanSize } from '~/lib/utils/number_utils';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    Icon,
  },
  props: {
    name: {
      type: String,
      required: true,
    },
    value: {
      type: Number,
      required: true,
    },
    icon: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
  },
  computed: {
    formattedValue() {
      return numberToHumanSize(this.value);
    },
  },
};
</script>
<template>
  <div class="gl-responsive-table-row gl-pl-2" role="row">
    <div
      class="table-section section-wrap section-70 text-truncate gl-pl-3 d-flex align-items-center"
      role="gridcell"
    >
      <icon :name="icon" />
      <div class="ml-3">
        <div class="table-mobile-content gl-font-weight-bold gl-text-gray-900">{{ name }}</div>
        <div class="table-mobile-content">{{ description }}</div>
      </div>
    </div>

    <div class="table-section section-wrap section-30 text-truncate" role="gridcell">
      <div class="table-mobile-content d-flex align-items-center">
        <icon name="disk" class="gl-mr-2" />
        {{ formattedValue }}
      </div>
    </div>
  </div>
</template>
