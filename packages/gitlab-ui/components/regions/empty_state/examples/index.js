import EmptyStateBasicExample from './empty_state.basic.example.vue';
import EmptyStatePrimaryButtonExample from './empty_state.primary_button.example.vue';
import EmptyStateMultipleButtonExample from './empty_state.multiple_button.example.vue';
import EmptyStateNoIllustrationExample from './empty_state.no_illustration.example.vue';

export default [
  {
    name: 'Basic',
    items: [
      {
        id: 'empty-state-basic',
        name: 'Basic',
        description: 'Basic Empty State',
        component: EmptyStateBasicExample,
      },
      {
        id: 'empty-state-primary-button',
        name: 'Primary Button',
        description: 'Empty State With Primary Button',
        component: EmptyStatePrimaryButtonExample,
      },
      {
        id: 'empty-state-multiple-buttons',
        name: 'Multiple Buttons',
        description: 'Empty State With Multiple Buttons',
        component: EmptyStateMultipleButtonExample,
      },
      {
        id: 'empty-state-no-illustration',
        name: 'No Illustration',
        description: 'Empty State With No Illustration',
        component: EmptyStateNoIllustrationExample,
      },
    ],
  },
];
