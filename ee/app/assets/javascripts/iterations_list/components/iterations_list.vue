<script>
import { GlLoadingIcon, GlPagination } from '@gitlab/ui';

export default {
  PREV_PAGE: 1,
  NEXT_PAGE: 2,
  components: {
    GlLoadingIcon,
    GlPagination,
  },
  props: {
    iterations: {
      type: Array,
      required: false,
      default: () => [],
    },
    loading: {
      type: Number,
      required: false,
      default: 0,
    },
    pageInfo: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      page: 0,
    };
  },
  methods: {
    goToPage(page) {
      this.page = page;
    },
  },
};
</script>

<template>
  <div class="milestones">
    <div v-if="loading">
      <gl-loading-icon size="lg" />
    </div>
    <template v-else-if="iterations.length > 0">
      <ul class="content-list">
        <li v-for="iteration in iterations" :key="iteration.id" class="milestone milestone-open">
          <a :href="iteration.webPath"
            ><strong>{{ iteration.title }}</strong></a
          >
          <p class="text-secondary">{{ iteration.startDate }} - {{ iteration.dueDate }}</p>
        </li>
      </ul>
      <div v-if="false" class="mt-3">
        <gl-pagination
          v-show="!loading"
          :value="page"
          :per-page="20"
          :prev-page="$options.PREV_PAGE"
          :next-page="$options.NEXT_PAGE"
          class="justify-content-center"
          @input="goToPage"
        />
      </div>
    </template>
    <div v-else class="nothing-here-block">
      {{ __('No iterations to show') }}
    </div>
  </div>
</template>
