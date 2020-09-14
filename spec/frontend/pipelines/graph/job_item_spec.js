import { mount } from '@vue/test-utils';
import { trimText } from 'helpers/text_helper';
import JobItem from '~/pipelines/components/graph/job_item.vue';

describe('pipeline graph job item', () => {
  let wrapper;

  const findJobWithoutLink = () => wrapper.find('[data-testid="job-without-link"]');

  const createWrapper = propsData => {
    wrapper = mount(JobItem, {
      propsData,
    });
  };

  const triggerActiveClass = 'gl-shadow-x0-y0-b3-s1-blue-500';
  const delayedJobFixture = getJSONFixture('jobs/delayed.json');
  const mockJob = {
    id: 4256,
    name: 'test',
    status: {
      icon: 'status_success',
      text: 'passed',
      label: 'passed',
      tooltip: 'passed',
      group: 'success',
      details_path: '/root/ci-mock/builds/4256',
      has_details: true,
      action: {
        icon: 'retry',
        title: 'Retry',
        path: '/root/ci-mock/builds/4256/retry',
        method: 'post',
      },
    },
  };
  const mockJobWithoutDetails = {
    id: 4257,
    name: 'test',
    status: {
      icon: 'status_success',
      text: 'passed',
      label: 'passed',
      group: 'success',
      details_path: '/root/ci-mock/builds/4257',
      has_details: false,
    },
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('name with link', () => {
    it('should render the job name and status with a link', done => {
      createWrapper({ job: mockJob });

      wrapper.vm.$nextTick(() => {
        const link = wrapper.find('a');

        expect(link.attributes('href')).toBe(mockJob.status.details_path);

        expect(link.attributes('title')).toEqual(`${mockJob.name} - ${mockJob.status.label}`);

        expect(wrapper.find('.ci-status-icon-success').exists()).toBe(true);

        expect(trimText(wrapper.find('.ci-status-text').text())).toBe(mockJob.name);

        done();
      });
    });
  });

  describe('name without link', () => {
    beforeEach(() => {
      createWrapper({
        job: mockJobWithoutDetails,
        cssClassJobName: 'css-class-job-name',
        jobHovered: 'test',
      });
    });

    it('it should render status and name', () => {
      expect(wrapper.find('.ci-status-icon-success').exists()).toBe(true);
      expect(wrapper.find('a').exists()).toBe(false);

      expect(trimText(wrapper.find('.ci-status-text').text())).toEqual(mockJob.name);
    });

    it('should apply hover class and provided class name', () => {
      expect(findJobWithoutLink().classes()).toContain(triggerActiveClass);
      expect(findJobWithoutLink().classes()).toContain('css-class-job-name');
    });
  });

  describe('action icon', () => {
    it('it should render the action icon', () => {
      createWrapper({ job: mockJob });

      expect(wrapper.find('.ci-action-icon-container').exists()).toBe(true);
      expect(wrapper.find('.ci-action-icon-wrapper').exists()).toBe(true);
    });
  });

  it('should render provided class name', () => {
    createWrapper({
      job: mockJob,
      cssClassJobName: 'css-class-job-name',
    });

    expect(wrapper.find('a').classes()).toContain('css-class-job-name');
  });

  describe('status label', () => {
    it('should not render status label when it is not provided', () => {
      createWrapper({
        job: {
          id: 4258,
          name: 'test',
          status: {
            icon: 'status_success',
          },
        },
      });

      expect(wrapper.find('.js-job-component-tooltip').attributes('title')).toBe('test');
    });

    it('should not render status label when it is  provided', () => {
      createWrapper({
        job: {
          id: 4259,
          name: 'test',
          status: {
            icon: 'status_success',
            label: 'success',
            tooltip: 'success',
          },
        },
      });

      expect(wrapper.find('.js-job-component-tooltip').attributes('title')).toEqual(
        'test - success',
      );
    });
  });

  describe('for delayed job', () => {
    it('displays remaining time in tooltip', () => {
      createWrapper({
        job: delayedJobFixture,
      });

      expect(wrapper.find('.js-pipeline-graph-job-link').attributes('title')).toEqual(
        `delayed job - delayed manual action (${wrapper.vm.remainingTime})`,
      );
    });
  });

  describe('trigger job highlighting', () => {
    it('trigger job should stay highlighted when downstream is expanded', () => {
      createWrapper({
        job: mockJobWithoutDetails,
        pipelineExpanded: { jobName: mockJob.name, expanded: true },
      });

      expect(findJobWithoutLink().classes()).toContain(triggerActiveClass);
    });

    it('trigger job should not be highlighted when downstream is closed', () => {
      createWrapper({
        job: mockJobWithoutDetails,
        pipelineExpanded: { jobName: mockJob.name, expanded: false },
      });

      expect(findJobWithoutLink().classes()).not.toContain(triggerActiveClass);
    });
  });
});
