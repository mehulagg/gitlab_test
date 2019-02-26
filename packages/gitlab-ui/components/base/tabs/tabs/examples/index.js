import BasicTabsExample from './tabs.basic.example.vue';
import DisabledTabExample from './tabs.disabled.example.vue';
import CustomTitleExample from './tabs.custom_title.example.vue';

export default [
  {
    name: 'Basic',
    items: [
      {
        id: 'tabs-basic',
        name: 'Basic',
        description: 'Basic Tabs',
        component: BasicTabsExample,
      },
      {
        id: 'tabs-disabled',
        name: 'Disabled',
        description: 'Disabled Tab',
        component: DisabledTabExample,
      },
      {
        id: 'tabs-custom-title',
        name: 'Custom Title',
        description: 'Custom Title Tab',
        component: CustomTitleExample,
      },
    ],
  },
];
