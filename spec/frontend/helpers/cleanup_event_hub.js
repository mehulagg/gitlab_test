import eventHubFactory from '~/helpers/event_hub_factory';

jest.mock('~/helpers/event_hub_factory');

const realEventHubFactory = jest.requireActual('~/helpers/event_hub_factory').default;

let eventHubInstances = [];

eventHubFactory.mockImplementation(() => {
  const instance = realEventHubFactory();

  eventHubInstances.push(instance);

  return instance;
});

afterEach(() => {
  eventHubInstances.forEach(x => {
    x.dispose();
  });
  eventHubInstances = [];
});
