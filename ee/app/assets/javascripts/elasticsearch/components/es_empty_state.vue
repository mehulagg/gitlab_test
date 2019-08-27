<script>
import ElasticsearchEmptyStateIllustration from '@gitlab/svgs/dist/illustrations/elasticsearch-lg.svg';
import { GlNewButton } from '@gitlab/ui';

export default {
  components: {
    GlNewButton,
  },
  created() {
    this.emptyStateIllustration = ElasticsearchEmptyStateIllustration;
  },
  methods: {
    routeToNewIndex() {
      this.$router.push({ name: 'newIndexPath' });
    },
  },
};
</script>

<template>
  <div class="row empty-state">
    <div class="col-12 svg-content" v-html="emptyStateIllustration"></div>
    <div class="col-12">
      <div class="text-content text-center">
        <h4>{{ s__('Elasticsearch|Get started with Elasticsearch in GitLab') }}</h4>
        <p>
          {{
            s__(
              'Elasticsearch|Use Elasticsearch to improve the search functionality inside of GitLab and enable Advanced Global Search.',
            )
          }}
        </p>
        <div>
          <gl-new-button
            :title="s__('Elasticsearch|Create GitLab index')"
            class="btn btn-success qa-new-node-link"
            @click="routeToNewIndex"
            data-qa-selector="es_empty_new"
          >
            {{ s__('Elasticsearch|Create GitLab index') }} </gl-new-button
          ><gl-new-button
            href="https://docs.gitlab.com/ee/integration/elasticsearch.html"
            rel="nofollow"
            class="btn"
            target="_blank"
          >
            {{ __('Learn more') }}
          </gl-new-button>
        </div>
      </div>
    </div>
  </div>
</template>
