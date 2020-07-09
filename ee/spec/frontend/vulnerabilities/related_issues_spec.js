import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import RelatedIssues from 'ee/vulnerabilities/components/related_issues.vue';
import RelatedIssuesBlock from 'ee/related_issues/components/related_issues_block.vue';
import { issuableTypesMap, PathIdSeparator } from 'ee/related_issues/constants';

jest.mock('~/flash');

const mockAxios = new MockAdapter(axios);

describe('Vulnerability related issues component', () => {
  let wrapper;

  const propsData = {
    endpoint: 'endpoint',
    projectPath: 'project/path',
    helpPath: 'help/path',
    canAdmin: true,
  };

  const issue1 = { id: 3, vulnerabilityLinkId: 987 };
  const issue2 = { id: 25, vulnerabilityLinkId: 876 };
  const issue3 = { id: 356, vulnerabilityLinkId: 765 };

  const createWrapper = () => {
    wrapper = shallowMount(RelatedIssues, { propsData });
  };

  const relatedIssuesBlock = () => wrapper.find(RelatedIssuesBlock);
  const blockProp = prop => relatedIssuesBlock().props(prop);
  const blockEmit = (eventName, data) => relatedIssuesBlock().vm.$emit(eventName, data);

  afterEach(() => {
    wrapper.destroy();
    mockAxios.reset();
  });

  it('passes the expected props to the RelatedIssuesBlock component', async () => {
    createWrapper();

    const data = {
      isFetching: true,
      isSubmitting: true,
      isFormVisible: true,
      inputValue: 'input value',
    };

    const state = {
      relatedIssues: [{}, {}, {}],
      pendingReferences: ['#1', '#2', '#3'],
    };

    window.gl = { GfmAutoComplete: { dataSources: {} } };

    wrapper.setData(data);
    wrapper.setData({ state });
    await wrapper.vm.$nextTick();

    expect(relatedIssuesBlock().props()).toMatchObject({
      helpPath: propsData.helpPath,
      canAdmin: propsData.canAdmin,
      relatedIssues: state.relatedIssues,
      pendingReferences: state.pendingReferences,
      autoCompleteSources: window.gl.GfmAutoComplete.dataSources,
      issuableType: issuableTypesMap.ISSUE,
      pathIdSeparator: PathIdSeparator.Issue,
      showCategorizedIssues: false,
    });

    expect(relatedIssuesBlock().props()).toMatchObject(data);
  });

  describe('fetch issues', () => {
    it('fetches related issues when the component is created', async () => {
      mockAxios.onGet(propsData.endpoint).replyOnce(200, [issue1, issue2, issue3]);
      createWrapper();
      await axios.waitForAll();

      expect(mockAxios.history.get).toHaveLength(1);
      expect(blockProp('relatedIssues')).toMatchObject([issue1, issue2, issue3]);
    });

    it('fetch fails with error', async () => {
      mockAxios.onGet(propsData.endpoint).replyOnce(500);
      createWrapper();
      await axios.waitForAll();

      expect(mockAxios.history.get).toHaveLength(1);
      expect(blockProp('relatedIssues')).toEqual([]);
      expect(createFlash).toHaveBeenCalledTimes(1);
    });
  });

  describe('add related issue', () => {
    it.each`
      reference                                          | id                           | projectPath
      ${'135'}                                           | ${135}                       | ${propsData.projectPath}
      ${'#246'}                                          | ${246}                       | ${propsData.projectPath}
      ${'https://localhost:3000/root/test/-/issues/357'} | ${357}                       | ${'root/test'}
      ${'/root/test/-/issues/357'}                       | ${'/root/test/-/issues/357'} | ${propsData.projectPath}
      ${'invalidReference'}                              | ${'invalidReference'}        | ${propsData.projectPath}
    `('addRelatedIssue for $id, $reference', async ({ id, reference, projectPath }) => {
      createWrapper();

      const vulnerabilityLinkId = Math.floor(Math.random() * 100);
      mockAxios.onPost(propsData.endpoint).replyOnce(200, { issue: {}, id: vulnerabilityLinkId });
      blockEmit('addIssuableFormSubmit', { pendingReferences: reference });

      await axios.waitForAll();

      expect(mockAxios.history.post).toHaveLength(1);
      const requestData = JSON.parse(mockAxios.history.post[0].data);
      expect(requestData.target_issue_iid).toBe(id.toString());
      expect(requestData.target_project_id).toBe(projectPath);
      expect(blockProp('relatedIssues')).toHaveLength(1);
      expect(blockProp('relatedIssues')[0].vulnerabilityLinkId).toBe(vulnerabilityLinkId);
    });

    it('adds multiple issues', async () => {
      createWrapper();

      mockAxios.onPost(propsData.endpoint).reply(200, { issue: {} });

      blockEmit('addIssuableFormSubmit', { pendingReferences: '#1 #2 #3' });
      await axios.waitForAll();

      expect(mockAxios.history.post).toHaveLength(3);
      expect(blockProp('relatedIssues')).toHaveLength(3);
      expect(blockProp('isFormVisible')).toBe(false);
      expect(blockProp('inputValue')).toBe('');
    });

    it('adds only issues that returns issue', async () => {
      mockAxios.onGet(propsData.endpoint).replyOnce(200, []);
      createWrapper();
      wrapper.setData({ isFormVisible: true });

      const response = { issue: {} };

      mockAxios
        .onPost(propsData.endpoint)
        .replyOnce(200, response)
        .onPost(propsData.endpoint)
        .replyOnce(500)
        .onPost(propsData.endpoint)
        .replyOnce(200, response)
        .onPost(propsData.endpoint)
        .replyOnce(500);

      blockEmit('addIssuableFormSubmit', { pendingReferences: '#1 #2 #3 #4' });
      await axios.waitForAll();

      expect(mockAxios.history.post).toHaveLength(4);
      expect(blockProp('relatedIssues')).toHaveLength(2);
      expect(blockProp('isFormVisible')).toBe(true);
      expect(blockProp('inputValue')).toBe('');
      expect(blockProp('pendingReferences')).toEqual(['#2', '#4']);
      expect(createFlash).toHaveBeenCalledTimes(1);
    });
  });

  describe('related issues block events', () => {
    beforeEach(() => createWrapper());

    it('@toggleAddRelatedIssuesForm -> toggleFormVisibility', async () => {
      expect(relatedIssuesBlock().props('isFormVisible')).toBe(false);
      relatedIssuesBlock().vm.$emit('toggleAddRelatedIssuesForm');
      await wrapper.vm.$nextTick();
      expect(relatedIssuesBlock().props('isFormVisible')).toBe(true);
      relatedIssuesBlock().vm.$emit('toggleAddRelatedIssuesForm');
      await wrapper.vm.$nextTick();
      expect(relatedIssuesBlock().props('isFormVisible')).toBe(false);
    });

    it('@addIssuableFormInput -> addPendingReferences', async () => {
      const pendingReferences = ['135', '246'];
      const newReferences = ['357', '468'];
      const touchedReference = 'touchedReference';
      wrapper.setData({ state: { pendingReferences } });

      relatedIssuesBlock().vm.$emit('addIssuableFormInput', {
        untouchedRawReferences: newReferences,
        touchedReference,
      });
      await wrapper.vm.$nextTick();
      expect(relatedIssuesBlock().props('pendingReferences')).toEqual(
        pendingReferences.concat(newReferences),
      );
      expect(relatedIssuesBlock().props('inputValue')).toBe(touchedReference);
    });

    it('@addIssuableFormBlur -> processAllReferences', async () => {
      relatedIssuesBlock().vm.$emit('addIssuableFormBlur', '135 246');
      await wrapper.vm.$nextTick();
      expect(relatedIssuesBlock().props('pendingReferences')).toEqual(['135', '246']);
      expect(relatedIssuesBlock().props('inputValue')).toBe('');
    });

    it('@addIssuableFormCancel -> resetForm', async () => {
      wrapper.setData({
        inputValue: 'some input value',
        isFormVisible: true,
        state: { pendingReferences: ['135', '246'] },
      });

      relatedIssuesBlock().vm.$emit('addIssuableFormCancel');
      await wrapper.vm.$nextTick();

      expect(relatedIssuesBlock().props('isFormVisible')).toBe(false);
      expect(relatedIssuesBlock().props('pendingReferences')).toEqual([]);
      expect(relatedIssuesBlock().props('inputValue')).toBe('');
    });

    it('@pendingIssuableRemoveRequest -> removePendingReference', async () => {
      wrapper.setData({ state: { pendingReferences: ['135', '246', '357'] } });
      relatedIssuesBlock().vm.$emit('pendingIssuableRemoveRequest', 1);
      await wrapper.vm.$nextTick();

      expect(relatedIssuesBlock().props('pendingReferences')).toEqual(['135', '357']);
    });
  });

  describe('remove related issue', () => {
    beforeEach(async () => {
      mockAxios.onGet(propsData.endpoint).replyOnce(200, [issue1, issue2]);
      createWrapper();
      await axios.waitForAll();
    });

    it('@relatedIssueRemoveRequest -> removeRelatedIssue', async () => {
      mockAxios.onDelete(`${propsData.endpoint}/${issue1.vulnerabilityLinkId}`).replyOnce(200);
      relatedIssuesBlock().vm.$emit('relatedIssueRemoveRequest', issue1.id);
      await axios.waitForAll();

      expect(mockAxios.history.delete).toHaveLength(1);
      expect(blockProp('relatedIssues')).toMatchObject([issue2]);
    });

    it('@relatedIssueRemoveRequest -> removeRelatedIssue delete fail', async () => {
      mockAxios.onDelete(`${propsData.endpoint}/${issue1.vulnerabilityLinkId}`).replyOnce(500);
      relatedIssuesBlock().vm.$emit('relatedIssueRemoveRequest', issue1.id);
      await axios.waitForAll();

      expect(mockAxios.history.delete).toHaveLength(1);
      expect(blockProp('relatedIssues')).toMatchObject([issue1, issue2]);
      expect(createFlash).toHaveBeenCalledTimes(1);
    });
  });
});
