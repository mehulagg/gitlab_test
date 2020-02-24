<script>
import { mapActions, mapState } from 'vuex';
import { GlButton, GlSprintf, GlLink, GlFormInput, GlIcon } from '@gitlab/ui';

export default {
  components: { GlButton, GlSprintf, GlLink, GlFormInput, GlIcon },
  computed: {
    ...mapState(['enabled', 'bucketName', 'region', 'awsSecretKey', 'awsAccessKey', 'loading']),
  },
  methods: {
    ...mapActions([
      'setStatusPageEnabled',
      'setStatusPageBucketName',
      'setStatusPageRegion',
      'setStatusPageAccessKey',
      'setStatusPageSecretAccessKey',
      'updateStatusPageSettings',
    ]),
    handleSubmit() {
      this.updateStatusPageSettings();
    },
  },
};
</script>

<template>
  <section id="status-page" class="settings no-animate js-status-page-settings">
    <div class="settings-header">
      <h3 class="js-section-header h4">
        {{ s__('StatusPage|Status Page') }}
      </h3>
      <gl-button class="js-settings-toggle">{{ __('Expand') }}</gl-button>
      <p class="js-section-sub-header">
        {{
          s__(
            'StatusPage|Configure file storage settings to link issues in this project to an external status page.',
          )
        }}
        <gl-link>{{ __('More information') }}</gl-link>
      </p>
    </div>

    <div class="settings-content">
      <!-- eslint-disable @gitlab/vue-i18n/no-bare-attribute-strings -->
      <p>
        <gl-sprintf
          :message="
            s__(
              'StatusPage|To publish incidents to an external status page, GitLab will store a JSON file in your Amazon S3 account in a location accessible to your external status page service. Make sure to also set up %{docsLink}',
            )
          "
        >
          <template #docsLink>
            <gl-link href="#">
              <span>{{ s__('StatusPage|Status Page frontend.') }}</span>
            </gl-link>
          </template>
        </gl-sprintf>
      </p>
      <form>
        <div class="form-check form-group">
          <input
            id="status-page-activated"
            :checked="enabled"
            class="form-check-input"
            type="checkbox"
            @change="setStatusPageEnabled($event.target.checked)"
          />
          <label class="form-check-label" for="status-page-activated">{{
            s__('StatusPage|Active')
          }}</label>
        </div>

        <div class="form-group">
          <label class="label-bold" for="status-page-s3-bucket-name ">{{
            s__('StatusPage|S3 Bucket name')
          }}</label>
          <div class="row">
            <div class="col-8 col-md-9 gl-pr-0">
              <gl-form-input
                id="status-page-s3-bucket-name "
                :value="bucketName"
                @input="setStatusPageBucketName"
              />
              <p class="form-text text-muted">
                <gl-sprintf :message="s__('StatusPage|Bucket %{docsLink}')">
                  <template #docsLink>
                    <gl-link
                      href="https://docs.aws.amazon.com/AmazonS3/latest/dev/HostingWebsiteOnS3Setup.html"
                    >
                      <span>{{ s__('StatusPage|configuration documentation.') }}</span>
                      <gl-icon name="external-link" class="vertical-align-middle" />
                    </gl-link>
                  </template>
                </gl-sprintf>
              </p>
            </div>
          </div>
        </div>

        <div class="form-group">
          <label class="label-bold" for="status-page-aws-region">{{
            s__('StatusPage|AWS Region')
          }}</label>
          <div class="row">
            <div class="col-8 col-md-9 gl-pr-0">
              <gl-form-input
                id="status-page-aws-region"
                :value="region"
                placeholder="example: us-west-2"
                @input="setStatusPageRegion"
              />
              <p class="form-text text-muted">
                <gl-sprintf
                  :message="s__('StatusPage|For help with this configuration, visit %{docsLink}')"
                >
                  <template #docsLink>
                    <gl-link href="https://github.com/aws/aws-sdk-ruby#configuration">
                      <span>{{ s__('StatusPage|AWS documentation.') }}</span>
                      <gl-icon name="external-link" class="vertical-align-middle" />
                    </gl-link>
                  </template>
                </gl-sprintf>
              </p>
            </div>
          </div>
        </div>

        <div class="form-group">
          <label class="label-bold" for="status-page-aws-access-key-id">{{
            s__('StatusPage|AWS Access Key ID')
          }}</label>
          <div class="row">
            <div class="col-8 col-md-9 gl-pr-0">
              <gl-form-input
                id="status-page-aws-access-key "
                :value="awsAccessKey"
                @input="setStatusPageAccessKey"
              />
            </div>
          </div>
        </div>

        <div class="form-group">
          <label class="label-bold" for="status-page-aws-secret-access-key ">{{
            s__('StatusPage|AWS Secret access key')
          }}</label>
          <div class="row">
            <div class="col-8 col-md-9 gl-pr-0">
              <gl-form-input
                id="status-page-aws-secret-access-key "
                :value="awsSecretKey"
                @input="setStatusPageSecretAccessKey"
              />
            </div>
          </div>
        </div>

        <gl-button :disabled="loading" variant="success" @click="handleSubmit">
          {{ __('Save changes') }}
        </gl-button>
      </form>
    </div>
  </section>
</template>
