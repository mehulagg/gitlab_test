import GetSnippetQuery from '../queries/snippet.query.graphql';

const blobsDefault = [];

export const getSnippetMixin = {
  apollo: {
    snippet: {
      query: GetSnippetQuery,
      variables() {
        return {
          ids: this.snippetGid,
        };
      },
      update: data => {
        const res = data.snippets.edges[0]?.node;
        const blobs = res.blobs.edges;

        if (blobs) {
          res.blobs = blobs.map(blob => blob.node);
        }

        return res;
      },
      result(res) {
        this.blobs = res.data.snippets.edges[0]?.node?.blobs || blobsDefault;
        if (this.onSnippetFetch) {
          this.onSnippetFetch(res);
        }
      },
    },
  },
  props: {
    snippetGid: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      snippet: {},
      newSnippet: false,
      blobs: blobsDefault,
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.snippet.loading;
    },
  },
};
