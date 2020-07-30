<script>
import { mapActions } from 'vuex';

export default {
  methods: {
    ...mapActions(['openDrawer'])
  }
};

</script>

<template>
  <li>
    <a href="javascript:void(0);" @click="openDrawer">See what's new at GitLab</a>
  </li>
</template>
