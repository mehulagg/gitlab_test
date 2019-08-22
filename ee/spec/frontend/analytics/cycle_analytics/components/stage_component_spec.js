import { shallowMount, mount } from '@vue/test-utils';
import StageComponent from 'ee/analytics/cycle_analytics/components/stage_component.vue';
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

function createComponent(props = {}, shallow = true) {
  const func = shallow ? shallowMount : mount;
  return func(StageComponent, {
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
  expect(elem.find($sel.issueLink).text()).toEqual(`#${item.iid}`);
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
    beforeEach(() => {
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    describe('Issue stage', () => {
      it('will render the event description', () => {
        wrapper = createComponent({ items: issueItems });
        expect(wrapper.find($sel.description).text()).toEqual(stage.description);
      });

      it('will render the list of items', () => {
        wrapper = createComponent({}, false);

        issueItems.forEach((item, index) => {
          const elem = wrapper.findAll($sel.item).at(index);
          renderStageEvent(elem, item);
          renderTotalTime(elem, item.totalTime);
        });
      });
    });

    describe('Plan stage', () => {
      it('will render the event description', () => {
        wrapper = createComponent({ items: planItems });
        expect(wrapper.find($sel.description).text()).toEqual(stage.description);
      });
      it('will render the list of items', () => {
        wrapper = createComponent({ items: planItems }, false);

        planItems.forEach((item, index) => {
          const elem = wrapper.findAll($sel.item).at(index);
          renderStageEvent(elem, item);
          renderTotalTime(elem, item.totalTime);
        });
      });
    });

    describe('Review stage', () => {
      it('will render the event description', () => {
        wrapper = createComponent({ items: reviewItems });
        expect(wrapper.find($sel.description).text()).toEqual(stage.description);
      });
      it('will render the list of items', () => {
        wrapper = createComponent({ items: reviewItems }, false);
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
      it('will render the event description', () => {
        wrapper = createComponent({ items: codeItems });
        expect(wrapper.find($sel.description).text()).toEqual(stage.description);
      });
      it('will render the list of items', () => {
        wrapper = createComponent({ items: codeItems }, false);
        codeItems.forEach((item, index) => {
          const elem = wrapper.findAll($sel.item).at(index);
          renderStageEvent(elem, item);
          renderTotalTime(elem, item.totalTime);
        });
      });
    });

    describe('Test stage', () => {
      it('will render the event description', () => {
        wrapper = createComponent({ items: testItems });
        expect(wrapper.find($sel.description).text()).toEqual(stage.description);
      });
      it('will render the list of items', () => {
        wrapper = createComponent({ items: testItems }, false);
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
      it('will render the event description', () => {
        wrapper = createComponent({ items: stagingItems });
        stagingItems.forEach(item => {
          expect(wrapper.find($sel.description).text()).toEqual(item.description);
        });
      });
      it('will render the list of items', () => {
        wrapper = createComponent({ items: stagingItems }, false);
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
      it('will render the event description', () => {
        wrapper = createComponent({ items: productionItems });
        expect(wrapper.find($sel.description).text()).toEqual(stage.description);
      });
      it('will render the list of items', () => {
        wrapper = createComponent({ items: productionItems }, false);
        productionItems.forEach((item, index) => {
          const elem = wrapper.findAll($sel.item).at(index);
          renderStageEvent(elem, item);
          renderTotalTime(elem, item.totalTime);
        });
      });
    });
  });
});
