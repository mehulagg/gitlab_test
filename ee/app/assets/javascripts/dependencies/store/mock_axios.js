// TODO: remove mock-axios once the backend implementation is actually
// available

import _ from 'underscore';
import { REPORT_STATUS, PACKAGE_TYPES, SORT_ORDER } from './constants';

const perPage = 20;

function randomName() {
  const charCodeA = 'a'.charCodeAt(0);
  const charCodeZ = 'z'.charCodeAt(0);
  return Array(_.random(1, 5))
    .fill('')
    .map(() =>
      Array(_.random(1, 10))
        .fill('')
        .map(() => String.fromCharCode(_.random(charCodeA, charCodeZ)))
        .join(''),
    )
    .join('-');
}

function randomVersion() {
  return [_.random(1, 15), _.random(0, 15), _.random(0, 15)].join('.');
}

function random(list) {
  return list[Math.floor(Math.random() * list.length)];
}

// TODO: add location.path everywhere
function makeDependency() {
  return {
    name: randomName(),
    version: randomVersion(),
    type: random(Object.keys(PACKAGE_TYPES)),
    location: {
      blob_path: 'gitlab-org/gitlab-ee/blob/master/Gemfile.lock#L1248',
    },
  };
}

class PageHeaders {
  constructor(total = _.random(0, 3000)) {
    const totalPages = Math.ceil(total / perPage);
    this.headers = {
      'x-per-page': perPage,
      'x-page': 1,
      'x-total': total,
      'x-total-pages': totalPages,
      'x-next-page': 2,
      'x-prev-page': null,
    };
  }

  set page(value) {
    const totalPages = this.headers['x-total-pages'];
    this.headers['x-page'] = value;
    this.headers['x-next-page'] = value <= 1 ? null : value - 1;
    this.headers['x-prev-page'] = value >= totalPages ? null : value + 1;
  }

  copy() {
    return { ...this.headers };
  }
}

const pageInfoHeaders = new PageHeaders();

function wait(ms = 1000) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

window.mockDependencies = {
  state: '',
};

['jobNotSetUp', 'incomplete', 'jobFailed', 'error'].forEach(state => {
  window.mockDependencies[state] = () => {
    window.mockDependencies.state = state;
  };
});

export default {
  get(url, config) {
    if (window.mockDependencies.state === 'jobNotSetUp') {
      return this.doGet(url, config).then(res => {
        res.data.dependencies = [];
        res.data.report.status = REPORT_STATUS.jobNotSetUp;
        res.headers = new PageHeaders(0).copy();
        return res;
      });
    } else if (window.mockDependencies.state === 'incomplete') {
      return this.doGet(url, config).then(res => {
        res.data.report.status = REPORT_STATUS.incomplete;
        return res;
      });
    } else if (window.mockDependencies.state === 'jobFailed') {
      return this.doGet(url, config).then(res => {
        res.data.dependencies = [];
        res.data.report.status = REPORT_STATUS.jobFailed;
        res.headers = new PageHeaders(0).copy();
        return res;
      });
    } else if (window.mockDependencies.state === 'error') {
      return wait().then(() => {
        throw new Error('500 Some error');
      });
    }
    return this.doGet(url, config);
  },

  doGet(url, config) {
    // eslint-disable-next-line camelcase
    const { page, sort_by = 'name', sort } = config.params;
    pageInfoHeaders.page = page || 1;

    const dependencies = Array(perPage)
      .fill(null)
      .map(makeDependency);

    const sortedDependencies = _.sortBy(dependencies, sort_by);
    if (sort === SORT_ORDER.descending) sortedDependencies.reverse();

    const data = {
      dependencies: sortedDependencies,
      report: {
        status: '',
        job_path: '',
      },
    };

    return wait().then(() => ({ data, headers: pageInfoHeaders.copy() }));
  },
};
