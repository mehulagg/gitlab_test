import 'global-jsdom/es/register';
import hypernova from 'hypernova/server';
import RelatedMergeRequestsSSR from './app/assets/javascripts/related_merge_requests/ssr';

hypernova({
  devMode: true,
  getComponent(name) {
    if (name === 'RelatedMergeRequests') {
      return RelatedMergeRequestsSSR();
    }

    return null;
  },
  port: 3030,
});
