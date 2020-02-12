import getSha from '../queries/getSha.query.graphql';

export default {
  apollo: {
    sha: {
      query: getSha,
    },
  },
  data() {
    return {
      sha: '',
    };
  },
};
