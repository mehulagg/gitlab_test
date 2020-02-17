<script>
import GlHeader from './../components/header.vue';

export default {
  components: {
    GlHeader,
  },
};
</script>

<template>
  <div class="position-relative">
    <transition name="slide">
      <div>
        <gl-header/>
        <router-view/>
      </div>
    </transition>
  </div>
</template>
