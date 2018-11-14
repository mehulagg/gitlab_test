import * as description from './modal.md';

export default {
  description,
  slots: [
    {
      name: 'modal-header',
      description:
        'Entire modal header container contents (including the close button on the top right corner)',
    },
    {
      name: 'modal-title',
      description: 'Modal title. If modal-header slot is used, this slot will not be shown.',
    },
    {
      name: 'modal-header-close',
      description:
        'Content of Modal header close button. If modal-header slot is used, this slot will not be shown.',
    },
    {
      name: 'modal-footer',
      description: 'Entire modal footer contents (including the default OK and CANCEL buttons)',
    },
    {
      name: 'modal-ok',
      description: 'Modal OK button content.',
    },
    {
      name: 'modal-cancel',
      description: 'Modal CANCEL button content.',
    },
  ],
};
