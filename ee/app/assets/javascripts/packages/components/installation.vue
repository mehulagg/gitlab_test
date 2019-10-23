<script>
import { s__, sprintf } from '~/locale';
import { GlTab, GlTabs } from '@gitlab/ui';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import CodeInstruction from './code_instruction.vue';

export default {
  name: 'PackageInstallation',
  components: {
    ClipboardButton,
    CodeInstruction,
    GlTab,
    GlTabs,
  },
  props: {
    heading: {
      type: String,
      default: s__('Package installation'),
      required: false,
    },
    name: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
    helpLink: {
      type: String,
      default: '',
    },
  },
  computed: {
    npmCommand() {
      // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
      return `npm i ${this.name}`;
    },
    npmSetupCommand() {
      // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
      return `echo @mycompany:registry=<registry url> >> .npmrc`;
    },
    yarnCommand() {
      // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
      return `yarn add ${this.name}`;
    },
    yarnSetupCommand() {
      // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
      return `echo "@<repoName>" <registry url> >> .yarnrc`;
    },
    helpText() {
      return sprintf(
        s__(
          `PackageRegistry|You may also need to setup authentication using an auth token. Please %{linkStart}see
          the documentation%{linkEnd} to find out more.`,
        ),
        {
          linkStart: `<a href="${this.helpLink}" target="_blank">`,
          linkEnd: '</a>',
        },
        false,
      );
    },
  },
};
</script>

<template>
  <div class="col-sm-6 append-bottom-default">
    <gl-tabs>
      <gl-tab :title="s__('PackageRegistry|Installation')">
        <div class="prepend-left-default append-right-default">
          <p class="prepend-top-default font-weight-bold">{{ s__('PackageRegistry|npm') }}</p>
          <code-instruction
            :instruction="npmCommand"
            :copy-text="s__('PackageRegistry|Copy npm command')"
          />

          <p class="prepend-top-default font-weight-bold">{{ s__('PackageRegistry|yarn') }}</p>
          <code-instruction
            :instruction="yarnCommand"
            :copy-text="s__('PackageRegistry|Copy yarn command')"
          />
        </div>
      </gl-tab>
      <gl-tab :title="s__('PackageRegistry|Registry Setup')">
        <div class="prepend-left-default append-right-default">
          <p class="prepend-top-default font-weight-bold">{{ s__('PackageRegistry|npm') }}</p>
          <code-instruction
            :instruction="npmSetupCommand"
            :copy-text="s__('PackageRegistry|Copy npm setup command')"
          />

          <p class="prepend-top-default font-weight-bold">{{ s__('PackageRegistry|yarn') }}</p>
          <code-instruction
            :instruction="yarnSetupCommand"
            :copy-text="s__('PackageRegistry|Copy yarn setup command')"
          />

          <p v-html="helpText"></p>
        </div>
      </gl-tab>
    </gl-tabs>
  </div>
</template>
