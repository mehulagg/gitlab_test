export default {
  computed: {
    durationInWords: () => {},
  },
  methods: {
    buildConnnectorClass(index) {
      return index === 0 && !this.isFirstColumn ? 'left-connector' : '';
    },
    groupDurationInWords: () => {},
  },
};
