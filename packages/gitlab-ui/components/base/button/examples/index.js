import ButtonBasicExample from './button.basic.example.vue';
import ButtonLinkExample from './button.link.example.vue';
import ButtonVariantsExample from './button.variants.example.vue';
import ButtonSizesExample from './button.sizes.example.vue';

export default [
  {
    name: 'Basic',
    items: [
      {
        id: 'button-basic',
        name: 'Basic',
        description: 'Basic Button',
        component: ButtonBasicExample,
      },
      {
        id: 'button-link',
        name: 'Button Link',
        description: 'Button with a link',
        component: ButtonLinkExample,
      },
    ],
  },
  {
    name: 'Styling',
    items: [
      {
        id: 'button-variants',
        name: 'Variants',
        description: 'Different button variants',
        component: ButtonVariantsExample,
      },
      {
        id: 'button-sizes',
        name: 'Button Sizes',
        description: 'Different button sizes',
        component: ButtonSizesExample,
      },
    ],
  },
];
