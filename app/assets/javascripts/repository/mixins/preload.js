import getFiles from '../queries/getFiles.query.graphql';
import getShaMixin from './get_sha';
import getProjectPath from '../queries/getProjectPath.query.graphql';

export default {
  mixins: [getShaMixin],
  apollo: {
    projectPath: {
      query: getProjectPath,
    },
  },
  data() {
    return { projectPath: '', loadingPath: null };
  },
  beforeRouteUpdate(to, from, next) {
    this.preload(to.params.path, next);
  },
  methods: {
    preload(path = '/', next) {
      this.loadingPath = path.replace(/^\//, '');

      return this.$apollo
        .query({
          query: getFiles,
          variables: {
            projectPath: this.projectPath,
            ref: this.sha,
            path: this.loadingPath,
            nextPageCursor: '',
            pageSize: 100,
          },
        })
        .then(() => next());
    },
  },
};
