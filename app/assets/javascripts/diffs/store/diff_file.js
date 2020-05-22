// https://gitlab.com/gitlab-org/frontend/rfcs/-/issues/20
/* eslint-disable import/prefer-default-export */

const SHA1_REGEX = /^[a-f0-9]{40}$/i;
// Testers are quick checks to see if we can focus on a single matcher right away, ordered by preference
const testers = [
  {
    type: 'sha1',
    test: id => SHA1_REGEX.test(id),
  },
  {
    type: 'any',
    test: () => true,
  },
];
// Matchers are all the ways we know how to identify a Diff File, with `any` as a fallback
const matchers = {
  path: function matchesPath(file, path) {
    return file.file_path === path;
  },
  sha1: function matchesSha(file, sha1) {
    return file.file_hash === sha1;
  },
  any: function matchesAnyIdentifier(file, identifier) {
    return matchers.sha1(file, identifier) || matchers.path(file, identifier);
  },
};

function getIdentifierFilter(identifier) {
  const { type } = testers.find(definition => definition.test(identifier));
  const check = matchers[type];

  return file => check(file, identifier);
}

export function getByIdentifier({ identifier, diffFiles }) {
  return diffFiles.find(getIdentifierFilter(identifier));
}
