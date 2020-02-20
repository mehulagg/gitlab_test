import { mount } from '@vue/test-utils';
import { componentNames } from 'ee/reports/components/issue_body';
import createStore from 'ee/vue_shared/security_reports/store';
import {
  sastParsedIssues,
  dockerReportParsed,
  parsedDast,
} from 'ee_jest/vue_shared/security_reports/mock_data';
import { STATUS_FAILED, STATUS_SUCCESS } from '~/reports/constants';
import ReportIssues from '~/reports/components/report_item.vue';

describe('Report issues', () => {
  let wrapper;

  const codequalityParsedIssues = [
    {
      name: 'Insecure Dependency',
      fingerprint: 'ca2e59451e98ae60ba2f54e3857c50e5',
      path: 'Gemfile.lock',
      line: 12,
      urlPath: 'foo/Gemfile.lock',
    },
  ];

  const factory = (propsData = {}, store = null) => {
    wrapper = mount(ReportIssues, {
      propsData,
      store,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('for codequality issues', () => {
    describe('resolved issues', () => {
      beforeEach(() => {
        factory({
          issue: codequalityParsedIssues[0],
          component: componentNames.CodequalityIssueBody,
          status: STATUS_SUCCESS,
        });
      });

      it('should render "Fixed" keyword', () => {
        expect(wrapper.text()).toContain('Fixed');
        expect(
          wrapper
            .text()
            .replace(/\s+/g, ' ')
            .trim(),
        ).toEqual('Fixed: Insecure Dependency in Gemfile.lock:12');
      });
    });

    describe('unresolved issues', () => {
      beforeEach(() => {
        factory({
          issue: codequalityParsedIssues[0],
          component: componentNames.CodequalityIssueBody,
          status: STATUS_FAILED,
        });
      });

      it('should not render "Fixed" keyword', () => {
        expect(wrapper.text()).not.toContain('Fixed');
      });
    });
  });

  describe('with location', () => {
    it('should render location', () => {
      factory({
        issue: sastParsedIssues[0],
        component: componentNames.SastIssueBody,
        status: STATUS_FAILED,
      });

      expect(wrapper.text()).toContain('in');
      expect(wrapper.find('.report-block-list-issue a').attributes('href')).toBe(
        sastParsedIssues[0].urlPath,
      );
    });
  });

  describe('without location', () => {
    it('should not render location', () => {
      factory({
        issue: {
          title: 'foo',
        },
        component: componentNames.SastIssueBody,
        status: STATUS_SUCCESS,
      });

      expect(wrapper.text()).not.toContain('in');
      expect(wrapper.find('.report-block-list-issue a').exists()).toBe(false);
    });
  });

  describe('for container scanning issues', () => {
    beforeEach(() => {
      factory({
        issue: dockerReportParsed.unapproved[0],
        component: componentNames.ContainerScanningIssueBody,
        status: STATUS_FAILED,
      });
    });

    it('renders severity', () => {
      expect(wrapper.text().trim()).toContain(dockerReportParsed.unapproved[0].severity);
    });

    it('renders CVE name', () => {
      expect(
        wrapper
          .find('.report-block-list-issue button')
          .text()
          .trim(),
      ).toBe(dockerReportParsed.unapproved[0].title);
    });
  });

  describe('for dast issues', () => {
    beforeEach(() => {
      factory(
        {
          issue: parsedDast[0],
          component: componentNames.DastIssueBody,
          status: STATUS_FAILED,
        },
        createStore(),
      );
    });

    it('renders severity and title', () => {
      expect(wrapper.text()).toContain(parsedDast[0].title);
      expect(wrapper.text()).toContain(`${parsedDast[0].severity}`);
    });
  });
});
