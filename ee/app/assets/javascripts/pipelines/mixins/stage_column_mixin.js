export default {
  props: {
    duration: {
      type: Number,
      required: false,
      default: null,
    },
    pipelineDuration: {
      type: Number,
      required: false,
      default: null,
    },
    hasTriggeredBy: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    buildConnnectorClass(index) {
      return index === 0 && (!this.isFirstColumn || this.hasTriggeredBy) ? 'left-connector' : '';
    },
  },
};
