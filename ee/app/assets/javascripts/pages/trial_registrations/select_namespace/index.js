import $ from 'jquery';

document.addEventListener('DOMContentLoaded', () => {
  const namespaceId = $('#namespace_id');
  const newGroupName = $('#new_group');

  namespaceId.on('change', () => {
    newGroupName.toggleClass('hidden', $(this).val() === '1');
  });
});
