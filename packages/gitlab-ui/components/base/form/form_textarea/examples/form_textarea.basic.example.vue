<script>
export default {
  // We need this because without a v-model this input will reset on every keystroke
  // https://github.com/bootstrap-vue/bootstrap-vue/issues/1915
  data: () => ({ text: '' }),
};
</script>

<template>
  <gl-form-textarea
    v-model="text"
    placeholder="Enter something"
   />
</template>
