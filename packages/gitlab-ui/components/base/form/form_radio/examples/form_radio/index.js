import FormRadioGroupBasicExample from './form_radio_group.basic.example.vue';
import FormRadioGroupButtonExample from './form_radio_group.button.example.vue';

export default [
  {
    name: 'Form Radio',
    items: [
      {
        id: 'form-group-radio',
        name: 'Form radio group with code',
        component: FormRadioGroupBasicExample,
      },
      {
        id: 'form-radio-group-buttons',
        name: 'Form radio group with buttons',
        component: FormRadioGroupButtonExample,
      },
    ],
  },
];
