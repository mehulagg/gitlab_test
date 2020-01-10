<script>
export default {
  props: {
    crumbs: {
      type: Array,
      required: true,
    },
  },
  computed: {
    rootRoute() {
      return this.$router.options.routes[0];
    },
    isRootRoute() {
      return this.$route.name === this.rootRoute.name;
    },
    rootCrumbs() {
      return this.crumbs.slice(0, -1);
    },
    divider() {
      const { classList, tagName, innerHTML } = this.crumbs[0].querySelector('svg');
      return { classList: [...classList], tagName, innerHTML };
    },
    lastCrumb() {
      const { tagName, className } = this.crumbs[this.crumbs.length - 1].children[0];
      return { tagName, className, text: this.$route.meta.name, path: { to: this.$route.name } };
    },
  },
};
</script>

<template>
  <ul>
    <li v-for="(crumb, index) in rootCrumbs" :key="index" v-html="crumb.innerHTML"></li>
    <li v-if="!isRootRoute">
      <router-link :to="rootRoute.path">{{ rootRoute.meta.name }}</router-link>
      <component :is="divider.tagName" :class="divider.classList" v-html="divider.innerHTML" />
    </li>
    <li>
      <component :is="lastCrumb.tagName" :class="lastCrumb.className">
        <router-link :to="lastCrumb.path">{{ lastCrumb.text }}</router-link>
      </component>
    </li>
  </ul>
</template>
