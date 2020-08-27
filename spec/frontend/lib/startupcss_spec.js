import StartupCSS from '~/lib/startupcss';

let startupCSS;
let startupComplete;
const fixtures =
  '<link media="all" href="example.css" data-startupcss="loading"><link media="print" href="other.css" data-startupcss="loading">';

describe('StartupCSS', () => {
  beforeEach(() => {
    setFixtures(fixtures);
    startupCSS = new StartupCSS();
    jest.spyOn(startupCSS, 'complete');
  });

  it('dispaches event when loading is complete', () => {
    const docDispatch = jest.spyOn(document, 'dispatchEvent');

    startupCSS.complete();

    expect(startupCSS.links.length).toBe(2);
    expect(docDispatch).toHaveBeenCalled();
  });

  it('calls complete() when only some link tags have been loaded', () => {
    startupComplete = jest.spyOn(startupCSS, 'complete');

    // Only 1 of 2
    document
      .querySelectorAll('[data-startupcss="loading"]')[0]
      .setAttribute('data-startupcss', 'loaded');

    startupCSS.handleIndividualActivation();

    expect(startupComplete).not.toHaveBeenCalled();
  });

  it('calls complete() when all link tags have been loaded', () => {
    startupComplete = jest.spyOn(startupCSS, 'complete');

    // All 2 of 2
    document
      .querySelectorAll('[data-startupcss="loading"]')
      .forEach(el => el.setAttribute('data-startupcss', 'loaded'));

    startupCSS.handleIndividualActivation();

    expect(startupComplete).toHaveBeenCalled();
  });
});

describe('StartupCSS Feature state', () => {
  beforeEach(() => {
    setFixtures(fixtures);
  });

  describe('is disabled', () => {
    // Controlled by the constant: STARTUPCSS_EVENT_IF_DISABLED
    it('sets an event listener', () => {
      window.gl = {};
      const docListener = jest.spyOn(document, 'addEventListener');
      startupCSS = new StartupCSS();

      expect(docListener).toHaveBeenCalled();
    });
  });

  describe('is enabled', () => {
    it('sets an event listener', () => {
      window.gl = {
        startupcssEnabled: true,
      };
      const docListener = jest.spyOn(document, 'addEventListener');
      startupCSS = new StartupCSS();

      expect(docListener).toHaveBeenCalled();
    });
  });
});
