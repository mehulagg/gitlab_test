import FormGroupBasicExample from './form_group.basic.example.vue';
import FormGroupValidationExample from './form_group.validation.example.vue';

export default [
  {
    name: 'Form Group',
    items: [
      {
        id: 'form-group',
        name: 'basic example',
        component: FormGroupBasicExample,
      },
      {
        id: 'form-group-validations',
        name: 'with validations',
        component: FormGroupValidationExample,
      },
    ],
  },
];
