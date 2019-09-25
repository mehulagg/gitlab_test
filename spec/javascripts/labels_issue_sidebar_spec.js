/* eslint-disable no-new */

import $ from 'jquery';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import IssuableContext from '~/issuable_context';
import LabelsSelect from '~/labels_select';
import _ from 'underscore';

import '~/gl_dropdown';
import 'select2';
import '~/api';
import '~/create_label';
import '~/users_select';

let saveLabelCount = 0;
let mock;

function testLabelSelections(opts) {
  saveLabelCount = opts.labelCount;
  console.log(saveLabelCount)
  return function(done) {
    $('.edit-link')
      .get(0)
      .click();

    setTimeout(() => {
      console.log(saveLabelCount)
      const labelsInDropdown = $('.dropdown-content a');

      expect(labelsInDropdown.length).toBe(10);

      const arrayOfLabels = labelsInDropdown.get();
      const randomArrayOfLabels = _.shuffle(arrayOfLabels);
      randomArrayOfLabels.forEach((label, i) => {
        if (i < opts.labelCount) {
          $(label).click();
        }
      });

      $('.edit-link')
        .get(0)
        .click();

      setTimeout(() => {
        expect($('.sidebar-collapsed-icon').attr('data-original-title')).toBe(opts.labelOrder);
        done();
      }, 0);
    }, 0);
  };
}

describe('Issue dropdown sidebar', () => {
  preloadFixtures('static/issue_sidebar_label.html');

  beforeEach(() => {
    loadFixtures('static/issue_sidebar_label.html');

    mock = new MockAdapter(axios);

    new IssuableContext('{"id":1,"name":"Administrator","username":"root"}');
    new LabelsSelect();

    mock.onGet('/root/test/labels.json').reply(() => {
      const labels = Array(10)
        .fill()
        .map((_val, i) => ({
          id: i,
          title: `test ${i}`,
          color: '#5CB85C',
        }));

      return [200, labels];
    });

    mock.onPut('/root/test/issues/2.json').reply(() => {
      const labels = Array(saveLabelCount)
        .fill()
        .map((_val, i) => ({
          id: i,
          title: `test ${i}`,
          color: '#5CB85C',
        }));

      return [200, { labels }];
    });
  });

  afterEach(() => {
    mock.restore();
  });

  const fewerThanFive = testLabelSelections({
    labelCount: 5,
    labelOrder: 'test 0, test 1, test 2, test 3, test 4',
  })

  it('changes collapsed tooltip when changing labels when fewer than 5', fewerThanFive);

  const greaterThanFive = testLabelSelections({
    labelCount: 6,
    labelOrder: 'test 0, test 1, test 2, test 3, test 4, and 1 more',
  })

  it('changes collapsed tooltip when changing labels when greater than 5', greaterThanFive);
})
