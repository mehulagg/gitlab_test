<script>
import { mapActions, mapState } from 'vuex';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import Terminal from './terminal.vue';
import { isEndingStatus } from '../../utils';

export default {
  components: {
    Terminal,
  },
  computed: {
    ...mapState('terminal', ['session']),
    actionButton() {
      if (isEndingStatus(this.session.status)) {
        return {
          action: () => this.restartSession(),
          text: __('Restart Terminal'),
          class: 'btn-primary',
        };
      }

      return {
        action: () => this.stopSession(),
        text: __('Stop Terminal'),
        class: 'btn-inverted btn-remove',
      };
    },
  },
  methods: {
    ...mapActions('terminal', ['restartSession', 'stopSession']),
    test() {
      // axios({
      //   method: "GET",
      //   url: $("input.requesteduri").val(),
      // }).then(({ data }) => {
      //   var w = window.open();
      //   $(w.document.body).html(data);
      // })
      // .catch(function (error) {
      //   var w = window.open();
      //   $(w.document.body).html(error.response.data);
      // });
      window.open($("input.requesteduri").val(), "theFrame");
    },
  },
};
</script>

<template>
  <div v-if="session" class="ide-terminal build-page d-flex flex-column">
    <header class="ide-job-header d-flex align-items-center">
      <h5>{{ __('Web Terminal') }}</h5>
      <div class="ml-auto align-self-center">
        <button
          v-if="actionButton"
          type="button"
          class="btn btn-sm"
          :class="actionButton.class"
          @click="actionButton.action"
        >
          {{ actionButton.text }}
        </button>
      </div>
    </header>
    <input class="requesteduri" id="requesteduri"></input>
    <button @click="test">
        Test
    </button>
    <iframe name="theFrame" style="height:200px"></iframe>
    <terminal :terminal-path="session.terminalPath" :status="session.status" />
  </div>
</template>
