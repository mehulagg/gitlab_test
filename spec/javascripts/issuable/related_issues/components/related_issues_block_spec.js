import Vue from 'vue';
import eventHub from '~/issuable/related_issues/event_hub';
import relatedIssuesBlock from '~/issuable/related_issues/components/related_issues_block.vue';

const issuable1 = {
  id: 200,
  epic_issue_id: 1,
  reference: 'foo/bar#123',
  displayReference: '#123',
  title: 'some title',
  path: '/foo/bar/issues/123',
  state: 'opened',
};

const issuable2 = {
  id: 201,
  epic_issue_id: 2,
  reference: 'foo/bar#124',
  displayReference: '#124',
  title: 'some other thing',
  path: '/foo/bar/issues/124',
  state: 'opened',
};

const issuable3 = {
  id: 202,
  epic_issue_id: 3,
  reference: 'foo/bar#125',
  displayReference: '#125',
  title: 'some other other thing',
  path: '/foo/bar/issues/125',
  state: 'opened',
};

const issuable4 = {
  id: 203,
  epic_issue_id: 4,
  reference: 'foo/bar#126',
  displayReference: '#126',
  title: 'some other other other thing',
  path: '/foo/bar/issues/126',
  state: 'opened',
};

describe('RelatedIssuesBlock', () => {
  let RelatedIssuesBlock;
  let vm;

  beforeEach(() => {
    RelatedIssuesBlock = Vue.extend(relatedIssuesBlock);
  });

  afterEach(() => {
    if (vm) {
      vm.$destroy();
    }
  });

  describe('with defaults', () => {
    beforeEach(() => {
      vm = new RelatedIssuesBlock().$mount();
    });

    it('unable to add new related issues', () => {
      expect(vm.$refs.issueCountBadgeAddButton).toBeUndefined();
    });

    it('add related issues form is hidden', () => {
      expect(vm.$el.querySelector('.js-add-related-issues-form-area')).toBeNull();
    });

    it('should not show loading icon', () => {
      expect(vm.$refs.loadingIcon).toBeUndefined();
    });
  });

  describe('with isFetching=true', () => {
    beforeEach(() => {
      vm = new RelatedIssuesBlock({
        propsData: {
          isFetching: true,
        },
      }).$mount();
    });

    it('should show loading icon', () => {
      expect(vm.$refs.loadingIcon).toBeDefined();
    });

    it('should show `...` badge count', () => {
      expect(vm.badgeLabel).toBe('...');
    });
  });

  describe('with canAddRelatedIssues=true', () => {
    beforeEach(() => {
      vm = new RelatedIssuesBlock({
        propsData: {
          canAdmin: true,
        },
      }).$mount();
    });

    it('can add new related issues', () => {
      expect(vm.$refs.issueCountBadgeAddButton).toBeDefined();
    });
  });

  describe('with isFormVisible=true', () => {
    beforeEach(() => {
      vm = new RelatedIssuesBlock({
        propsData: {
          isFormVisible: true,
        },
      }).$mount();
    });

    it('shows add related issues form', () => {
      expect(vm.$el.querySelector('.js-add-related-issues-form-area')).toBeDefined();
    });
  });

  describe('with relatedIssues', () => {
    beforeEach(() => {
      vm = new RelatedIssuesBlock({
        propsData: {
          relatedIssues: [
            issuable1,
            issuable2,
          ],
        },
      }).$mount();
    });

    it('should render issue tokens items', () => {
      expect(vm.$el.querySelectorAll('.js-related-issues-token-list-item').length).toEqual(2);
    });
  });

  describe('methods', () => {
    let toggleAddRelatedIssuesFormSpy;

    beforeEach(() => {
      vm = new RelatedIssuesBlock({
        propsData: {
          relatedIssues: [
            issuable1,
            issuable2,
            issuable3,
            issuable4,
          ],
        },
      }).$mount();
      toggleAddRelatedIssuesFormSpy = jasmine.createSpy('spy');
      eventHub.$on('toggleAddRelatedIssuesForm', toggleAddRelatedIssuesFormSpy);
    });

    afterEach(() => {
      eventHub.$off('toggleAddRelatedIssuesForm', toggleAddRelatedIssuesFormSpy);
    });

    it('reorder item correctly when an item is moved to the top', () => {
      const beforeAfterIds = vm.getBeforeAfterId(0, 3);
      expect(beforeAfterIds.beforeId).toBeNull();
      expect(beforeAfterIds.afterId).toBe(1);
    });

    it('reorder item correctly when an item is moved to the bottom', () => {
      const beforeAfterIds = vm.getBeforeAfterId(3, 3);
      expect(beforeAfterIds.beforeId).toBe(4);
      expect(beforeAfterIds.afterId).toBeNull();
    });

    it('reorder item correctly when an item is moved somewhere in the middle', () => {
      const beforeAfterIds = vm.getBeforeAfterId(2, 3);
      expect(beforeAfterIds.beforeId).toBe(2);
      expect(beforeAfterIds.afterId).toBe(3);
    });

    it('when expanding add related issue form', () => {
      expect(toggleAddRelatedIssuesFormSpy).not.toHaveBeenCalled();
      vm.toggleAddRelatedIssuesForm();
      expect(toggleAddRelatedIssuesFormSpy).toHaveBeenCalled();
    });
  });
});
