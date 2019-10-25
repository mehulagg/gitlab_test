<script>
import Icon from '~/vue_shared/components/icon.vue';
import { mapState } from 'vuex';

export default {
  name: 'GeoDesignStatus',
  components: {
    Icon,
  },
  props: {
    status: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      iconName: '',
      iconClass: '',
    };
  },
  computed: {
    ...mapState(['filterStates']),
  },
  created() {
    this.iconProperties(this.status);
  },
  methods: {
    iconProperties(status) {
      switch (status) {
        case this.filterStates.SYNCED:
          this.iconName = 'status_closed';
          this.iconClass = 'text-success';
          break;

        case this.filterStates.PENDING:
          this.iconName = 'status_scheduled';
          this.iconClass = 'text-warning';
          break;

        case this.filterStates.FAILED:
          this.iconName = 'status_failed';
          this.iconClass = 'text-danger';
          break;

        default:
          this.iconName = 'status_notfound';
          this.iconClass = 'text-muted';
      }
    },
  },
};
</script>

<template>
  <div>
    <span class="d-flex align-items-center text-capitalize">
      <icon :name="iconName" :class="iconClass" class="mr-2" />
      {{ status || 'never' }}
    </span>
  </div>
</template>
