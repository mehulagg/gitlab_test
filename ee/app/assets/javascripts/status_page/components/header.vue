<script>
  import GlLink from '@gitlab/ui/dist/components/base/link/link';

  export default {
    components: {
      GlLink,
    }
  }
</script>

<template>

  <header class="header d-flex justify-content-between">
    <div class="d-inline-flex align-items-center">
      <img src="./../assets/images/gitlab-logo.png" class="tanuki-logo"/>
      <span class="d-inline logo-text">GitLab</span>
    </div>

    <!--
          <gl-link>Contact support</gl-link>
    -->

  </header>
</template>

<style scoped lang="scss">
  .header {
    padding: 0 16px;
    z-index: 1000;
    margin-bottom: 0;
    height: 40px;
    border: 0;
    border-bottom: 1px solid $border-color;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    background-color: $indigo;
    margin-bottom: 64px;

    .tanuki-logo {
      height: 40px;
    }

    .logo-text {
      color: $white-light;
      font-size: 20px;
    }
  }
</style>
