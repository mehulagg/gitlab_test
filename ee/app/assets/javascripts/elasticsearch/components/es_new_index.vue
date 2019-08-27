<script>
import { mapActions, mapState } from 'vuex';
import {
  GlButton,
  GlFormInput,
  GlFormGroup,
  GlFormCheckbox,
  GlFormSelect,
  GlLoadingIcon,
  GlAlert,
} from '@gitlab/ui';
import Service from '../service/elasticsearch_service';
import * as utils from '../utils';

import { s__, sprintf } from '~/locale';

export default {
  components: {
    GlButton,
    GlFormInput,
    GlFormGroup,
    GlFormCheckbox,
    GlFormSelect,
    GlLoadingIcon,
    GlAlert,
  },
  props: {
    indexid: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      shards: 5,
      replicas: 1,
      aws: false,
      friendly_name: '',
      urls: '',
      aws_region: 'us-east-1',
      aws_access_key: '',
      aws_secret_access_key: '',

      isAdding: false,
      formErrors: {},
      isAlertDismissed: false,
      awsRegionOptions: [
        'us-east-2',
        'us-east-1',
        'us-west-1',
        'us-west-2',
        'ap-east-1',
        'ap-south-1',
        'ap-northeast-3',
        'ap-northeast-2',
        'ap-southeast-1',
        'ap-southeast-2',
        'ap-northeast-1',
        'ca-central-1',
        'eu-central-1',
        'eu-west-1',
        'eu-west-2',
        'eu-west-3',
        'eu-north-1',
        'me-south-1',
        'sa-east-1',
      ],
    };
  },
  computed: {
    ...mapState(['indices']),
    disabledHelpText() {
      return sprintf(
        s__(
          'Elasticsearch|Changing this setting via API can destroy your GitLab index. To change the number of shards you have to %{linkStart}create a new GitLab index%{linkEnd}.',
        ),
        { linkStart: '<a href="/admin/elasticsearch/new" target="_blank">', linkEnd: '</a>' },
        false,
      );
    },
    baseErrorMessage() {
      return this.formErrors.base && this.formErrors.base.join(', ');
    },
  },
  created() {
    if (this.indexid) {
      let existingIndex = this.indices.find(i => i.id === parseInt(this.indexid, 10));
      const applyData = data => {
        ({
          shards: this.shards,
          replicas: this.replicas,
          aws: this.aws,
          friendly_name: this.friendly_name,
          urls: this.urls,
          aws_region: this.aws_region,
          aws_access_key: this.aws_access_key,
          aws_secret_access_key: this.aws_secret_access_key,
        } = data);
      };
      if (!existingIndex) {
        Service.getIndex(this.indexid)
          .then(({ data }) => {
            applyData(data);
          })
          .catch(({ response }) => {
            this.formErrors = utils.fetchErrorData(response);
          });
      } else {
        applyData(existingIndex);
      }
    }
  },
  methods: {
    ...mapActions(['updateIndices']),
    createIndex() {
      this.isAdding = true;
      const indexData = {
        shards: this.shards,
        replicas: this.replicas,
        aws: this.aws,
        friendly_name: this.friendly_name,
        urls: this.urls,
        aws_region: this.aws_region,
        aws_access_key: this.aws_access_key,
        aws_secret_access_key: this.aws_secret_access_key,
      };
      if (this.indexid) {
        Service.updateIndex(this.indexid, indexData)
          .then(({ data }) => {
            const existingIndex = this.indices.findIndex(i => i.id === data.id);
            const updatedIndices = [].concat(this.indices);
            Object.assign(updatedIndices[existingIndex], data);

            this.updateIndices(updatedIndices);
            this.$router.push({ name: 'root' });
          })
          .catch(({ response }) => {
            this.formErrors = utils.fetchErrorData(response);
            this.isAdding = false;
          });
      } else {
        Service.createNewIndex(indexData)
          .then(newIndex => {
            // We have to manually add returned index to the indices
            const updatedIndices = [newIndex].concat(this.indices);
            this.updateIndices(updatedIndices);
            this.$router.push({ name: 'root' });
          })
          .catch(({ response }) => {
            this.formErrors = utils.fetchErrorData(response);
            this.isAdding = false;
          });
      }
    },
    routeToRoot() {
      this.$router.push({ name: 'root' });
    },
    invalidFeedback(id) {
      return this.formErrors[id] && this.formErrors[id].join();
    },
    state(id) {
      return !this.formErrors[id];
    },
  },
};
</script>
<template>
  <div>
    <h4 v-if="indexid" class="my-3">{{ s__('Elasticsearch|Edit GitLab index') }}</h4>
    <h4 v-else class="my-3">{{ s__('Elasticsearch|New GitLab index') }}</h4>

    <hr class="clearfix my-0" />

    <form class="fieldset-form mt-3" @submit.prevent="createIndex()">
      <gl-alert
        v-if="baseErrorMessage && !isAlertDismissed"
        @dismiss="isAlertDismissed = true"
        variant="danger"
      >
        {{ baseErrorMessage }}
      </gl-alert>
      <fieldset>
        <div class="row">
          <gl-form-group
            class="col-md-12"
            :label="__('Name')"
            label-for="friendly_name"
            :invalid-feedback="invalidFeedback('friendly_name')"
            :description="
              s__('Elasticsearch|Choose a name that you can use to identify this GitLab index.')
            "
            :state="state('friendly_name')"
            data-qa-selector="es_new_index_friendlyname"
          >
            <gl-form-input
              id="friendly_name"
              v-model.trim="friendly_name"
              type="text"
              class="col-md-4"
              required
              :placeholder="s__('Elasticsearch|GitLab Production')"
              :state="state('friendly_name')"
            />
          </gl-form-group>
        </div>

        <div class="row">
          <gl-form-group
            class="col-md-12"
            :label="s__('Elasticsearch|URLs')"
            label-for="urls"
            :invalid-feedback="invalidFeedback('urls')"
            :description="
              s__(
                'Elasticsearch|The URL to use for connecting to Elasticsearch. Use a comma separated list to support clustering (e.g. http://localhost:9200, https://localhost:9201).',
              )
            "
            :state="state('urls')"
            data-qa-selector="es_new_index_urls"
          >
            <gl-form-input
              id="urls"
              v-model.trim="urls"
              type="text"
              class="col-md-4"
              required
              aria-describedby="urls-help"
              :placeholder="s__('Elasticsearch|e.g. http://localhost:9200')"
              :state="state('urls')"
            />
          </gl-form-group>
        </div>

        <div class="row">
          <gl-form-group class="col-md-12">
            <gl-form-checkbox id="aws" v-model="aws">{{
              s__('Elasticsearch|Using AWS hosted Elasticsearch with IAM credentials')
            }}</gl-form-checkbox>
          </gl-form-group>
        </div>

        <template v-if="aws">
          <div class="row">
            <gl-form-group
              class="col-md-12"
              :label="s__('Elasticsearch|AWS region')"
              label-for="aws_region"
            >
              <gl-form-select
                id="aws_region"
                class="col-md-4"
                v-model="aws_region"
                :options="awsRegionOptions"
              />
            </gl-form-group>
          </div>
          <div class="row">
            <gl-form-group
              class="col-md-12"
              :label="s__('Elasticsearch|AWS Access Key ID')"
              label-for="aws_access_key"
              :description="
                s__('Elasticsearch|Only required if not using role instance credentials.')
              "
            >
              <gl-form-input
                id="aws_access_key"
                v-model="aws_access_key"
                type="text"
                class="col-md-4"
                :required="aws"
              />
            </gl-form-group>
          </div>
          <div class="row">
            <gl-form-group
              class="col-md-12"
              :label="s__('Elasticsearch|AWS Secret Access Key')"
              label-for="aws_secret_access_key"
              :description="
                s__('Elasticsearch|Only required if not using role instance credentials.')
              "
            >
              <gl-form-input
                id="aws_secret_access_key"
                v-model="aws_secret_access_key"
                type="password"
                class="col-md-4"
                :required="aws"
              />
            </gl-form-group>
          </div>
        </template>

        <div class="row">
          <gl-form-group
            class="col-md-12"
            :label="s__('Elasticsearch|Number of shards')"
            label-for="shards"
          >
            <gl-form-input
              id="shards"
              v-model="shards"
              type="number"
              class="col-md-1"
              min="1"
              aria-describedby="shards-help"
              :disabled="Boolean(indexid)"
              :class="Boolean(indexid) ? 'gl-cursor-not-allowed' : undefined"
            />
            <div id="shards-help" class="form-text text-muted">
              <span v-if="indexid" v-html="disabledHelpText"></span>
              <span v-else>
                {{
                  s__(
                    'Elasticsearch|You will not be able to change this setting later without creating a new GitLab index first.',
                  )
                }}
              </span>
            </div>
          </gl-form-group>
        </div>

        <div class="row">
          <gl-form-group
            class="col-md-12"
            :label="s__('Elasticsearch|Number of replicas')"
            label-for="replicas"
          >
            <gl-form-input
              id="replicas"
              v-model="replicas"
              type="number"
              class="col-md-1"
              min="1"
              aria-describedby="eplicas-help"
              :disabled="Boolean(indexid)"
              :class="Boolean(indexid) ? 'gl-cursor-not-allowed' : undefined"
            />
            <div id="replicas-help" class="form-text text-muted">
              <span v-if="indexid" v-html="disabledHelpText"></span>
              <span v-else>
                {{
                  s__(
                    'Elasticsearch|You will not be able to change this setting later without creating a new GitLab index first.',
                  )
                }}
              </span>
            </div>
          </gl-form-group>
        </div>

        <div class="form-actions">
          <gl-button
            new-style
            variant="success"
            type="submit"
            :disabled="isAdding"
            data-qa-selector="es_new_index_create"
          >
            <gl-loading-icon v-if="isAdding" inline />
            <template v-if="indexid">{{ __('Save changes') }}</template>
            <template v-else>{{ s__('Elasticsearch|Create GitLab index') }}</template>
          </gl-button>
          <a class="btn btn-cancel" @click="routeToRoot">{{ __('Cancel') }}</a>
        </div>
      </fieldset>
    </form>
  </div>
</template>
