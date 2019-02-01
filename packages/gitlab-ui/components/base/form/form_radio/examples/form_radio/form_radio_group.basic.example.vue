<script>
export default {
  data() {
    return {
      selected: 'pizza',
      options: [{ text: 'Pizza', value: 'pizza' }, { text: 'Tacos', value: 'tacos' }],
    };
  },
};
</script>

<template>
  <gl-form-radio-group v-model="selected" :options="options" />
</template>
