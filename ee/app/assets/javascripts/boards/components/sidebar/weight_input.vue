<script>
import BoardSidebarItem from './board_sidebar_item.vue';
import { GlButton, GlFormInput } from '@gitlab/ui';

export default {
  components: { BoardSidebarItem, GlButton, GlFormInput },
  data() {
    return {
      weight: 0,
      loading: false,
    };
  },
  methods: {
    setWeight(weigth) {
      if (weigth !== undefined) {
        this.weight = weigth;
      }

      this.loading = true;
      setTimeout(() => {
        this.loading = false;
      }, 1000);
    },
  },
};
</script>

<template>
  <board-sidebar-item
    :title="__('Weight')"
    :loading="loading"
    :can-update="true"
    @closed="setWeight()"
  >
    <template #collapsed>
      <div v-if="weight" class="gl-display-flex gl-align-items-center">
        <strong class="gl-text-gray-900">{{ weight }}</strong>
        <span class="gl-mx-2">-</span>
        <gl-button variant="link" class="gl-text-gray-400!" @click="setWeight(0)">
          {{ __('remove weight') }}
        </gl-button>
      </div>
    </template>
    <template>
      <gl-form-input v-model="weight" type="number" :placeholder="__('Enter a number')" />
    </template>
  </board-sidebar-item>
</template>
