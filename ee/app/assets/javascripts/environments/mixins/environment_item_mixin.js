export default {
  props: {
    deployIconName() {
      return this.model.isDeployBoardVisible ? 'chevron-down' : 'chevron-right';
    },
    shouldRenderDeployBoard() {
      return this.model.hasDeployBoard;
    },
  },
  methods: {
    toggleDeployBoard() {
      eventHub.$emit('toggleDeployBoard', this.model);
    },
  },
};
