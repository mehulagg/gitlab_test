import { shallowMount, mount } from '@vue/test-utils';
import StageComponent from 'ee/analytics/cycle_analytics/components/stage_component.vue';
import { issueStage, issueItems } from '../mock_data';

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

describe('StageComponent', () => {
  describe('Issue stage', () => {
    describe('with a stage and events', () => {
      beforeEach(() => {
        wrapper = createComponent();
      });

      afterEach(() => {
        wrapper.destroy();
      });

      it('will render the event description', () => {
        const txt = wrapper.find($sel.description).text();
        expect(txt).toEqual(issueStage.description);
      });

      it('will render a list of items', () => {
        expect(wrapper.findAll($sel.item).length).toEqual(issueItems.length);
      });

      it('will render the list of items as stage events', () => {
        wrapper = createComponent({}, false);

        issueItems.forEach((item, index) => {
          const elem = wrapper.findAll($sel.item).at(index);
          expect(elem.find($sel.title).text()).toEqual(item.title);
          expect(elem.find($sel.issueLink).text()).toEqual(`#${item.iid}`);
          expect(elem.find($sel.date).text()).toEqual(item.createdAt);
          expect(elem.find($sel.author).text()).toEqual(item.author.name);
          expect(elem.find($sel.author).attributes('href')).toEqual(item.author.webUrl);
          expect(elem.find($sel.time).text()).toContain(item.totalTime.seconds);
        });
      });
    });
  });
});
