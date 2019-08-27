import { mapGetters, mapActions } from 'vuex';

export default {
  computed: {
    ...mapGetters(['clickedIndex']),
  },
  props: {
    visible: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      requestInFlight: false,
      isAlertDismissed: false,
      errorMessage: '',
    };
  },
  watch: {
    visible(isVisible) {
      if (isVisible) {
        this.show();
      } else {
        this.hide();
      }
    },
  },
  methods: {
    ...mapActions(['updateIndices']),
    beforeShow() {
      // just an API marker. Should be overridden by a component where needed
    },
    beforeHide() {
      // just an API marker. Should be overridden by a component where needed
    },
    show() {
      this.beforeShow();
      this.$refs.modal.show();
    },
    hide() {
      this.beforeHide();
      this.$refs.modal.hide();
    },
  },
};
