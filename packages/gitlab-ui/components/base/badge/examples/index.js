import BadgeBasicExample from './badge.basic.example.vue';
import BadgeVariantsExample from './badge.variants.example.vue';
import BadgeScalingExample from './badge.scaling.example.vue';
import BadgeActionableExample from './badge.action.example.vue';
import BadgeButtonExample from './badge.button.example.vue';

export default [
  {
    name: 'Basic',
    items: [
      {
        id: 'badge-basic',
        name: 'Basic',
        description: 'Basic Badge',
        component: BadgeBasicExample,
      },
      {
        id: 'badge-variants',
        name: 'Variants',
        description: 'Different Badge Variants',
        component: BadgeVariantsExample,
      },
      {
        id: 'badge-scaling',
        name: 'Scaling',
        description: 'Automatic Scaling of Badges',
        component: BadgeScalingExample,
      },
      {
        id: 'badge-actions',
        name: 'Actionable',
        description: 'Badges with Actions',
        component: BadgeActionableExample,
      },
      {
        id: 'badge-button',
        name: 'Inside Button',
        description: 'Show Badge inside Button',
        component: BadgeButtonExample,
      },
    ],
  },
];
