import { shallowMount } from '@vue/test-utils';
import { GlLoadingIcon, GlAlert } from '@gitlab/ui';
import Incident from '~/incidents/components/incident_details.vue';

describe('Incidents Details', () => {
  let wrapper;

  const findIncidentTitle = () => wrapper.find('[data-testid="incident-title"]');
  const findLoader = () => wrapper.find(GlLoadingIcon);
  const findAlert = () => wrapper.find(GlAlert);

  function mountComponent({ data = { incident: {} }, loading = false }) {
    wrapper = shallowMount(Incident, {
      data() {
        return data;
      },
      mocks: {
        $apollo: {
          queries: {
            incident: {
              loading,
            },
          },
        },
      },
      provide: {
        projectPath: '/project/path',
        incidentId: '1',
      },
    });
  }

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  it('shows the loading state', () => {
    mountComponent({
      loading: true,
    });
    expect(findLoader().exists()).toBe(true);
  });

  it('shows error state', () => {
    mountComponent({
      data: { incident: {}, errored: true },
      loading: false,
    });
    expect(findIncidentTitle().exists()).toBe(false);
    expect(findAlert().exists()).toBe(true);
  });

  it('displays incident title', () => {
    const incident = [{ title: 1 }];
    mountComponent({
      data: { incident },
      loading: false,
    });
    expect(findIncidentTitle().exists()).toBe(true);
  });
});
