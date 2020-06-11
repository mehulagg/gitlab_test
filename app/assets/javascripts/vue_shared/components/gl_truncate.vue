<script>
export default {
  props: {
    text: {
      type: String,
      required: true,
    },
  },
  computed: {
    first() {
      const middleIndex = Math.floor(this.text.length / 2);
      return this.text.slice(0, middleIndex);
    },
    last() {
      const middleIndex = Math.floor(this.text.length / 2);
      return this.text.slice(middleIndex);
    },
  },
};
</script>

<template>
  <span class="gl-truncate"
    ><span class="gl-truncate-start">{{ first }}</span
    ><span class="gl-truncate-end">{{ last }}</span></span
  >
</template>

<style>
.gl-truncate {
  display: inline-flex;
  max-width: 100%;
}

.gl-truncate-start,
.gl-truncate-end {
  flex: 0 1 auto;
  white-space: nowrap;
  overflow: hidden;
}

.gl-truncate-start {
  text-overflow: ellipsis;
}

.gl-truncate-end {
  direction: rtl;
  text-align: left;
  text-overflow: '';
}
</style>
