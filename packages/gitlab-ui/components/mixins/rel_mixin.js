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
      default: null,
    },
  },
  computed: {
    relType() {
      if (this.target === '_blank' && this.hostname !== window.location.hostname) {
        return this.secureRel;
      }

      return this.$attrs.rel;
    },
    hostname() {
      const anchor = document.createElement('a');
      anchor.href = this.$attrs.href;

      return anchor.hostname;
    },
    secureRel() {
      return `${this.$attrs.rel || ''} noopener noreferrer`.trim();
    },
  },
};
