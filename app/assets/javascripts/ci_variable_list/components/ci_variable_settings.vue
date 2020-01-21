<script>
import CiVariableModal from './ci_variable_modal.vue';
import CiVariableTable from './ci_variable_table.vue';
import { mapActions } from 'vuex';

export default {
  components: {
    CiVariableModal,
    CiVariableTable,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    projectId: {
      type: String,
      required: true,
    },
    isGroup: {
      type: Boolean,
      required: true,
    },
  },
  created() {
    this.setEndpoint(this.endpoint);
    this.setProjectId(this.projectId);
    this.setIsGroup(this.isGroup);
  },
  mounted() {
    if (!this.isGroup) {
      this.fetchEnvironments();
    }
  },
  methods: {
    ...mapActions(['setEndpoint', 'setProjectId', 'fetchEnvironments', 'setIsGroup']),
  },
};
</script>

<template>
  <div class="row">
    <div class="col-lg-12">
      <ci-variable-table />
      <ci-variable-modal />
    </div>
  </div>
</template>
