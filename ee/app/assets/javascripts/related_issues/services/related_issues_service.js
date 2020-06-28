import axios from '~/lib/utils/axios_utils';
import { linkedIssueTypesMap } from '../constants';

class RelatedIssuesService {
  constructor(endpoint) {
    this.endpoint = endpoint;
  }

  fetchRelatedIssues() {
    return axios.get(this.endpoint).then(({ data }) => data);
  }

  addRelatedIssues(newIssueReferences, linkType = linkedIssueTypesMap.RELATES_TO) {
    return axios
      .post(this.endpoint, {
        issuable_references: newIssueReferences,
        link_type: linkType,
      })
      .then(({ data }) => data.issuables);
  }

  // Use a class method here so that it can be overridden by a sub-class.
  // eslint-disable-next-line class-methods-use-this
  remove(issue) {
    return axios.delete(issue.relationPath).then(({ data }) => data.issuables);
  }

  // Use a class method here so that it can be overridden by a sub-class.
  // eslint-disable-next-line class-methods-use-this
  saveOrder({ issue, move_before_id, move_after_id }) {
    return axios.put(issue.relationPath, {
      epic: {
        move_before_id,
        move_after_id,
      },
    });
  }
}

export default RelatedIssuesService;
