<script>
export default {
  props: {
    error: {
      type: String,
      required: true,
    },
    chartName: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    summary: {
      type: String,
      required: true,
    },
  },
};
</script>
<template>
  <div class="row empty-state">
    <div class="col-12">
      <div class="text-content">
        <h4 class="content-title">{{ title }}</h4>
        <h4 class="content-title text-center">{{ chartName }}</h4>
        <p class="content-summary">{{ summary }}</p>
        <p class="content-summary">{{ error }}</p>
      </div>
    </div>
  </div>
</template>
