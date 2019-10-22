<script>
export default {
  name: 'GeoDesignsApp',
  props: {
    /*
    store: {
      type: Object,
      required: true,
    },
    service: {
      type: Object,
      required: true,
    },
    */
  },
  data() {
    return {};
  },
  created() {
    console.log('hello');
  }
};
</script>

<template>
  <div class="geo-designs-container">
    <h1>{{ __("Hello World") }}</h1>
  </div>
</template>
