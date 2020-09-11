import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import setupAxiosStartupCalls from '~/lib/utils/axios_startup_calls';

describe('setupAxiosStartupCalls', () => {
  const AXIOS_RESPONSE = { text: 'AXIOS_RESPONSE' };
  const STARTUP_JS_RESPONSE = { text: 'STARTUP_JS_RESPONSE' };
  let mock;

  function mockFetchCall(status) {
    const p = {
      ok: status >= 200 && status < 300,
      status,
      headers: new Headers({ 'Content-Type': 'application/json' }),
      statusText: `MOCK-FETCH ${status}`,
      clone: () => p,
      json: () => Promise.resolve(STARTUP_JS_RESPONSE),
    };
    return Promise.resolve(p);
  }

  beforeEach(() => {
    window.gl = {};
    mock = new MockAdapter(axios);
    mock.onGet('/non-startup').reply(200, AXIOS_RESPONSE);
    mock.onGet('/startup').reply(200, AXIOS_RESPONSE);
    mock.onGet('/startup-failing').reply(200, AXIOS_RESPONSE);
  });

  afterEach(() => {
    delete window.gl;
    axios.interceptors.request.handlers = [];
    mock.restore();
  });

  it('if no startupCalls are registered: does not register a request interceptor', () => {
    setupAxiosStartupCalls(axios);

    expect(axios.interceptors.request.handlers.length).toBe(0);
  });

  describe('if startupCalls are registered', () => {
    beforeEach(() => {
      window.gl.startup_calls = {
        '/startup': {
          fetchCall: mockFetchCall(200),
        },
        '/startup-failing': {
          fetchCall: mockFetchCall(400),
        },
      };
      setupAxiosStartupCalls(axios);
    });

    it('registers a request interceptor', () => {
      expect(axios.interceptors.request.handlers.length).toBe(1);
    });

    it('delegates to startup calls if URL is registered and call is successful', async () => {
      const { headers, data, status, statusText } = await axios.get('/startup');

      expect(headers).toEqual({ 'content-type': 'application/json' });
      expect(status).toBe(200);
      expect(statusText).toBe('MOCK-FETCH 200');
      expect(data).toEqual(STARTUP_JS_RESPONSE);
      expect(data).not.toEqual(AXIOS_RESPONSE);
    });

    it('delegates to startup calls exactly once', async () => {
      await axios.get('/startup');
      const { data } = await axios.get('/startup');

      expect(data).not.toEqual(STARTUP_JS_RESPONSE);
      expect(data).toEqual(AXIOS_RESPONSE);
    });

    it('does not delegate to startup calls if the call is failing', async () => {
      const { data } = await axios.get('/startup-failing');

      expect(data).not.toEqual(STARTUP_JS_RESPONSE);
      expect(data).toEqual(AXIOS_RESPONSE);
    });

    it('does not delegate to startup call if URL is not registered', async () => {
      const { data } = await axios.get('/non-startup');

      expect(data).toEqual(AXIOS_RESPONSE);
      expect(data).not.toEqual(STARTUP_JS_RESPONSE);
    });
  });
});
