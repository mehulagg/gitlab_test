import axios from '~/lib/utils/axios_utils';
import Api from '~/api';

export default class GroupsService {
  constructor(endpoint) {
    this.endpoint = endpoint;
  }

  getGroups(parentId, page, filterGroups, sort, archived) {
    const params = {};

    if (parentId) {
      params.parent_id = parentId;
    } else {
      // Do not send the following param for sub groups
      if (page) {
        params.page = page;
      }

      if (filterGroups) {
        params.filter = filterGroups;
      }
    }

    return axios.get(this.endpoint, { params });
  }
}
