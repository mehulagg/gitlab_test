import { findAllByText, findByLabelText, fireEvent, screen } from '@testing-library/dom';

const isFileRowOpen = row => row.matches('.is-open');

const getLeftSidebar = async () => screen.getByTestId('left-sidebar');

const clickOnLeftSidebarTab = async name => {
  const sidebar = await getLeftSidebar();

  const button = await findByLabelText(sidebar, name);

  button.click();
};

const findMonacoEditorTextarea = async () => screen.findByLabelText(/Editor content;/);

const findMonacoEditor = async () => (await findMonacoEditorTextarea()).closest('.monaco-editor');

const setEditorValue = async value => {
  const editor = await findMonacoEditor();
  const uri = editor.getAttribute('data-uri');

  window.monaco.editor.getModel(uri).setValue(value);
};

const findTreeBody = async () => screen.findByTestId('ide-tree-body', {}, { timeout: 5000 });

const findFileRowContainer = async (row = null) => (row ? row.parentElement : findTreeBody());

const findFileChild = async (row, name, index = 0) => {
  const container = await findFileRowContainer(row);

  return (await findAllByText(container, name, { selector: '.file-row-name' }))
    .map(x => x.closest('.file-row'))
    .find(x => x.dataset.level === index.toString());
};

const openFileRow = async row => {
  if (!row || isFileRowOpen(row)) {
    return;
  }

  row.click();
};

const traverseToPath = async (path, index = 0, row = null) => {
  if (!path) {
    return row;
  }

  const [name, ...restOfPath] = path.split('/');

  await openFileRow(row);

  const child = await findFileChild(row, name, index);

  return traverseToPath(restOfPath.join('/'), index + 1, child);
};

const clickFileRowAction = async (row, name) => {
  fireEvent.mouseOver(row);

  const dropdownButton = await findByLabelText(row, 'Create new file or directory');
  dropdownButton.click();

  const dropdownAction = await findByLabelText(dropdownButton.parentNode, name);
  dropdownAction.click();
};

const fillInFileNameModal = async value => {
  const nameField = await screen.findByTestId('file-name-field');
  fireEvent.input(nameField, { target: { value } });

  const createButton = await screen.findByText('Create file');
  createButton.click();
};

export const createFile = async (path, content) => {
  const parentPath = path
    .split('/')
    .slice(0, -1)
    .join('/');

  const parentRow = await traverseToPath(parentPath);
  await clickFileRowAction(parentRow, 'New file');

  await fillInFileNameModal(path);
  await setEditorValue(content);
};

export const deleteFile = async path => {
  const row = await traverseToPath(path);
  await clickFileRowAction(row, 'Delete');
};

export const commit = async () => {
  await clickOnLeftSidebarTab('Commit');
  (await screen.findByTestId('begin-commit-button')).click();
  (await screen.findByLabelText(/Commit to .+ branch/)).click();
  (await screen.findByText('Commit')).click();
};
