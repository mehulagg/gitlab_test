import { shallowMount, mount } from '@vue/test-utils';
import StageComponent from 'ee/analytics/cycle_analytics/components/stage_component.vue';
import { issueStage, issueItems, planItems, reviewItems } from '../mock_data';

let wrapper = null;

function createComponent(props = {}, shallow = true) {
  const func = shallow ? shallowMount : mount;
  return func(StageComponent, {
    propsData: {
      stage: issueStage,
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
};

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
  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with a stage and events', () => {
    it('will render the event description', () => {
      const txt = wrapper.find($sel.description).text();
      expect(txt).toEqual(issueStage.description);
    });

    it('will render a list of items', () => {
      expect(wrapper.findAll($sel.item).length).toEqual(issueItems.length);
    });
  });

  describe('Issue stage', () => {
    it('will render the list of items as stage events', () => {
      wrapper = createComponent({}, false);

      issueItems.forEach((item, index) => {
        const elem = wrapper.findAll($sel.item).at(index);
        expect(elem.find($sel.title).text()).toEqual(item.title);
        expect(elem.find($sel.issueLink).text()).toEqual(`#${item.iid}`);
        expect(elem.find($sel.date).text()).toEqual(item.createdAt);
        expect(elem.find($sel.author).text()).toEqual(item.author.name);
        expect(elem.find($sel.author).attributes('href')).toEqual(item.author.webUrl);
        renderTotalTime(elem, item.totalTime);
      });
    });
  });

  describe('Plan stage', () => {
    it('will render the list of items as stage events', () => {
      wrapper = createComponent({ items: planItems }, false);

      planItems.forEach((item, index) => {
        const elem = wrapper.findAll($sel.item).at(index);
        expect(elem.find($sel.title).text()).toEqual(item.title);
        expect(elem.find($sel.issueLink).text()).toEqual(`#${item.iid}`);
        expect(elem.find($sel.date).text()).toEqual(item.createdAt);
        expect(elem.find($sel.author).text()).toEqual(item.author.name);
        expect(elem.find($sel.author).attributes('href')).toEqual(item.author.webUrl);
        renderTotalTime(elem, item.totalTime);
      });
    });
  });

  describe('Review stage', () => {
    it('will render the list of items as stage events', () => {
      wrapper = createComponent({ items: reviewItems }, false);
      reviewItems.forEach((item, index) => {
        const elem = wrapper.findAll($sel.item).at(index);
        expect(elem.find($sel.title).text()).toEqual(item.title);
        expect(elem.find($sel.issueLink).text()).toEqual(`#${item.iid}`);
        expect(elem.find($sel.date).text()).toEqual(item.createdAt);
        expect(elem.find($sel.author).text()).toEqual(item.author.name);
        expect(elem.find($sel.author).attributes('href')).toEqual(item.author.webUrl);
        renderTotalTime(elem, item.totalTime);
      });
    });
  });
});
