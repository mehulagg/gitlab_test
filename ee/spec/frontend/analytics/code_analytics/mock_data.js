export const DEFAULT_FILE_QUANTITY = 100;

export const group = {
  id: 1,
  name: 'foo',
  path: 'foo',
  avatar_url: 'host/images/group/image.svg',
};

export const project = {
  id: 1,
  name: 'bar',
  path: 'bar',
  avatar_url: 'host/images/project/image.svg',
};

export const endpoint = '/endpoint';

export const codeHotspotsResponseData = [
  {
    id: 1,
    name: 'README.md',
    count: 5,
  },
  {
    id: 2,
    name: 'index.js',
    count: 7,
  },
  {
    id: 3,
    name: 'style.css',
    count: 2,
  },
];

export const codeHotspotsTransformedData = [
  {
    id: 1,
    name: 'README.md',
    count: 5,
    value: 5,
    link: `/${group.path}/${project.path}/blob/master/README.md`,
  },
  {
    id: 2,
    name: 'index.js',
    count: 7,
    value: 7,
    link: `/${group.path}/${project.path}/blob/master/index.js`,
  },
  {
    id: 3,
    name: 'style.css',
    count: 2,
    value: 2,
    link: `/${group.path}/${project.path}/blob/master/style.css`,
  },
];

export const endDate = new Date('2019-10-21T13:40:11.138Z');
export const startDate = new Date('2019-09-21T13:40:11.138Z');
