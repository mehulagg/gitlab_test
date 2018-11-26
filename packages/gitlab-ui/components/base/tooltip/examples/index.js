import TooltipDirectiveDefaultExample from './tooltip.directive_default.example.vue';
import TooltipDirectiveRightExample from './tooltip.directive_right.example.vue';
import TooltipDirectiveBottomExample from './tooltip.directive_bottom.example.vue';
import TooltipDirectiveLeftExample from './tooltip.directive_left.example.vue';

import TooltipComponentDefaultExample from './tooltip.component_default.example.vue';

export default [
  {
    name: 'Directive',
    items: [
      {
        id: 'tooltip-directive',
        name: 'Default',
        description: 'Default Tooltip Directive Use Case',
        component: TooltipDirectiveDefaultExample,
      },
      {
        id: 'tooltip-directive-right',
        name: 'To the right',
        description: 'Directive Tooltip to the right',
        component: TooltipDirectiveRightExample,
      },
      {
        id: 'tooltip-directive-bottom',
        name: 'To the bottom',
        description: 'Directive Tooltip to the bottom',
        component: TooltipDirectiveBottomExample,
      },
      {
        id: 'tooltip-directive-left',
        name: 'To the left',
        description: 'Directive Tooltip to the left',
        component: TooltipDirectiveLeftExample,
      },
    ],
  },
  {
    name: 'Component',
    items: [
      {
        id: 'tooltip-default',
        name: 'HTML',
        description: 'Default Tooltip Component Use Case',
        component: TooltipComponentDefaultExample,
      },
    ],
  },
];
