import { isEmpty } from 'lodash';
import { mergeUrlParams } from './url_utility';

// We should probably not couple this utility to `gon.gitlab_url`
// Also, this would replace occurrences that aren't at the beginning of the string
const removeGitLabUrl = url => url.replace(gon.gitlab_url, '');

const getFullUrl = req => {
  const url = removeGitLabUrl(req.url);
  return mergeUrlParams(req.params || {}, url);
};

const setupAxiosStartupCalls = axios => {
  const { startup_calls: startupCalls } = window.gl || {};

  if (!startupCalls || isEmpty(startupCalls)) {
    return;
  }

  // TODO: To save performance of future axios calls, we can
  // remove this interceptor once the "startupCalls" have been loaded
  axios.interceptors.request.use(async req => {
    const fullUrl = getFullUrl(req);

    const existing = startupCalls[fullUrl];

    if (existing && existing.fetchCall) {
      try {
        const res = await existing.fetchCall;
        if (!res.ok) {
          throw new Error(res.statusText);
        }

        const fetchHeaders = {};
        res.headers.forEach((val, key) => {
          fetchHeaders[key] = val;
        });

        const data = await res.clone().json();

        // eslint-disable-next-line no-param-reassign
        req.adapter = () =>
          Promise.resolve({
            data,
            status: res.status,
            statusText: res.statusText,
            headers: fetchHeaders,
            config: req,
            request: req,
          });
      } catch (e) {
        // Something went wrong with the startup call
      }

      delete startupCalls[fullUrl];
    }

    return req;
  });
};

export default setupAxiosStartupCalls;
