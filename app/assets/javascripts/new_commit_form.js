/* eslint-disable no-return-assign */

export default function initNewCommitForm(form) {
  const branchName = form.find('.js-branch-name');
  const originalBranch = form.find('.js-original-branch');
  const createMergeRequest = form.find('.js-create-merge-request');
  const createMergeRequestContainer = form.find('.js-create-merge-request-container');

  function renderDestination() {
    const different = branchName.val() !== originalBranch.val();
    let wasDifferent;

    if (different) {
      createMergeRequestContainer.show();
      if (!wasDifferent) {
        createMergeRequest.prop('checked', true);
      }
    } else {
      createMergeRequestContainer.hide();
      createMergeRequest.prop('checked', false);
    }
    return (wasDifferent = different);
  }

  renderDestination();
  branchName.keyup(renderDestination);
}
