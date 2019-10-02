import { shallowMount } from '@vue/test-utils';
import IssueMergeRequestLinks from '~/releases/components/issue_merge_request_links.vue';
import _ from 'underscore';
import { milestones } from '../mock_data';

describe('IssueMergeRequestLinks', () => {
  let wrapper;
  let mockMilestones;
  const issuesUrl = 'http://example.gitlab.com/issues?scope=all';
  const mergeRequestsUrl = 'http://example.gitlab.com/merge_requests?scope=all';

  const factory = milestonesProp => {
    wrapper = shallowMount(IssueMergeRequestLinks, {
      propsData: {
        milestones: milestonesProp,
        issuesUrl,
        mergeRequestsUrl,
      },
      sync: false,
    });
  };

  beforeEach(() => {
    mockMilestones = JSON.parse(JSON.stringify(milestones));
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const testLinkAttributes = () => {
    it('renders links with the appropriate attributes', () => {
      const allLinks = wrapper.findAll('a');

      for (let i = 0; i < allLinks.length; i += 1) {
        const linkAttrs = allLinks.at(i).attributes();
        expect(linkAttrs.target).toBe('_blank');
        expect(linkAttrs.rel).toBe('noopener noreferrer');
      }
    });
  };

  describe('when a single milestone is associated', () => {
    beforeEach(() => {
      factory(mockMilestones.slice(0, 1));
    });

    it('renders the correct text', () => {
      expect(wrapper.text()).toBe('View Issues or Merge Requests in this release');
    });

    it('renders the correct issues URL', () => {
      expect(wrapper.find('a[href*=issues]').attributes().href).toBe(
        'http://example.gitlab.com/issues?scope=all&milestone_title=13.6',
      );
    });

    it('renders the correct merge requests URL', () => {
      expect(wrapper.find('a[href*=merge_requests]').attributes().href).toBe(
        'http://example.gitlab.com/merge_requests?scope=all&milestone_title=13.6',
      );
    });

    testLinkAttributes();
  });

  describe('when multiple milestones are associated', () => {
    beforeEach(() => {
      factory(mockMilestones);
    });

    it('renders the correct text', () => {
      expect(wrapper.text()).toBe(
        'View Issues for milestones 13.6, 13.5. View Merge Requests for milestones 13.6, 13.5.',
      );
    });

    it('renders the correct issue URLs', () => {
      const links = wrapper.findAll('a[href*=issues]');

      expect(links.length).toBe(2);

      expect(links.at(0).attributes().href).toBe(
        'http://example.gitlab.com/issues?scope=all&milestone_title=13.6',
      );

      expect(links.at(0).text()).toBe('13.6');

      expect(links.at(1).attributes().href).toBe(
        'http://example.gitlab.com/issues?scope=all&milestone_title=13.5',
      );

      expect(links.at(1).text()).toBe('13.5');
    });

    it('renders the correct merge request URLs', () => {
      const links = wrapper.findAll('a[href*=merge_requests]');

      expect(links.length).toBe(2);

      expect(links.at(0).attributes().href).toBe(
        'http://example.gitlab.com/merge_requests?scope=all&milestone_title=13.6',
      );

      expect(links.at(0).text()).toBe('13.6');

      expect(links.at(1).attributes().href).toBe(
        'http://example.gitlab.com/merge_requests?scope=all&milestone_title=13.5',
      );

      expect(links.at(1).text()).toBe('13.5');
    });

    testLinkAttributes();
  });

  describe('when the milestone title contains URL-unfriendly characters', () => {
    beforeEach(() => {
      const milestone = mockMilestones.slice(0, 1);
      _.first(milestone).title = 'a/weird/title';
      factory(milestone);
    });

    it('renders the correct issues URL', () => {
      expect(wrapper.find('a[href*=issues]').attributes().href).toBe(
        'http://example.gitlab.com/issues?scope=all&milestone_title=a%2Fweird%2Ftitle',
      );
    });

    it('renders the correct merge requests URL', () => {
      expect(wrapper.find('a[href*=merge_requests]').attributes().href).toBe(
        'http://example.gitlab.com/merge_requests?scope=all&milestone_title=a%2Fweird%2Ftitle',
      );
    });
  });

  describe('when the milestone title contains malicious text', () => {
    beforeEach(() => {
      const milestone = mockMilestones.slice(0, 1);
      _.first(milestone).title = '<script></script>';
      factory(milestone);
    });

    it('renders the correct issues URL', () => {
      expect(wrapper.find('a[href*=issues]').attributes().href).toBe(
        'http://example.gitlab.com/issues?scope=all&milestone_title=%26lt%3Bscript%26gt%3B%26lt%3B%2Fscript%26gt%3B',
      );
    });

    it('renders the correct merge requests URL', () => {
      expect(wrapper.find('a[href*=merge_requests]').attributes().href).toBe(
        'http://example.gitlab.com/merge_requests?scope=all&milestone_title=%26lt%3Bscript%26gt%3B%26lt%3B%2Fscript%26gt%3B',
      );
    });
  });
});
