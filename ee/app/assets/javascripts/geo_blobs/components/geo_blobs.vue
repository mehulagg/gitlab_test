<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { __ } from '~/locale';
// import query from '../graphql/blobs.query.graphql';
import GeoBlobRegistry from './geo_blob_registry.vue';
import mockGeoBlobs from '../graphql/blobs.query.graphql.mock';

export default {
  name: 'GeoBlobs',
  components: {
    GlDropdown,
    GlDropdownItem,
    GeoBlobRegistry,
  },
  /*
    apollo: {
      blobs: {
        query
      },
    },
    */
  data() {
    return {
      blobs: null,
      selectedBlob: null,
    };
  },
  computed: {
    dropdownTitle() {
      if (!this.blobs) {
        return __('Loading ...');
      } else if (!this.selectedBlob) {
        return __('Select Blob');
      }

      return this.selectedBlob.name;
    },
  },
  // ******************************
  // This to be replaced by apollo
  created() {
    this.blobs = mockGeoBlobs;
  },
  // ******************************
};
</script>

<template>
  <section>
    <header class="m-3">
      <label for="dropdown">{{ __('Blobs:') }}</label>
      <gl-dropdown :text="dropdownTitle">
        <gl-dropdown-item v-for="blob in blobs.nodes" :key="blob.id" @click="selectedBlob = blob">{{
          blob.name
        }}</gl-dropdown-item>
      </gl-dropdown>
      <geo-blob-registry v-if="selectedBlob" :blob="selectedBlob" />
    </header>
  </section>
</template>

<style lang="scss" scoped></style>
