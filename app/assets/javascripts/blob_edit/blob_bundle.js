import $ from 'jquery';
import initNewCommitForm from '../new_commit_form';
import initEditBlob from './edit_blob';
import initBlobFileDropzone from '../blob/blob_file_dropzone';

export default () => {
  const editBlobForm = $('.js-edit-blob-form');
  const uploadBlobForm = $('.js-upload-blob-form');
  const deleteBlobForm = $('.js-delete-blob-form');

  if (editBlobForm.length) {
    const commitButton = $('.js-commit-button');
    const cancelLink = $('.btn.btn-cancel');

    cancelLink.on('click', () => {
      window.onbeforeunload = null;
    });

    commitButton.on('click', () => {
      window.onbeforeunload = null;
    });

    initEditBlob(editBlobForm);
    initNewCommitForm(editBlobForm);

    // returning here blocks page navigation
    window.onbeforeunload = () => '';
  }

  if (uploadBlobForm.length) {
    initBlobFileDropzone(uploadBlobForm);
    initNewCommitForm(uploadBlobForm);

    window.gl.utils.disableButtonIfEmptyField(
      uploadBlobForm.find('.js-commit-message'),
      '.btn-upload-file',
    );
  }

  if (deleteBlobForm.length) {
    initNewCommitForm(deleteBlobForm);
  }
};
