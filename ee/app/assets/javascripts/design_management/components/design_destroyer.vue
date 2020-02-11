<script>
import { ApolloMutation } from 'vue-apollo';
import projectQuery from '../graphql/queries/project.query.graphql';
import destroyDesignMutation from '../graphql/mutations/destroyDesign.mutation.graphql';
import allDesignsMixin from '../mixins/all_designs';
import { updateStoreAfterDesignsDelete } from '../utils/cache_update';
import { DESIGNS_PAGE_SIZE } from '../utils/design_management_utils';

export default {
  components: {
    ApolloMutation,
  },
  mixins: [allDesignsMixin],
  props: {
    filenames: {
      type: Array,
      required: true,
    },
  },
  computed: {
    projectQueryBody() {
      return {
        query: projectQuery,
        variables: {
          fullPath: this.projectPath,
          iid: this.issueIid,
          atVersion: null,
          first: DESIGNS_PAGE_SIZE,
        },
      };
    },
    refetchDesigns() {
      return this.designs.length <= DESIGNS_PAGE_SIZE ? [this.projectQueryBody] : [];
    },
  },
  methods: {
    updateStoreAfterDelete(
      store,
      {
        data: { designManagementDelete },
      },
    ) {
      updateStoreAfterDesignsDelete(
        store,
        designManagementDelete,
        this.projectQueryBody,
        this.filenames,
      );
    },
  },
  destroyDesignMutation,
};
</script>

<template>
  <apollo-mutation
    v-slot="{ mutate, loading, error }"
    :mutation="$options.destroyDesignMutation"
    :variables="{
      filenames,
      projectPath,
      iid: issueIid,
    }"
    :update="updateStoreAfterDelete"
    :refetch-queries="() => refetchDesigns"
    v-on="$listeners"
  >
    <slot v-bind="{ mutate, loading, error }"></slot>
  </apollo-mutation>
</template>
