import * as description from './pagination.md';
import examples from './examples';

export default {
  description,
  examples,
  bootstrapComponent: 'b-pagination',
  propsInfo: {
    limits: {
      additionalInfo: 'The object must contain the xs, sm, md and default keys',
    },
  },
};
