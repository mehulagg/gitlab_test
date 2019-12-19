<script>
import { ApolloMutation } from 'vue-apollo';
import projectQuery from '../graphql/queries/project.query.graphql';
import destroyDesignMutation from '../graphql/mutations/destroyDesign.mutation.graphql';
import updateCache from '../graphql/cache';
import { transformDesignDeletion, transformNewVersion } from '../graphql/cache/transforms';

export default {
  components: {
    ApolloMutation,
  },
  props: {
    filenames: {
      type: Array,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
    iid: {
      type: String,
      required: true,
    },
  },
  computed: {
    projectQueryBody() {
      return {
        query: projectQuery,
        variables: { fullPath: this.projectPath, iid: this.iid, atVersion: null },
      };
    },
  },
  methods: {
    updateStoreAfterDelete(
      store,
      {
        data: { designManagementDelete },
      },
    ) {
      updateCache(store, this.filenames, this.projectQueryBody, transformDesignDeletion);
      updateCache(
        store,
        designManagementDelete.version,
        this.projectQueryBody,
        transformNewVersion,
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
      iid,
    }"
    :update="updateStoreAfterDelete"
    v-on="$listeners"
  >
    <slot v-bind="{ mutate, loading, error }"></slot>
  </apollo-mutation>
</template>
