<script>
import { GlLoadingIcon } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';

export default {
  components: {
    GlLoadingIcon,
  },
  props: {
    isLoading: {
      type: Boolean,
      required: false,
      default: true,
    },
    isValid: {
      type: Boolean,
      required: false,
      default: false,
    },
    message: {
      type: String,
      required: false,
      default: '',
    },
    helpPath: {
      type: String,
      required: false,
      default: '',
    },
    illustrationPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  methods: {
    onStart() {
      this.$emit('start');
    },
    testws() {      
      const { protocol, hostname, port } = window.location;
      console.log(protocol)
      console.log(hostname)      
      console.log(port)
      const wsProtocol = protocol === 'https:' ? 'wss://' : 'ws://';
      // var path = `/root/testruneree/ide_terminals/1234/proxy.ws`;
      var path = `/root/testrunneree/-/jobs/1234/terminal.ws`;
      var url = `${wsProtocol}${hostname}:${port}${path}`;
      console.log(url)
      var socket = new WebSocket(url, ['terminal.gitlab.com']);
      
      // axios.get(url)
      // new WebSocket(`${this.session.proxyPath}.ws`);
      // new WebSocket($('#wssurl').val());
    }
  },
};
</script>
<template>  
  <div class="text-center">
    <div>
      <input id="wssurl"></input>
      <button @click="testws">
        TestWSS
      </button>
    </div>
    <div v-if="illustrationPath" class="svg-content svg-130"><img :src="illustrationPath" /></div>
    <h4>{{ __('Web Terminal') }}</h4>
    <gl-loading-icon v-if="isLoading" :size="2" class="prepend-top-default" />
    <template v-else>
      <p>{{ __('Run tests against your code live using the Web Terminal') }}</p>
      <p>
        <button :disabled="!isValid" class="btn btn-info" type="button" @click="onStart">
          {{ __('Start Web Terminal') }}
        </button>
      </p>
      <div v-if="!isValid && message" class="bs-callout text-left" v-html="message"></div>
      <p v-else>
        <a
          v-if="helpPath"
          :href="helpPath"
          target="_blank"
          v-text="__('Learn more about Web Terminal')"
        ></a>
      </p>
    </template>
  </div>
</template>
