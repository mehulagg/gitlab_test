import MockAdapter from 'axios-mock-adapter';
import { useMockIntersectionObserver } from 'helpers/mock_dom_observer';
import waitForPromises from 'helpers/wait_for_promises';
import axios from '~/lib/utils/axios_utils';
import initIncidentApp from '~/issue_show/incident';
import * as parseData from '~/issue_show/utils/parse_data';
import { appProps } from '../issue_show/mock_data';

const mock = new MockAdapter(axios);
mock.onGet().reply(200);

useMockIntersectionObserver();

jest.mock('~/lib/utils/poll');

const setupHTML = initialData => {
  document.body.innerHTML = `
    <div id="js-issuable-app"></div>
    <script id="js-issuable-app-initial-data" type="application/json">
      ${JSON.stringify(initialData)}
    </script>
  `;
};

describe('Incident show index', () => {
  describe('initIssueableApp', () => {
    it('should initialize app with no potential XSS attack', async () => {
      const alertSpy = jest.spyOn(window, 'alert').mockImplementation(() => {});
      const parseDataSpy = jest.spyOn(parseData, 'parseIssuableData');

      setupHTML({
        ...appProps,
        initialDescriptionHtml: '<svg onload=window.alert(1)>',
      });

      const issuableData = parseData.parseIssuableData();
      initIncidentApp(issuableData);

      await waitForPromises();

      expect(parseDataSpy).toHaveBeenCalled();
      expect(alertSpy).not.toHaveBeenCalled();
    });
  });
});
