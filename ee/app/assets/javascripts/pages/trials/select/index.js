import $ from 'jquery';

document.addEventListener('DOMContentLoaded', () => {
  const namespaceId = $('#namespace_id');
  const newGroupName = $('#new_group_name');

  namespaceId.on('change', () => {
    const enableNewGroupName = namespaceId.val() === '0';

    newGroupName
      .toggleClass('hidden', !enableNewGroupName)
      .find('input')
      .prop('required', enableNewGroupName);
  });

  namespaceId.trigger('change');
});
