import { shallowMount, mount } from '@vue/test-utils';
import StageComponent from 'ee/analytics/cycle_analytics/components/stage_component.vue';
import StageCodeComponent from 'ee/analytics/cycle_analytics/components/stage_code_component.vue';
import StageReviewComponent from 'ee/analytics/cycle_analytics/components/stage_review_component.vue';
import StageTestComponent from 'ee/analytics/cycle_analytics/components/stage_test_component.vue';
import StageStagingComponent from 'ee/analytics/cycle_analytics/components/stage_staging_component.vue';

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

function createComponent(props = {}, shallow = true, Component = StageComponent) {
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
  title: '.issue-title',
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

describe('StageComponent', () => {
  describe('Default stages', () => {
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
        wrapper = createComponent({ items: reviewItems }, false, StageReviewComponent);
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
        wrapper = createComponent({ items: codeItems }, false, StageCodeComponent);
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
        wrapper = createComponent({ items: testItems }, false, StageTestComponent);
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
        wrapper = createComponent({ items: stagingItems }, false, StageStagingComponent);
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
