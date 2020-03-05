/* global ace */

import $ from 'jquery';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import { __ } from '~/locale';
import TemplateSelectorMediator from '../blob/file_template_mediator';
import getModeByFileExtension from '~/lib/utils/ace_utils';
import { addEditorMarkdownListeners } from '~/lib/utils/text_markdown';

function configureAceEditor(options) {
  const { filePath, assetsPath, isMarkdown } = options;
  ace.config.set('modePath', `${assetsPath}/ace`);
  ace.config.loadModule('ace/ext/searchbox');
  ace.config.loadModule('ace/ext/modelist');

  const editor = ace.edit('editor');

  if (isMarkdown) {
    addEditorMarkdownListeners(editor);
  }

  // This prevents warnings re: automatic scrolling being logged
  editor.$blockScrolling = Infinity;

  editor.focus();

  if (filePath) {
    editor.getSession().setMode(getModeByFileExtension(filePath));
  }

  return editor;
}

function editModeLinkClickHandler(editor, e) {
  e.preventDefault();

  const editModePanes = $('.js-edit-mode-pane');
  const editModeLinks = $('.js-edit-mode a');

  const currentLink = $(e.target);
  const paneId = currentLink.attr('href');
  const currentPane = editModePanes.filter(paneId);
  const toggleButton = $('.soft-wrap-toggle');

  editModeLinks.parent().removeClass('active hover');

  currentLink.parent().addClass('active hover');

  editModePanes.hide();

  currentPane.fadeIn(200);

  if (paneId === '#preview') {
    toggleButton.hide();
    axios
      .post(currentLink.data('previewUrl'), {
        content: editor.getValue(),
      })
      .then(({ data }) => {
        currentPane.empty().append(data);
        currentPane.renderGFM();
      })
      .catch(() => createFlash(__('An error occurred previewing the blob')));
  }

  toggleButton.show();

  return editor.focus();
}


function initModePanesAndLinks(editor) {
  const editModeLinks = $('.js-edit-mode a');

  editModeLinks.on('click', e => editModeLinkClickHandler(editor, e));
}

function toggleSoftWrap(toggleButton, editor, isSoftWrapped) {
  toggleButton.toggleClass('soft-wrap-active', !isSoftWrapped);
  editor.getSession().setUseWrapMode(!isSoftWrapped);
}

function initSoftWrap(editor) {
  const toggleButton = $('.soft-wrap-toggle');
  const isSoftWrapped = toggleButton.hasClass('soft-wrap-active');

  toggleButton.on('click', () => toggleSoftWrap(toggleButton, editor, isSoftWrapped));
}

function initFileSelectors(editor, options) {
  const { currentAction, projectId } = options;

  const templateSelectorMediator = new TemplateSelectorMediator({
    currentAction,
    editor,
    projectId,
  });

  templateSelectorMediator.initTemplateSelectorMediators();
}

export default function initEditBlob(editBlobForm) {
  const urlRoot = editBlobForm.data('relativeUrlRoot');
  const assetsPrefix = editBlobForm.data('assetsPrefix');
  const assetsPath = `${urlRoot}${assetsPrefix}`;
  const filePath = `${editBlobForm.data('blobFilename')}`;
  const currentAction = $('.js-file-title').data('currentAction');
  const projectId = editBlobForm.data('project-id');
  const isMarkdown = editBlobForm.data('is-markdown');

  const editBlobOptions = {
    assetsPath,
    filePath,
    currentAction,
    projectId,
    isMarkdown,
  };

  const editor = configureAceEditor(editBlobOptions);

  initModePanesAndLinks(editor);
  initSoftWrap(editor, editBlobOptions);
  initFileSelectors(editor, editBlobOptions);
}
