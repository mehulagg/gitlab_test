<script>
import ServiceCredentialsForm from './service_credentials_form.vue';
import EksClusterConfigurationForm from './eks_cluster_configuration_form.vue';

export default {
  components: {
    ServiceCredentialsForm,
    EksClusterConfigurationForm,
  },
  props: {
    gitlabManagedClusterHelpPath: {
      type: String,
      required: true,
    },
    accountAndExternalIdsHelpPath: {
      type: String,
      required: true,
    },
    createRoleArnHelpPath: {
      type: String,
      required: true,
    },
    externalId: {
      type: String,
      required: true,
    },
    accountId: {
      type: String,
      required: true,
    },
    validCredentials: {
      type: Boolean,
      required: true,
    },
  },
};
</script>
<template>
  <eks-cluster-configuration-form
    v-if="validCredentials"
    :gitlab-managed-cluster-help-path="gitlabManagedClusterHelpPath"
  />
  <service-credentials-form
    v-else
    :create-role-arn-help-path="createRoleArnHelpPath"
    :account-and-external-ids-help-path="accountAndExternalIdsHelpPath"
    :external-id="externalId"
    :account-id="accountId"
  />
</template>
