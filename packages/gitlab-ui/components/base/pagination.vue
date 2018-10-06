<script>
import BPagination from "bootstrap-vue/es/components/pagination/pagination";
import Breakpoints, { breakpoints } from "../../helpers/breakpoints.js";

export default {
  components: {
    BPagination
  },
  props: {
    change: {
      type: Function,
      required: true,
    },
    page: {
      type: Number,
      required: true,
    },
    perPage: {
      type: Number,
      required: true,
    },
    totalItems: {
      type: Number,
      required: true,
    },
    limits: {
      type: Object,
      require: false,
      default: () => ({
        xs: 1,
        sm: 3,
        md: 5,
        default: 11,
      }),
      validator: value => {
        const missingSizes = Object.keys(breakpoints)
          .filter(size => !value.hasOwnProperty(size))
          .length;

        return missingSizes === 0
          ? true
          : value.hasOwnProperty('default');
      },
    },
  },
  data() {
    return {
      breakpoint: Breakpoints.getBreakpointSize(),
      currentPage: this.page,
    };
  },
  computed: {
    hideGotoEndButtons() {
      const totalPages = Math.ceil(this.totalItems / this.perPage);

      return totalPages < this.paginationLimit;
    },
    paginationLimit() {
      return this.limits[this.breakpoint] || this.limits.default;
    },
    shouldRenderPagination() {
      return this.page && this.totalItems > this.perPage;
    },
  },
  watch: {
    currentPage: 'change',
    page(pageNumber) {
      this.currentPage = pageNumber;
    },
  },
  created() {
    window.addEventListener('resize', this.setBreakpoint);
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.setBreakpoint);
  },
  methods: {
    setBreakpoint() {
      this.breakpoint = Breakpoints.getBreakpointSize();
    }
  },
};
</script>

<template>
  <b-pagination
    v-if="shouldRenderPagination"
    v-model="currentPage"
    v-bind="$attrs"
    :limit="paginationLimit"
    :per-page="perPage"
    :total-rows="totalItems"
    :hide-goto-end-buttons="hideGotoEndButtons"
    class="gl-pagination"
  />
</template>
