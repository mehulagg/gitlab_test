import renderVuex from '../hypernova_vue';
import createStore from './store';
import RelatedMergeRequests from './components/related_merge_requests.vue';

export default () => renderVuex('RelatedMergeRequests', RelatedMergeRequests, createStore);
