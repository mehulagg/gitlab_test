<script>
import { getIdenticonBackgroundClass, getIdenticonTitle } from '~/helpers/avatar_helper';
import gqHelpers from '~/helpers/graphql_helper';

export default {
  props: {
    entityId: {
      type: Number,
      required: true,
    },
    entityName: {
      type: String,
      required: true,
    },
    sizeClass: {
      type: String,
      required: false,
      default: 's40',
    },
    isGQL: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  computed: {
    identiconBackgroundClass() {
      const id = this.isGQL ? gqHelpers.convertId(this.entityId) : this.entityId;
      return getIdenticonBackgroundClass(id);
    },
    identiconTitle() {
      return getIdenticonTitle(this.entityName);
    },
  },
};
</script>

<template>
  <div ref="identicon" :class="[sizeClass, identiconBackgroundClass]" class="avatar identicon">
    {{ identiconTitle }}
  </div>
</template>
