<script>
export default {
  data: () => ({ text: 'This text is two-way bound. Nice.' }),
};
</script>

<template>
<div>
  <gl-form-textarea
    v-model="text"
    placeholder="Enter something"
    :rows="3"
    :max-rows="6"
  />
  <pre>{{ text }}</pre>
  </div>
</template>
