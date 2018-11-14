import * as description from './button.md';
import examples from './examples';

export default {
  description,
  examples,
  bootstrapComponent: 'b-button',
  bootstrapPropsInfo: {
    variant: {
      enum: 'buttonVariantOptions',
    },
  },
  events: [
    {
      event: 'click',
      description: 'Emitted when clicked on button',
    },
  ],
};
