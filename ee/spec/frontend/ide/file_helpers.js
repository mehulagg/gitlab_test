export const createFile = (path, content = '') => ({
  id: path,
  path,
  content,
  raw: content,
});

export const updateFile = (file, content) =>
  Object.assign(file, {
    content,
    changed: file.raw !== content,
  });

export const createNewFile = (path, content) =>
  Object.assign(createFile(path, content), {
    tempFile: true,
    raw: '',
  });

export const createDeletedFile = (path, content) =>
  Object.assign(createFile(path, content), {
    deleted: true,
  });

export const createUpdatedFile = (path, oldContent, content) =>
  updateFile(createFile(path, oldContent), content);

export const createMovedFile = (path, prevPath, content, newContent = null) => {
  const file = Object.assign(createFile(path, content), {
    prevPath,
  });

  return newContent ? updateFile(file, newContent) : file;
};

export const createEntries = path =>
  path.split('/').reduce((acc, part, idx, parts) => {
    const parentPath = parts.slice(0, idx).join('/');
    const fullPath = parentPath ? `${parentPath}/${part}` : part;

    return Object.assign(acc, { [fullPath]: { ...createFile(fullPath), parentPath } });
  }, {});
