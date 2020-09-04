<script>
import {
  GlButton,
  GlForm,
  GlFormCheckbox,
  GlFormGroup,
  GlFormInput,
  GlLink,
  GlSprintf,
  GlFormTextarea
} from '@gitlab/ui';
import { mapState } from 'vuex';
import { s__ } from '~/locale';

export default {
  components: {
    GlButton,
    GlForm,
    GlFormCheckbox,
    GlFormGroup,
    GlFormInput,
    GlLink,
    GlSprintf,
    GlFormTextarea,
  },
  data() {
    return {
      apiUrl: '',
      certificate: '',
      clusterEnvironment: '*',
      clusterManaged: true,
      clusterName: '',
      namespace: '',
      rbacEnabled: true,
      token: '',
    };
  },
  computed: {
    ...mapState([
      'allowUserDefinedNamespace',
      'clusterConnectHelpPath',
      'managedClustersHelpLink',
      'rbacHelpLink'
    ]),
    namespaceDescription() {
      if (this.clusterManaged) {
        return s__('ClusterIntgegration|Set a prefix for your namespaces. If not set, defaults to your project path. If modified, existing environments will use their current namespaces until the cluster cache is cleared. %{linkStart}More Information%{linkEnd}')
      } else {
        return s__('ClusterIntegration|The namespace associated with your project. This will be used for deploy boards, logs, and Web terminals.')
      }
    },
    namespaceLabel() {
      if (this.clusterManaged) {
        return s__('ClusterIntegration|Project namespace prefix (optional, unique)')
      } else {
        return s__('ClusterIntegration|Project namespace (optional, unique)')
      }
    }
  },
  methods: {
    onSubmit() {
      return clusterConnectHelpPath;
    },
    onReset() {
      return clusterConnectHelpPath;
    },
  },
};
</script>

<template>
  <div>
    <gl-form @submit="onSubmit">
      <gl-form-group
        id="cluster_name_group"
        label-for="cluster_name"
        :label="s__('ClusterIntegration|Kubernetes cluster name')"
      >
        <gl-form-input
          id="cluster_name"
          v-model="clusterName"
          name="cluster[name]"
          required
          type="text"
          invalid-feedback="error message"
        />
      </gl-form-group>

      <gl-form-group
        id="cluster_environment_scope_group"
        label-for="cluster_environment_scope"
        :label="s__('ClusterIntegration|Environment scope')"
        :description="
          s__('ClusterIntegration|Choose which of your environments will use this cluster.')
        "
      >
        <gl-form-input
          id="cluster_environment_scope"
          v-model="clusterEnvironment"
          name="cluster[environment_scope]"
          required
          type="text"
          invalid-feedback="error message"
        />
      </gl-form-group>

      <gl-form-group
        id="cluster_platform_kubernetes_attributes_api_url_group"
        label-for="cluster_platform_kubernetes_attributes_api_url"
        :label="s__('ClusterIntegration|API URL')"
      >
        <gl-form-input
          id="cluster_platform_kubernetes_attributes_api_url"
          v-model="apiUrl"
          name="cluster[platform_kubernetes_attributes][api_url]"
          required
          type="text"
          invalid-feedback="error message"
        />

        <template #description>
          <gl-sprintf
            :message="
              s__(
                'ClusterIntegration|The URL used to access the Kubernetes API. %{linkStart}More Information%{linkEnd}',
              )
            "
          >
            <template #link="{ content }">
              <gl-link :href="clusterConnectHelpPath" target="_blank">{{ content }}</gl-link>
            </template>
          </gl-sprintf>
        </template>
      </gl-form-group>

      <gl-form-group
        id="cluster_platform_kubernetes_attributes_ca_cert_group"
        label-for="cluster_platform_kubernetes_attributes_ca_cert"
        :label="s__('ClusterIntegration|CA Certificate')"
      >
        <gl-form-textarea
          id="cluster_platform_kubernetes_attributes_ca_cert"
          v-model="certificate"
          rows="10"
          name="cluster[platform_kubernetes_attributes][ca_cert]"
          :placeholder="s__('ClusterIntegration|Certificate Authority bundle (PEM format)')"
        />

        <template #description>
          <gl-sprintf
            :message="
              s__(
                'ClusterIntegration|The Kubernetes certificate used to authenticate to the cluster. %{linkStart}More Information%{linkEnd}',
              )
            "
          >
            <template #link="{ content }">
              <gl-link :href="clusterConnectHelpPath" target="_blank">{{ content }}</gl-link>
            </template>
          </gl-sprintf>
        </template>
      </gl-form-group>

      <gl-form-group
        id="cluster_platform_kubernetes_attributes_token_group"
        label-for="cluster_platform_kubernetes_attributes_token"
        :label="s__('ClusterIntegration|Service Token')"
      >
        <gl-form-input
          id="cluster_platform_kubernetes_attributes_token"
          v-model="token"
          autocomplete="off"
          name="cluster[platform_kubernetes_attributes][token]"
          required
          type="text"
          invalid-feedback="error message"
        />

        <template #description>
          <gl-sprintf
            :message="
              s__(
                'ClusterIntegration|A service token scoped to %{kubeStart}kube-system%{kubeEnd} with %{clusterStart}cluster-admin%{clusterEnd} privileges. %{linkStart}More Information%{linkEnd}',
              )
            "
          >
            <template #kube="{ content }">
              <code>{{ content }}</code>
            </template>

            <template #cluster="{ content }">
              <code>{{ content }}</code>
            </template>

            <template #link="{ content }">
              <gl-link :href="clusterConnectHelpPath" target="_blank">{{ content }}</gl-link>
            </template>
          </gl-sprintf>
        </template>
      </gl-form-group>

      <gl-form-group
        id="cluster_platform_kubernetes_attributes_authorization_type_group"
      >
        <gl-form-checkbox v-model="rbacEnabled">
          <label
            for="cluster_platform_kubernetes_attributes_authorization_type"
          >
            {{ s__('ClusterIntegration|RBAC-enabled cluster') }}
          </label>

          <template #help>
            <gl-sprintf
              :message="s__(
                  'ClusterIntegration|Enable this setting if using role-based access control (RBAC). This option will allow you to install applications on RBAC clusters. %{linkStart}More Information%{linkEnd}'
                )
              "
            >
            <template #link="{ content }">
              <gl-link :href="rbacHelpLink" target="_blank">{{ content }}</gl-link>
            </template>
            </gl-sprintf>
          </template>
        </gl-form-checkbox>
      </gl-form-group>

      <gl-form-group
        id="cluster_managed_group"
      >
        <gl-form-checkbox v-model="clusterManaged">
          <label
            for="cluster_managed"
          >
            {{ s__('ClusterIntegration|GitLab-managed cluster') }}
          </label>

          <template #help>
            <gl-sprintf
              :message="s__(
                  'ClusterIntegration|Allow GitLab to manage namespace and service accounts for this cluster. %{linkStart}More Information%{linkEnd}'
                )
              "
            >
            <template #link="{ content }">
              <gl-link :href="managedClustersHelpLink" target="_blank">{{ content }}</gl-link>
            </template>
            </gl-sprintf>
          </template>
        </gl-form-checkbox>
      </gl-form-group>

      <gl-form-group
        v-if="allowUserDefinedNamespace"
        :label="namespaceLabel"
      >
        <gl-form-input
          id="cluster_platform_kubernetes_attributes_namespace"
          v-model="namespace"
          name="cluster[platform_kubernetes_attributes][namespace]"
          type="text"
          invalid-feedback="error message"
        />

        <template #description>
          <gl-sprintf
            :message="namespaceDescription"
          >
            <template #link="{ content }">
              <gl-link :href="managedClustersHelpLink" target="_blank">{{ content }}</gl-link>
            </template>
          </gl-sprintf>
        </template>
      </gl-form-group>

      <gl-button
        type="submit"
        variant="success"
        data-qa-selector="add_kubernetes_cluster_button"
      >
        {{ s__('ClusterIntegration|Add Kubernetes cluster') }}
      </gl-button>
    </gl-form>
  </div>
</template>
