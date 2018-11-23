import examples from './examples';

export default {
  examples,
  bootstrapComponent: 'b-popover',
  bootstrapPropsInfo: {
    target: {
      additionalInfo:
        'Element string ID, or a reference to an element or component, that you want to trigger the popover.',
      required: true,
    },
    triggers: {
      enum: 'triggerVariantOptions',
    },
    placement: {
      enum: 'popoverPlacements',
    },
    boundary: {
      additionalInfo:
        '"scrollParent", "viewport", "window", or a reference to an HTML element. This is the container that the popover will be constrained to visually.You may need to change this if your target element is in a small container with overflow scroll',
    },
    container: {
      additionalInfo:
        'Specify container as null (default, appends to <body>) to avoid rendering problems in more complex components (like input groups, button groups, etc). You can use container to optionally specify a different element to append the popover to.',
    },
  },
};
