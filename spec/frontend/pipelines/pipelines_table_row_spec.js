import { mount } from '@vue/test-utils';
import PipelinesTableRowComponent from '~/pipelines/components/pipelines_table_row.vue';
import eventHub from '~/pipelines/event_hub';
import { breakpoints } from '~/breakpoints';

describe('Pipelines Table Row', () => {
  const jsonFixtureName = 'pipelines/pipelines.json';

  const createWrapper = pipeline =>
    mount(PipelinesTableRowComponent, {
      propsData: {
        pipeline,
        autoDevopsHelpPath: 'foo',
        viewType: 'root',
      },
      sync: false,
    });

  const resizeTo = width => {
    window.innerWidth = width + 1;
    window.dispatchEvent(new Event('resize'));
  };

  let wrapper;
  let pipeline;
  let pipelineWithoutAuthor;
  let pipelineWithoutCommit;

  preloadFixtures(jsonFixtureName);

  beforeEach(() => {
    const { pipelines } = getJSONFixture(jsonFixtureName);

    pipeline = pipelines.find(p => p.user !== null && p.commit !== null);
    pipelineWithoutAuthor = pipelines.find(p => p.user === null && p.commit !== null);
    pipelineWithoutCommit = pipelines.find(p => p.user === null && p.commit === null);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('should render a table row', () => {
    wrapper = createWrapper(pipeline);

    expect(wrapper.attributes('class')).toContain('gl-responsive-table-row');
  });

  describe('status column', () => {
    beforeEach(() => {
      wrapper = createWrapper(pipeline);
    });

    it('should render a pipeline link', () => {
      expect(wrapper.find('.table-section.commit-link a').attributes('href')).toEqual(
        pipeline.path,
      );
    });

    it('should render status icon', () => {
      expect(wrapper.contains('.table-section.commit-link .ci-status-icon')).toBe(true);
    });

    it('should not render status text in small viewports', () => {
      expect(wrapper.find('.table-section.commit-link .ci-status').text()).toBe('');
    });

    it('should render status text in large viewports', done => {
      resizeTo(breakpoints.lg);

      return wrapper.vm
        .$nextTick()
        .then(() => {
          expect(wrapper.find('.table-section.commit-link .ci-status').text()).toBe(
            pipeline.details.status.text,
          );
        })
        .then(done)
        .catch(done.fail);
    });
  });

  describe('information column', () => {
    beforeEach(() => {
      wrapper = createWrapper(pipeline);
    });

    it('should render a pipeline link', () => {
      expect(wrapper.find('.table-section:nth-child(2) a').attributes('href')).toEqual(
        pipeline.path,
      );
    });

    it('should render pipeline ID', () => {
      expect(wrapper.find('.table-section:nth-child(2) a > span').text()).toEqual(
        `#${pipeline.id}`,
      );
    });

    describe('when a user is provided', () => {
      it('should render user information', () => {
        expect(
          wrapper.find('.table-section:nth-child(3) .js-pipeline-url-user').attributes('href'),
        ).toEqual(pipeline.user.path);

        expect(
          wrapper
            .find('.table-section:nth-child(3) .js-user-avatar-image-toolip')
            .text()
            .trim(),
        ).toEqual(pipeline.user.name);
      });
    });
  });

  describe('commit column', () => {
    it('should render link to commit', () => {
      wrapper = createWrapper(pipeline);

      const commitLink = wrapper.find('.branch-commit .commit-sha');

      expect(commitLink.attributes('href')).toEqual(pipeline.commit.commit_path);
    });

    const findElements = () => {
      const commitTitleElement = wrapper.find('.branch-commit .commit-title');
      const commitAuthorElement = commitTitleElement.find('a.avatar-image-container');

      if (!commitAuthorElement.exists()) {
        return {
          commitAuthorElement,
        };
      }

      const commitAuthorLink = commitAuthorElement.attributes('href');
      const commitAuthorName = commitAuthorElement
        .find('.js-user-avatar-image-toolip')
        .text()
        .trim();

      return {
        commitTitleElement,
        commitAuthorElement,
        commitAuthorLink,
        commitAuthorName,
      };
    };

    it('renders nothing without commit', () => {
      expect(pipelineWithoutCommit.commit).toBe(null);

      wrapper = createWrapper(pipelineWithoutCommit);
      const { commitAuthorElement } = findElements();

      expect(commitAuthorElement.exists()).toBe(false);
    });

    it('renders commit author', () => {
      wrapper = createWrapper(pipeline);
      const { commitAuthorLink, commitAuthorName } = findElements();

      expect(commitAuthorLink).toEqual(pipeline.commit.author.path);
      expect(commitAuthorName).toEqual(pipeline.commit.author.username);
    });

    it('renders commit with unregistered author', () => {
      expect(pipelineWithoutAuthor.commit.author).toBe(null);

      wrapper = createWrapper(pipelineWithoutAuthor);
      const { commitAuthorLink, commitAuthorName } = findElements();

      expect(commitAuthorLink).toEqual(`mailto:${pipelineWithoutAuthor.commit.author_email}`);
      expect(commitAuthorName).toEqual(pipelineWithoutAuthor.commit.author_name);
    });

    it('renders commit title in large viewports', done => {
      wrapper = createWrapper(pipeline);
      resizeTo(breakpoints.lg);

      return wrapper.vm
        .$nextTick()
        .then(() => {
          const { commitTitleElement } = findElements();

          expect(commitTitleElement.text()).toContain(pipeline.commit.title);
          expect(commitTitleElement.text()).not.toContain('by');
        })
        .then(done)
        .catch(done.fail);
    });

    it('does not render commit title in small viewports', () => {
      wrapper = createWrapper(pipeline);

      const { commitTitleElement } = findElements();

      expect(commitTitleElement.text()).not.toContain(pipeline.commit.title);
      expect(commitTitleElement.text()).toContain('by');
    });
  });

  describe('stages column', () => {
    beforeEach(() => {
      wrapper = createWrapper(pipeline);
    });

    it('should render an icon for each stage', () => {
      expect(
        wrapper.findAll('.table-section:nth-child(4) .js-builds-dropdown-button').length,
      ).toEqual(pipeline.details.stages.length);
    });
  });

  describe('actions column', () => {
    const scheduledJobAction = {
      name: 'some scheduled job',
    };

    beforeEach(() => {
      const withActions = Object.assign({}, pipeline);
      withActions.details.scheduled_actions = [scheduledJobAction];
      withActions.flags.cancelable = true;
      withActions.flags.retryable = true;
      withActions.cancel_path = '/cancel';
      withActions.retry_path = '/retry';

      wrapper = createWrapper(withActions);

      resizeTo(breakpoints.lg);
    });

    it('should render the provided actions in large viewports', () => {
      expect(wrapper.find('.js-pipelines-retry-button').exists()).toBe(true);
      expect(wrapper.find('.js-pipelines-cancel-button').exists()).toBe(true);
      const dropdownMenu = wrapper.find('.dropdown-menu');

      expect(dropdownMenu.text()).toContain(scheduledJobAction.name);
    });

    it('emits `retryPipeline` event when retry button is clicked and toggles loading', () => {
      eventHub.$on('retryPipeline', endpoint => {
        expect(endpoint).toBe('/retry');
      });

      wrapper.find('.js-pipelines-retry-button').trigger('click');
      expect(wrapper.vm.isRetrying).toBe(true);
    });

    it('emits `openConfirmationModal` event when cancel button is clicked and toggles loading', () => {
      eventHub.$once('openConfirmationModal', data => {
        const { id, ref, commit } = pipeline;

        expect(data.endpoint).toBe('/cancel');
        expect(data.pipeline).toEqual(
          expect.objectContaining({
            id,
            ref,
            commit,
          }),
        );
      });

      wrapper.find('.js-pipelines-cancel-button').trigger('click');
    });

    it('renders a loading icon when `cancelingPipeline` matches pipeline id', done => {
      wrapper.setProps({ cancelingPipeline: pipeline.id });
      wrapper.vm
        .$nextTick()
        .then(() => {
          expect(wrapper.vm.isCancelling).toBe(true);
        })
        .then(done)
        .catch(done.fail);
    });

    describe('in small viewports', () => {
      beforeEach(() => {
        resizeTo(breakpoints.sm);
      });

      it('should render only the actions toggle by default', () => {
        expect(wrapper.contains('.js-more-actions-toggle')).toBe(true);
        expect(wrapper.contains('.js-pipelines-retry-button')).toBe(false);
        expect(wrapper.contains('.js-pipelines-cancel-button')).toBe(false);
      });

      it('should show and hide the actions when the actions toggle is clicked', done => {
        wrapper.find('.js-more-actions-toggle').trigger('click');

        return wrapper.vm
          .$nextTick()
          .then(() => {
            expect(wrapper.contains('.js-pipelines-retry-button')).toBe(true);
            expect(wrapper.contains('.js-pipelines-cancel-button')).toBe(true);

            wrapper.find('.js-more-actions-toggle').trigger('click');
          })
          .then(wrapper.vm.$nextTick)
          .then(() => {
            expect(wrapper.contains('.js-pipelines-retry-button')).toBe(false);
            expect(wrapper.contains('.js-pipelines-cancel-button')).toBe(false);
          })
          .then(done)
          .catch(done.fail);
      });
    });
  });
});
