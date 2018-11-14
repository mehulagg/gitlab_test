import * as description from './loading_icon.md';

export default {
  description,
  propsInfo: {
    size: {
      validation: {
        type: 'range',
        min: 1,
        max: 5,
      },
    },
  },
};
