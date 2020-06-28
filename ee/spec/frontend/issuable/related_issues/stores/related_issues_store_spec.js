import RelatedIssuesStore from 'ee/related_issues/stores/related_issues_store';

import {
  issuable1,
  issuable2,
  issuable3,
  issuable4,
  issuable5,
} from 'jest/vue_shared/components/issue/related_issuable_mock_data';

describe('RelatedIssuesStore', () => {
  let store;

  beforeEach(() => {
    store = new RelatedIssuesStore();
  });

  describe('setRelatedIssues', () => {
    it('defaults to empty array', () => {
      expect(store.state.relatedIssues).toEqual([]);
    });

    it('add issue', () => {
      const relatedIssues = [issuable1];
      store.setRelatedIssues(relatedIssues);

      expect(store.state.relatedIssues).toEqual(relatedIssues);
    });
  });

  describe('addRelatedIssues', () => {
    it('adds related issues', () => {
      store.state.relatedIssues = [issuable1];
      store.addRelatedIssues([issuable2, issuable3]);

      expect(store.state.relatedIssues).toEqual([issuable1, issuable2, issuable3]);
    });

    it('adds only new issues when some already exist', () => {
      store.state.relatedIssues = [issuable1, issuable2];
      store.addRelatedIssues([{ ...issuable1 }, { ...issuable2 }, issuable3]);

      expect(store.state.relatedIssues).toEqual([issuable1, issuable2, issuable3]);
    });
  });

  describe('removeRelatedIssue', () => {
    it('remove issue', () => {
      store.state.relatedIssues = [issuable1];

      store.removeRelatedIssue(issuable1);

      expect(store.state.relatedIssues).toEqual([]);
    });

    it('remove issue with multiple in store', () => {
      store.state.relatedIssues = [issuable1, issuable2];

      store.removeRelatedIssue(issuable1);

      expect(store.state.relatedIssues).toEqual([issuable2]);
    });
  });

  describe('updateIssueOrder', () => {
    it('updates issue order', () => {
      store.state.relatedIssues = [issuable1, issuable2, issuable3, issuable4, issuable5];

      expect(store.state.relatedIssues[3].id).toBe(issuable4.id);
      store.updateIssueOrder(3, 0);

      expect(store.state.relatedIssues[0].id).toBe(issuable4.id);
    });
  });

  describe('setPendingReferences', () => {
    it('defaults to empty array', () => {
      expect(store.state.pendingReferences).toEqual([]);
    });

    it('add reference', () => {
      const relatedIssues = [issuable1.reference];
      store.setPendingReferences(relatedIssues);

      expect(store.state.pendingReferences).toEqual(relatedIssues);
    });
  });

  describe('removePendingRelatedIssue', () => {
    it('remove issue', () => {
      store.state.pendingReferences = [issuable1.reference];

      store.removePendingRelatedIssue(0);

      expect(store.state.pendingReferences).toEqual([]);
    });

    it('remove issue with multiple in store', () => {
      store.state.pendingReferences = [issuable1.reference, issuable2.reference];

      store.removePendingRelatedIssue(0);

      expect(store.state.pendingReferences).toEqual([issuable2.reference]);
    });
  });
});
