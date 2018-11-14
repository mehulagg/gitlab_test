import * as description from './skeleton_loading.md';
import examples from './examples';

export default {
  description,
  examples,
  propsInfo: {
    lines: {
      validation: {
        type: 'range',
        min: 1,
        max: 3,
      },
    },
  },
};
