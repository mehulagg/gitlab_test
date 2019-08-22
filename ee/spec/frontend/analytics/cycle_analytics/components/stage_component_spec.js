import { shallowMount, mount } from '@vue/test-utils';
import Stage from 'ee/analytics/cycle_analytics/components/stage.vue';
import StageCode from 'ee/analytics/cycle_analytics/components/stage_code.vue';
import StageReview from 'ee/analytics/cycle_analytics/components/stage_review.vue';
import StageTest from 'ee/analytics/cycle_analytics/components/stage_test.vue';
import StageStaging from 'ee/analytics/cycle_analytics/components/stage_staging.vue';

import {
  issueStage as stage,
  issueItems,
  planItems,
  reviewItems,
  testItems,
  stagingItems,
  productionItems,
  codeItems,
} from '../mock_data';

let wrapper = null;

function createComponent(props = {}, shallow = true, Component = Stage) {
  const func = shallow ? shallowMount : mount;
  return func(Component, {
    propsData: {
      stage,
      items: issueItems,
      ...props,
    },
  });
}

const $sel = {
  item: '.stage-event-item',
  description: '.events-description',
  title: '.item-title',
  issueLink: '.issue-link',
  mrLink: '.mr-link',
  date: '.issue-date',
  author: '.issue-author-link',
  time: '.item-time',
  commit: '.commit-sha',
  branch: '.ref-name',
  mrBranch: '.merge-request-branch',
  pipeline: '.pipeline-id',
  build: '.item-build-name',
};

function renderStageEvent(elem, item) {
  expect(elem.find($sel.title).text()).toEqual(item.title);
  if (elem.find($sel.mrLink).exists()) {
    expect(elem.find($sel.mrLink).text()).toEqual(`!${item.iid}`);
  } else {
    expect(elem.find($sel.issueLink).text()).toEqual(`#${item.iid}`);
  }
  expect(elem.find($sel.date).text()).toEqual(item.createdAt);
  expect(elem.find($sel.author).text()).toEqual(item.author.name);
  expect(elem.find($sel.author).attributes('href')).toEqual(item.author.webUrl);
}

function renderTotalTime(element, totalTime) {
  // lol: so gross
  const { days = null, hours = null, mins = null, seconds = null } = totalTime;
  if (days) {
    expect(element.find($sel.time).text()).toContain(days);
  } else if (hours) {
    expect(element.find($sel.time).text()).toContain(hours);
  } else if (mins) {
    expect(element.find($sel.time).text()).toContain(mins);
  } else {
    expect(element.find($sel.time).text()).toContain(seconds);
  }
}

describe('Stage', () => {
  describe('Default stages', () => {
    describe.skip('With too many events', () => {
      beforeEach(() => {
        wrapper = createComponent({ items: [issueItems] }, false);
      });

      afterEach(() => {
        wrapper.destroy();
      });
      it('will render the limit warning', () => {});
    });

    describe('Issue stage', () => {
      beforeEach(() => {
        wrapper = createComponent({ items: issueItems }, false);
      });

      afterEach(() => {
        wrapper.destroy();
      });
      it('will render the event description', () => {
        expect(wrapper.find($sel.description).text()).toEqual(stage.description);
      });

      it('will render the list of items', () => {
        issueItems.forEach((item, index) => {
          const elem = wrapper.findAll($sel.item).at(index);
          renderStageEvent(elem, item);
          renderTotalTime(elem, item.totalTime);
        });
      });
    });

    describe('Plan stage', () => {
      beforeEach(() => {
        wrapper = createComponent({ items: planItems }, false);
      });

      afterEach(() => {
        wrapper.destroy();
      });
      it('will render the event description', () => {
        expect(wrapper.find($sel.description).text()).toEqual(stage.description);
      });
      it('will render the list of items', () => {
        planItems.forEach((item, index) => {
          const elem = wrapper.findAll($sel.item).at(index);
          renderStageEvent(elem, item);
          renderTotalTime(elem, item.totalTime);
        });
      });
    });

    describe('Review stage', () => {
      beforeEach(() => {
        wrapper = createComponent({ items: reviewItems }, false, StageReview);
      });

      afterEach(() => {
        wrapper.destroy();
      });
      it('will render the event description', () => {
        expect(wrapper.find($sel.description).text()).toEqual(stage.description);
      });
      it('will render the list of items', () => {
        reviewItems.forEach((item, index) => {
          const elem = wrapper.findAll($sel.item).at(index);
          if (item.state === 'closed') {
            expect(elem.find('.merge-request-state').text()).toBe(item.state.toUpperCase());
          }
          if (item.branch) {
            expect(elem.find($sel.mrBranch).text()).toBe(item.branch.name);
          }
          renderStageEvent(elem, item);
          renderTotalTime(elem, item.totalTime);
        });
      });
    });

    describe('Code stage', () => {
      beforeEach(() => {
        wrapper = createComponent({ items: codeItems }, false, StageCode);
      });

      afterEach(() => {
        wrapper.destroy();
      });
      it('will render the event description', () => {
        expect(wrapper.find($sel.description).text()).toEqual(stage.description);
      });
      it('will render the list of items', () => {
        codeItems.forEach((item, index) => {
          const elem = wrapper.findAll($sel.item).at(index);
          renderStageEvent(elem, item);
          renderTotalTime(elem, item.totalTime);
        });
      });
    });

    describe('Test stage', () => {
      beforeEach(() => {
        wrapper = createComponent({ items: testItems }, false, StageTest);
      });

      afterEach(() => {
        wrapper.destroy();
      });
      it('will render the event description', () => {
        expect(wrapper.find($sel.description).text()).toEqual(stage.description);
      });
      it('will render the list of items', () => {
        testItems.forEach((item, index) => {
          const elem = wrapper.findAll($sel.item).at(index);
          expect(elem.find('.icon-build-status').exists()).toBe(true);
          expect(elem.find('.icon-branch').exists()).toBe(true);
          expect(elem.find($sel.commit).text()).toEqual(item.shortSha);
          expect(elem.find($sel.branch).text()).toEqual(item.branch.name);
          expect(elem.find($sel.pipeline).text()).toEqual(`#${item.id}`);
          expect(elem.find($sel.build).text()).toEqual(item.name);
          renderStageEvent(elem, item);
          renderTotalTime(elem, item.totalTime);
        });
      });
    });

    describe('Staging stage', () => {
      beforeEach(() => {
        wrapper = createComponent({ items: stagingItems }, false, StageStaging);
      });

      afterEach(() => {
        wrapper.destroy();
      });
      it('will render the event description', () => {
        stagingItems.forEach(item => {
          expect(wrapper.find($sel.description).text()).toEqual(item.description);
        });
      });
      it('will render the list of items', () => {
        stagingItems.forEach((item, index) => {
          const elem = wrapper.findAll($sel.item).at(index);
          expect(elem.find('.icon-branch').exists()).toBe(true);
          expect(elem.find($sel.commit).text()).toEqual(item.shortSha);
          expect(elem.find($sel.branch).text()).toEqual(item.branch.name);
          expect(elem.find($sel.pipeline).text()).toEqual(`#${item.id}`);
          renderStageEvent(elem, item);
          renderTotalTime(elem, item.totalTime);
        });
      });
    });

    describe('Production stage', () => {
      beforeEach(() => {
        wrapper = createComponent({ items: productionItems }, false);
      });

      afterEach(() => {
        wrapper.destroy();
      });
      it('will render the event description', () => {
        expect(wrapper.find($sel.description).text()).toEqual(stage.description);
      });
      it('will render the list of items', () => {
        productionItems.forEach((item, index) => {
          const elem = wrapper.findAll($sel.item).at(index);
          renderStageEvent(elem, item);
          renderTotalTime(elem, item.totalTime);
        });
      });
    });
  });
});
