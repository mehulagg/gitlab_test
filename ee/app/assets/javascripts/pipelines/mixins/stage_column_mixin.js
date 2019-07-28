import { timeIntervalInWords } from '~/lib/utils/datetime_utility';

export default {
  props: {
    duration: {
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
  computed: {
    durationInWords() {
      return timeIntervalInWords(this.duration);
    },
  },
  methods: {
    groupDurationInWords(group) {
      return timeIntervalInWords(group.duration);
    },
    buildConnnectorClass(index) {
      return index === 0 && (!this.isFirstColumn || this.hasTriggeredBy) ? 'left-connector' : '';
    },
  },
};
