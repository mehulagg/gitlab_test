<script>
import { GlLoadingIcon } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import EsIndexBodyAdvanced from './es_index_body_advanced.vue';

export default {
  components: {
    Icon,
    GlLoadingIcon,
    EsIndexBodyAdvanced,
  },
  props: {
    index: {
      type: Object,
      required: true,
    },
  },
  computed: {
    urls() {
      const urlsArray = this.index.urls && this.index.urls.split(/[\s,]+/);
      return urlsArray.map(
        url =>
          `${url[url.length - 1] === '/' ? url.substring(0, url.length - 1) : url}/${
            this.index.name
          }`,
      );
    },
  },
};
</script>
<template>
  <div class="card-body px-0 pb-0">
    <dl class="px-3">
      <dt class="font-weight-normal text-secondary">{{ s__('Elasticsearch|URLs') }}:</dt>
      <dd class="font-weight-bold">
        <div v-for="(url, index) in urls" :key="index">{{ url }}</div>
      </dd>

      <!--      <dt class="font-weight-normal text-secondary">{{ s__('Elasticsearch|Index status:') }}</dt>-->
      <!--      <dd class="font-weight-bold">-->
      <!--        <span-->
      <!--          v-if="index.indexed !== undefined"-->
      <!--          class="d-flex align-items-center"-->
      <!--          :class="index.indexed ? 'text-success' : undefined"-->
      <!--        >-->
      <!--          <icon :name="index.indexed ? 'status_success' : 'status_warning'" class="mr-1" />-->
      <!--          <span-->
      <!--            v-html="-->
      <!--              index.indexed-->
      <!--                ? s__('Elasticsearch|Fully indexed')-->
      <!--                : s__('Elasticsearch|Not indexed yet')-->
      <!--            "-->
      <!--          ></span>-->
      <!--        </span>-->
      <!--        <gl-loading-icon v-else inline />-->
      <!--      </dd>-->
    </dl>
    <hr class="my-3" />
    <es-index-body-advanced class="px-3 mb-3" :index="index" />
  </div>
</template>
