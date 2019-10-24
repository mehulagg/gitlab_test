import _ from 'underscore';

export * from '@gitlab/ui';

/**
 * Most unit tests expect the GlTooltipDirective to add a
 * data-original-title attribute when the directive is bound
 * and remove the original title attribute.
 *
 * This GlTooltipDirective stub provides this behavior for backwards
 * compatibility. The GlTooltipDirective is based on bootstrap-vue
 * Tooltip directive. As of bootstrap-vue 2.0.4, the tooltip directive
 * does not provide that behavior anymore.
 */
export const GlTooltipDirective = {
  bind(el) {
    el.setAttribute('data-original-title', el.getAttribute('title'));
    el.setAttribute('title', '');
  },
};

export const GlTooltip = {
  props: {
    target: {
      type: [Object, Function],
      required: true,
    },
  },
  render(h) {
    return h('div');
  },
  mounted() {
    const target = this.getTarget();

    target.dataset.originalTitle = target.title;
  },
  methods: {
    getTarget() {
      const { target } = this;

      return _.isFunction(target) ? target() : target;
    },
  },
};
