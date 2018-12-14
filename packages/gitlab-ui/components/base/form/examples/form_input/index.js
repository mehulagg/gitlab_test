import FormInputTextExample from './form_input.text.example.vue';
import FormInputTextReactiveExample from './form_input.text_reactive.example.vue';
import FormInputTextDisabledExample from './form_input.text_disabled.example.vue';

export default [
  {
    name: 'Text Input',
    items: [
      {
        id: 'input-text',
        name: 'default state',
        component: FormInputTextExample,
      },
      {
        id: 'input-text-reactive',
        name: 'with reactive binding',
        component: FormInputTextReactiveExample,
      },
      {
        id: 'input-text-disabled',
        name: 'disabled state',
        component: FormInputTextDisabledExample,
      },
    ],
  },
];
