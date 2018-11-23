import PopoverBasicExample from './popover.basic.example.vue';
import PopoverNoTitleExample from './popover.notitle.example.vue';
import PopoverLoadingExample from './popover.loading.example.vue';
import PopoverContentExample from './popover.content.example.vue';

export default [
  {
    name: 'Basic',
    items: [
      {
        id: 'popover-basic',
        name: 'Basic',
        description: 'Basic Popover',
        component: PopoverBasicExample,
      },
      {
        id: 'popover-notitle',
        name: 'No Title',
        description: 'Basic Popover without a title',
        component: PopoverNoTitleExample,
      },
    ],
  },
  {
    name: 'With other components',
    items: [
      {
        id: 'popover-content',
        name: 'Slot Content',
        description: 'Popover with HTML and Vue component inside the slot',
        component: PopoverContentExample,
      },
      {
        id: 'popover-loading',
        name: 'Loading',
        description: 'Popover with Skeleton Loading',
        component: PopoverLoadingExample,
      },
    ],
  },
];
