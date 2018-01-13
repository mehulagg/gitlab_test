import Vue from 'vue';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import mrWidgetOptions from 'ee/vue_merge_request_widget/mr_widget_options';
import MRWidgetService from 'ee/vue_merge_request_widget/services/mr_widget_service';
import MRWidgetStore from 'ee/vue_merge_request_widget/stores/mr_widget_store';
import mockData, {
  baseIssues,
  headIssues,
  basePerformance,
  headPerformance,
  securityIssues,
  dockerReport,
  dockerReportParsed,
  dast,
  parsedDast,
} from './mock_data';
import mountComponent from '../helpers/vue_mount_component_helper';

describe('ee merge request widget options', () => {
  let vm;
  let Component;

  beforeEach(() => {
    delete mrWidgetOptions.extends.el; // Prevent component mounting

    Component = Vue.extend(mrWidgetOptions);
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('security widget', () => {
    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        sast: {
          path: 'path.json',
          blob_path: 'blob_path',
        },
      };

      Component.mr = new MRWidgetStore(gl.mrWidgetData);
      Component.service = new MRWidgetService({});
    });

    describe('when it is loading', () => {
      it('should render loading indicator', () => {
        vm = mountComponent(Component);
        expect(
          vm.$el.querySelector('.js-sast-widget').textContent.trim(),
        ).toContain('Loading security report');
      });
    });

    describe('with successful request', () => {
      let mock;

      beforeEach(() => {
        mock = mock = new MockAdapter(axios);
        mock.onGet('path.json').reply(200, securityIssues);
        vm = mountComponent(Component);
      });

      afterEach(() => {
        mock.reset();
      });

      it('should render provided data', (done) => {
        setTimeout(() => {
          expect(
            vm.$el.querySelector('.js-sast-widget .js-code-text').textContent.trim(),
          ).toEqual('SAST detected 2 security vulnerabilities');
          done();
        }, 0);
      });
    });

    describe('with empty successful request', () => {
      let mock;

      beforeEach(() => {
        mock = mock = new MockAdapter(axios);
        mock.onGet('path.json').reply(200, []);
        vm = mountComponent(Component);
      });

      afterEach(() => {
        mock.reset();
      });

      it('should render provided data', (done) => {
        setTimeout(() => {
          expect(
            vm.$el.querySelector('.js-sast-widget .js-code-text').textContent.trim(),
          ).toEqual('SAST detected no security vulnerabilities');
          done();
        }, 0);
      });
    });

    describe('with failed request', () => {
      let mock;

      beforeEach(() => {
        mock = mock = new MockAdapter(axios);
        mock.onGet('path.json').reply(500, []);
        vm = mountComponent(Component);
      });

      afterEach(() => {
        mock.reset();
      });

      it('should render error indicator', (done) => {
        setTimeout(() => {
          expect(
            vm.$el.querySelector('.js-sast-widget').textContent.trim(),
          ).toContain('Failed to load security report');
          done();
        }, 0);
      });
    });
  });

  describe('code quality', () => {
    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        codeclimate: {
          head_path: 'head.json',
          base_path: 'base.json',
        },
      };

      Component.mr = new MRWidgetStore(gl.mrWidgetData);
      Component.service = new MRWidgetService({});
    });

    describe('when it is loading', () => {
      it('should render loading indicator', () => {
        vm = mountComponent(Component);
        expect(
          vm.$el.querySelector('.js-codequality-widget').textContent.trim(),
        ).toContain('Loading codeclimate report');
      });
    });

    describe('with successful request', () => {
      let mock;

      beforeEach(() => {
        mock = mock = new MockAdapter(axios);
        mock.onGet('head.json').reply(200, headIssues);
        mock.onGet('base.json').reply(200, baseIssues);
        vm = mountComponent(Component);
      });

      afterEach(() => {
        mock.reset();
      });

      it('should render provided data', (done) => {
        setTimeout(() => {
          expect(
            vm.$el.querySelector('.js-code-text').textContent.trim(),
          ).toEqual('Code quality improved on 1 point and degraded on 1 point');
          done();
        }, 0);
      });

      describe('text connector', () => {
        it('should only render information about fixed issues', (done) => {
          setTimeout(() => {
            vm.mr.codeclimateMetrics.newIssues = [];

            Vue.nextTick(() => {
              expect(
                vm.$el.querySelector('.js-code-text').textContent.trim(),
              ).toEqual('Code quality improved on 1 point');
              done();
            });
          }, 0);
        });

        it('should only render information about added issues', (done) => {
          setTimeout(() => {
            vm.mr.codeclimateMetrics.resolvedIssues = [];
            Vue.nextTick(() => {
              expect(
                vm.$el.querySelector('.js-code-text').textContent.trim(),
              ).toEqual('Code quality degraded on 1 point');
              done();
            });
          }, 0);
        });
      });
    });

    describe('with empty successful request', () => {
      let mock;

      beforeEach(() => {
        mock = mock = new MockAdapter(axios);
        mock.onGet('head.json').reply(200, []);
        mock.onGet('base.json').reply(200, []);
        vm = mountComponent(Component);
      });

      afterEach(() => {
        mock.reset();
      });

      it('should render provided data', (done) => {
        setTimeout(() => {
          expect(
            vm.$el.querySelector('.js-code-text').textContent.trim(),
          ).toEqual('No changes to code quality');
          done();
        }, 0);
      });
    });

    describe('with failed request', () => {
      let mock;

      beforeEach(() => {
        mock = mock = new MockAdapter(axios);
        mock.onGet('head.json').reply(500, []);
        mock.onGet('base.json').reply(500, []);
        vm = mountComponent(Component);
      });

      afterEach(() => {
        mock.reset();
      });

      it('should render error indicator', (done) => {
        setTimeout(() => {
          expect(vm.$el.querySelector('.js-codequality-widget').textContent.trim()).toContain('Failed to load codeclimate report');
          done();
        }, 0);
      });
    });
  });

  describe('performance', () => {
    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        performance: {
          head_path: 'head.json',
          base_path: 'base.json',
        },
      };

      Component.mr = new MRWidgetStore(gl.mrWidgetData);
      Component.service = new MRWidgetService({});
    });

    describe('when it is loading', () => {
      it('should render loading indicator', () => {
        vm = mountComponent(Component);
        expect(
          vm.$el.querySelector('.js-performance-widget').textContent.trim(),
        ).toContain('Loading performance report');
      });
    });

    describe('with successful request', () => {
      let mock;

      beforeEach(() => {
        mock = mock = new MockAdapter(axios);
        mock.onGet('head.json').reply(200, headPerformance);
        mock.onGet('base.json').reply(200, basePerformance);
        vm = mountComponent(Component);
      });

      afterEach(() => {
        mock.reset();
      });

      it('should render provided data', (done) => {
        setTimeout(() => {
          expect(
            vm.$el.querySelector('.js-performance-widget .js-code-text').textContent.trim(),
          ).toEqual('Performance metrics improved on 1 point and degraded on 1 point');
          done();
        }, 0);
      });

      describe('text connector', () => {
        it('should only render information about fixed issues', (done) => {
          setTimeout(() => {
            vm.mr.performanceMetrics.degraded = [];

            Vue.nextTick(() => {
              expect(
                vm.$el.querySelector('.js-performance-widget .js-code-text').textContent.trim(),
              ).toEqual('Performance metrics improved on 1 point');
              done();
            });
          }, 0);
        });

        it('should only render information about added issues', (done) => {
          setTimeout(() => {
            vm.mr.performanceMetrics.improved = [];

            Vue.nextTick(() => {
              expect(
                vm.$el.querySelector('.js-performance-widget .js-code-text').textContent.trim(),
              ).toEqual('Performance metrics degraded on 1 point');
              done();
            });
          }, 0);
        });
      });
    });

    describe('with empty successful request', () => {
      let mock;

      beforeEach(() => {
        mock = mock = new MockAdapter(axios);
        mock.onGet('head.json').reply(200, []);
        mock.onGet('base.json').reply(200, []);
        vm = mountComponent(Component);
      });

      afterEach(() => {
        mock.reset();
      });

      it('should render provided data', (done) => {
        setTimeout(() => {
          expect(
            vm.$el.querySelector('.js-performance-widget .js-code-text').textContent.trim(),
          ).toEqual('No changes to performance metrics');
          done();
        }, 0);
      });
    });

    describe('with failed request', () => {
      let mock;

      beforeEach(() => {
        mock = mock = new MockAdapter(axios);
        mock.onGet('head.json').reply(500, []);
        mock.onGet('base.json').reply(500, []);
        vm = mountComponent(Component);
      });

      afterEach(() => {
        mock.reset();
      });

      it('should render error indicator', (done) => {
        setTimeout(() => {
          expect(vm.$el.querySelector('.js-performance-widget').textContent.trim()).toContain('Failed to load performance report');
          done();
        }, 0);
      });
    });
  });

  describe('docker report', () => {
    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        sast_container: {
          path: 'gl-sast-container.json',
          blob_path: 'blob_path',
        },
      };

      Component.mr = new MRWidgetStore(gl.mrWidgetData);
      Component.service = new MRWidgetService({});
    });

    describe('when it is loading', () => {
      it('should render loading indicator', () => {
        vm = mountComponent(Component);

        expect(
          vm.$el.querySelector('.js-docker-widget').textContent.trim(),
        ).toContain('Loading sast:container report');
      });
    });

    describe('with successful request', () => {
      let mock;

      beforeEach(() => {
        mock = mock = new MockAdapter(axios);
        mock.onGet('gl-sast-container.json').reply(200, dockerReport);
        vm = mountComponent(Component);
      });

      afterEach(() => {
        mock.reset();
      });

      it('should render provided data', (done) => {
        setTimeout(() => {
          expect(
            vm.$el.querySelector('.js-docker-widget .js-code-text').textContent.trim(),
          ).toEqual('SAST:container found 3 vulnerabilities, of which 1 is approved');

          vm.$el.querySelector('.js-docker-widget button').click();

          Vue.nextTick(() => {
            expect(
              vm.$el.querySelector('.js-docker-widget .mr-widget-code-quality-info').textContent.trim(),
            ).toContain('Unapproved vulnerabilities (red) can be marked as approved.');
            expect(
              vm.$el.querySelector('.js-docker-widget .mr-widget-code-quality-info a').textContent.trim(),
            ).toContain('Learn more about whitelisting');

            const firstVulnerability = vm.$el.querySelector('.js-docker-widget .mr-widget-code-quality-list').textContent.trim();

            expect(firstVulnerability).toContain(dockerReportParsed.unapproved[0].name);
            expect(firstVulnerability).toContain(dockerReportParsed.unapproved[0].path);
            done();
          });
        }, 0);
      });
    });

    describe('with failed request', () => {
      let mock;

      beforeEach(() => {
        mock = mock = new MockAdapter(axios);
        mock.onGet('gl-sast-container.json').reply(500, {});
        vm = mountComponent(Component);
      });

      afterEach(() => {
        mock.reset();
      });

      it('should render error indicator', (done) => {
        setTimeout(() => {
          expect(
            vm.$el.querySelector('.js-docker-widget').textContent.trim(),
          ).toContain('Failed to load sast:container report');
          done();
        }, 0);
      });
    });
  });

  describe('dast report', () => {
    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        dast: {
          path: 'dast.json',
        },
      };

      Component.mr = new MRWidgetStore(gl.mrWidgetData);
      Component.service = new MRWidgetService({});
    });

    describe('when it is loading', () => {
      it('should render loading indicator', () => {
        vm = mountComponent(Component);

        expect(
          vm.$el.querySelector('.js-dast-widget').textContent.trim(),
        ).toContain('Loading DAST report');
      });
    });

    describe('with successful request', () => {
      let mock;

      beforeEach(() => {
        mock = mock = new MockAdapter(axios);
        mock.onGet('dast.json').reply(200, dast);
        vm = mountComponent(Component);
      });

      afterEach(() => {
        mock.reset();
      });

      it('should render provided data', (done) => {
        setTimeout(() => {
          expect(
            vm.$el.querySelector('.js-dast-widget .js-code-text').textContent.trim(),
          ).toEqual('DAST detected 2 alerts by analyzing the review app');

          vm.$el.querySelector('.js-dast-widget button').click();

          Vue.nextTick(() => {
            const firstVulnerability = vm.$el.querySelector('.js-dast-widget .mr-widget-code-quality-list').textContent.trim();
            expect(firstVulnerability).toContain(parsedDast[0].name);
            expect(firstVulnerability).toContain(parsedDast[0].priority);
            done();
          });
        }, 0);
      });
    });

    describe('with failed request', () => {
      let mock;

      beforeEach(() => {
        mock = mock = new MockAdapter(axios);
        mock.onGet('dast.json').reply(500, {});
        vm = mountComponent(Component);
      });

      afterEach(() => {
        mock.reset();
      });

      it('should render error indicator', (done) => {
        setTimeout(() => {
          expect(
            vm.$el.querySelector('.js-dast-widget').textContent.trim(),
          ).toContain('Failed to load DAST report');
          done();
        }, 0);
      });
    });
  });

  describe('computed', () => {
    describe('shouldRenderApprovals', () => {
      it('should return false when no approvals', () => {
        vm = mountComponent(Component, {
          mrData: {
            ...mockData,
            approvalsRequired: false,
          },
        });
        vm.mr.state = 'readyToMerge';

        expect(vm.shouldRenderApprovals).toBeFalsy();
      });

      it('should return false when in empty state', () => {
        vm = mountComponent(Component, {
          mrData: {
            ...mockData,
            approvalsRequired: true,
          },
        });
        vm.mr.state = 'nothingToMerge';

        expect(vm.shouldRenderApprovals).toBeFalsy();
      });

      it('should return true when requiring approvals and in non-empty state', () => {
        vm = mountComponent(Component, {
          mrData: {
            ...mockData,
            approvalsRequired: true,
          },
        });
        vm.mr.state = 'readyToMerge';

        expect(vm.shouldRenderApprovals).toBeTruthy();
      });
    });

    describe('dockerText', () => {
      beforeEach(() => {
        vm = mountComponent(Component, {
          mrData: {
            ...mockData,
            sast_container: {
              path: 'foo',
            },
          },
        });
      });

      describe('with no vulnerabilities', () => {
        it('returns No vulnerabilities found', () => {
          expect(vm.dockerText).toEqual('SAST:container no vulnerabilities were found');
        });
      });

      describe('without unapproved vulnerabilities', () => {
        it('returns approved information - single', () => {
          vm.mr.dockerReport = {
            vulnerabilities: [{
              vulnerability: 'CVE-2017-12944',
              namespace: 'debian:8',
              severity: 'Medium',
            }],
            approved: [{
              vulnerability: 'CVE-2017-12944',
              namespace: 'debian:8',
              severity: 'Medium',
            }],
            unapproved: [],
          };
          expect(vm.dockerText).toEqual('SAST:container found 1 approved vulnerability');
        });

        it('returns approved information - plural', () => {
          vm.mr.dockerReport = {
            vulnerabilities: [{
              vulnerability: 'CVE-2017-12944',
              namespace: 'debian:8',
              severity: 'Medium',
            }],
            approved: [
              {
                vulnerability: 'CVE-2017-12944',
                namespace: 'debian:8',
                severity: 'Medium',
              },
              {
                vulnerability: 'CVE-2017-13726',
                namespace: 'debian:8',
                severity: 'Medium',
              },
            ],
            unapproved: [],
          };
          expect(vm.dockerText).toEqual('SAST:container found 2 approved vulnerabilities');
        });
      });

      describe('with only unapproved vulnerabilities', () => {
        it('returns number of vulnerabilities - single', () => {
          vm.mr.dockerReport = {
            vulnerabilities: [{
              vulnerability: 'CVE-2017-12944',
              namespace: 'debian:8',
              severity: 'Medium',
            }],
            unapproved: [
              {
                vulnerability: 'CVE-2017-12944',
                namespace: 'debian:8',
                severity: 'Medium',
              },
            ],
            approved: [],
          };
          expect(vm.dockerText).toEqual('SAST:container found 1 vulnerability');
        });

        it('returns number of vulnerabilities - plural', () => {
          vm.mr.dockerReport = {
            vulnerabilities: [{
              vulnerability: 'CVE-2017-12944',
              namespace: 'debian:8',
              severity: 'Medium',
            }],
            unapproved: [
              {
                vulnerability: 'CVE-2017-12944',
                namespace: 'debian:8',
                severity: 'Medium',
              },
              {
                vulnerability: 'CVE-2017-12944',
                namespace: 'debian:8',
                severity: 'Medium',
              },
            ],
            approved: [],
          };
          expect(vm.dockerText).toEqual('SAST:container found 2 vulnerabilities');
        });
      });

      describe('with approved and unapproved vulnerabilities', () => {
        it('returns message with information about both - single', () => {
          vm.mr.dockerReport = {
            vulnerabilities: [{
              vulnerability: 'CVE-2017-12944',
              namespace: 'debian:8',
              severity: 'Medium',
            }],
            unapproved: [
              {
                vulnerability: 'CVE-2017-12944',
                namespace: 'debian:8',
                severity: 'Medium',
              },
            ],
            approved: [
              {
                vulnerability: 'CVE-2017-12944',
                namespace: 'debian:8',
                severity: 'Medium',
              },
            ],
          };

          expect(vm.dockerText).toEqual('SAST:container found 1 vulnerability, of which 1 is approved');
        });

        it('returns message with information about both - plural', () => {
          vm.mr.dockerReport = {
            vulnerabilities: [
              {
                vulnerability: 'CVE-2017-12944',
                namespace: 'debian:8',
                severity: 'Medium',
              },
              {
                vulnerability: 'CVE-2017-12944',
                namespace: 'debian:8',
                severity: 'Medium',
              },
            ],
            unapproved: [
              {
                vulnerability: 'CVE-2017-12944',
                namespace: 'debian:8',
                severity: 'Medium',
              },
              {
                vulnerability: 'CVE-2017-12923',
                namespace: 'debian:8',
                severity: 'Medium',
              },
            ],
            approved: [
              {
                vulnerability: 'CVE-2017-12944',
                namespace: 'debian:8',
                severity: 'Medium',
              },
              {
                vulnerability: 'CVE-2017-13944',
                namespace: 'debian:8',
                severity: 'Medium',
              },
            ],
          };
          expect(vm.dockerText).toEqual('SAST:container found 2 vulnerabilities, of which 2 are approved');
        });
      });
    });
  });
});
