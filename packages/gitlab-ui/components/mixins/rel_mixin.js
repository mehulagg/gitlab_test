/**
 * Mixin that handles the rel attribute/property for _blank targets
 * adds the "noopener noreferrer" to the rel attribute if the target has the aforementioned value
 * and if the target or rel haven't been set before
*/

export default {
  props: {
    target: {
      type: String,
      required: false,
      default: null
    }
  },
  computed: {
    relType() {
      if (this.$attrs.rel && this.$attrs.rel.length > 0) return this.$attrs.rel;

      return this.target === "_blank" ? "noopener noreferrer" : "";
    }
  }
};
