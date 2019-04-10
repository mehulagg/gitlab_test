<script>
import $ from 'jquery';
import axios from '~/lib/utils/axios_utils';
import { mapActions, mapState } from 'vuex';
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
      axios({
        method: $('#request_method').val(),
        url: this.session.proxyPath,
        params: {
          path: $("input.requesteduri").val(),
          port: $("input.proxyport").val(),
          service: $("input.proxyservice").val(),
        }
      }).then(({ data }) => {
        var w = window.open();
        $(w.document.body).html(data);
      })
      .catch(function (error) {
        var w = window.open();
        $(w.document.body).html(error.response.data);
      });
    },
    testws() {
      const { protocol, hostname, port } = window.location;
      const wsProtocol = protocol === 'https:' ? 'wss://' : 'ws://';
      var path = `${this.session.proxyWebsocketPath}?service=${$("input.proxyservice").val()}&port=${$("input.proxyport").val()}&path=${$("input.requesteduri").val()}`
      var url = `${wsProtocol}${hostname}:${port}${path}`;
      console.log(url)
      var socket = new WebSocket(url, ['terminal.gitlab.com']);
      socket.binaryType = 'arraybuffer';
      socket.onopen = () => {
        console.log("Connected");
      };
      socket.onerror = () => {
        console.log("Error connecting websocket");
      };

      const decoder = new TextDecoder('utf-8');
      const encoder = new TextEncoder('utf-8');
      var container = $('textarea.wssdata');
      console.log(container)
      container.bind('input propertychange', function() {
        socket.send(encoder.encode("pepe"));
      });

      socket.addEventListener('message', ev => {
        console.log(decoder.decode(ev.data));
      });
    }
  },
};
</script>

<template>
  <div v-if="session" class="ide-terminal build-page d-flex flex-column">
    <header class="ide-job-header d-flex align-items-center">
      <h5>{{ __('Web Terminal') }}</h5>
      <div class="ml-auto align-self-center">
        <select
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
    <div v-if="session.status == 'running'">
      <label for="proxyservice">Service Name</label>
      <input class="proxyservice" id="proxyservice" value="websocket"></input>
      <label for="proxyport">Service External Port</label>
      <input class="proxyport" id="proxyport" value="4004"></input>
      <form action="requesteduri">Requested Uri</form>
      <input class="requesteduri" id="requesteduri"></input>
      <select id="request_method">
        <option value="get">
          GET
        </option>
        <option value="post">
          POST
        </option>
        <option value="put">
          PUT
        </option>
        <option value="delete">
          DELETE
        </option>
      </select>
      <button @click="test">
        Test
      </button>
    </div>
    <div v-if="session.status == 'running'">
      <button @click="testws">
        TestWSS
      </button>
      <textarea class="wssdata" id="wssdata"></textarea>
    </div>
    <terminal :terminal-path="session.terminalPath" :status="session.status" />
  </div>
</template>
