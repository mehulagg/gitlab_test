import Api from '~/api';
import axios from '~/lib/utils/axios_utils';

const elasticsearchPath = '/api/:version/elasticsearch_indices';
export default {
  applicationSettingsPath: '/api/:version/application/settings',
  elasticsearchPath,

  elasticsearchIndexPath: `${elasticsearchPath}/:id`,
  elasticsearchSearchSourcePath: `${elasticsearchPath}/mark_active_search_source/:id`,
  elasticsearchReindexPath: `${elasticsearchPath}/reindex`,
  elasticsearchTogglePath: `${elasticsearchPath}/toggle_indexing`,

  getApplicationSettings() {
    const url = Api.buildUrl(this.applicationSettingsPath);
    return axios.get(url);
  },

  getIndices() {
    const url = Api.buildUrl(this.elasticsearchPath);
    return axios.get(url);
  },

  createNewIndex(indexData) {
    const url = Api.buildUrl(this.elasticsearchPath);
    return axios.post(url, indexData);
  },

  getIndex(id) {
    const url = Api.buildUrl(this.elasticsearchIndexPath).replace(':id', id);
    return axios.get(url);
  },

  updateIndex(id, indexData) {
    const url = Api.buildUrl(this.elasticsearchIndexPath).replace(':id', id);
    return axios.put(url, indexData);
  },

  removeIndex(id, newSourceId) {
    // newSourceId is not being used yet but will later when one can remove active search source.
    const url = Api.buildUrl(this.elasticsearchIndexPath).replace(':id', id);
    return axios.delete(url);
  },

  switchSearchSource(id) {
    const url = Api.buildUrl(this.elasticsearchSearchSourcePath).replace(':id', id);
    return axios.post(url);
  },

  reindexGlobally() {
    const url = Api.buildUrl(this.elasticsearchReindexPath);
    return axios.post(url);
  },

  toggleIndexingGlobally(indexing) {
    const url = Api.buildUrl(this.elasticsearchTogglePath);
    return axios.post(url, { indexing });
  },
};
