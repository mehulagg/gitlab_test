<script>
/* eslint-disable vue/no-v-html */

import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';

import * as Babel from '@babel/standalone';
import { parseComponent } from 'vue-template-compiler';

import { html } from 'js-beautify';
import hljs from 'highlight.js';
import 'highlight.js/styles/monokai.css';

import copyToClipboard from 'copy-to-clipboard';

import { gitlabComponents } from '../all_components';

import * as Documentation from '../components_documentation';

import JsfiddleButton from './jsfiddle_button.vue';

// We need to register globally all components as we don't know the components that are used in the dynamically compiled .example.vue files
// This is only for design.gitlab.com and shouldn't be done in our actual application
Vue.use(BootstrapVue);
Object.keys(gitlabComponents).forEach(comp => {
  if (!comp.includes('Directive')) {
    Vue.component(comp, gitlabComponents[comp]);
  }
});

// We need to do Directives for now manually
Vue.directive('gl-tooltip', gitlabComponents.GlTooltipDirective);
Vue.directive('gl-modal-directive', gitlabComponents.GlModalDirective);

function findComponentExample(exampleName) {
  /* eslint-disable no-restricted-syntax */
  // Doing it with a for loop to have an early return/break during iteration
  for (const component of Object.values(Documentation)) {
    if (component.examples) {
      // Looking for an example in the component documentation definition that matches the exampleName
      for (const exampleGroup of component.examples) {
        const foundExample = exampleGroup.items.find(example => example.id === exampleName);
        if (foundExample) {
          return foundExample;
        }
      }
    }
  }
  /* eslint-enable no-restricted-syntax */
  return null;
}

const animationTimeout = 2000;

export default {
  components: {
    JsfiddleButton,
  },
  props: {
    exampleName: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      source: '',
      renderedHtml: '',
      copiedSource: false,
      copiedOutput: false,
    };
  },
  computed: {
    // Based on the set exampleName we try to look it up in the currently loaded Documentation Examples and then read it-> parse and compile it
    currentExampleComponent() {
      // Going through all documentation objects of all components
      const foundExample = findComponentExample(this.exampleName);

      // Live loading of .example.vue files
      // Examples are included with webpack through raw-loader -> Results in a string
      if (foundExample && foundExample !== undefined) {
        const base = {
          name: '',
          template: '<div></div>',
        };
        try {
          // At Runtime we parse it with `parseComponent` from `vue-template-compiler` (Line 64)
          const parsed = parseComponent(foundExample.component);

          let compiled = {};
          if (parsed.script) {
            // We parse the script part with Babel.transform (Line 68 in example_display)
            const { code } = Babel.transform(parsed.script.content, {
              presets: ['es2015', 'stage-2'],
            });
            compiled = eval(`const exports = {};${code}`); // eslint-disable-line no-eval
          }

          // Results in the original source of the template and the compiled and working Vue component
          compiled.template = parsed.template.content;
          // eslint-disable-next-line vue/no-side-effects-in-computed-properties
          this.source = compiled.template;

          return Object.assign({}, base, compiled);
        } catch (e) {
          // eslint-disable-next-line no-console
          console.log('ERR : ', e);
          return base;
        }
      }
      return null;
    },
    exampleHTMLOutput() {
      return this.$refs.exampleComponent || '';
    },
    sourceFormatted() {
      if (this.source) {
        return hljs.fixMarkup(hljs.highlight('html', this.source).value);
      }
      return '';
    },
    renderedHtmlFormatted() {
      if (this.renderedHtml) {
        return hljs.fixMarkup(hljs.highlight('html', this.renderedHtml).value);
      }
      return '';
    },
  },
  watch: {
    currentExampleComponent() {
      Vue.nextTick(() => {
        this.setHtml();
      });
    },
  },
  created() {
    // Converting Tabs to spaces to make display look indented
    hljs.configure({ tabReplace: '    ', useBR: true });
  },
  mounted() {
    this.setHtml();
  },
  methods: {
    setHtml() {
      if (this.$refs.compiled) {
        const markup = this.$refs.compiled.$el.outerHTML;
        if (markup) {
          // Splitting lines for easier readability on the rendered output
          const preFormattedHTML = markup.replace(/><(?!\/i|\/label|\/span|option)/g, '>\n<');
          this.renderedHtml = html(preFormattedHTML, {
            indent_size: 2,
            indent_char: ' ',
            wrap_attributes: 'auto',
            wrap_attributes_indent_size: 2,
            end_with_newline: false,
          });
        }
      }
    },
    copySource() {
      copyToClipboard(this.source);
      this.copiedSource = true;
      setTimeout(() => {
        this.copiedSource = false;
      }, animationTimeout);
    },
    copyHtml() {
      copyToClipboard(this.renderedHtml);
      this.copiedOutput = true;
      setTimeout(() => {
        this.copiedOutput = false;
      }, animationTimeout);
    },
  },
};
</script>

<template>
  <div>
    <div v-if="currentExampleComponent">
      <b-card no-body>
        <div slot="header">
          <b-row>
            <b-col>
              <strong>{{ exampleName }}</strong>
            </b-col>
            <b-col class="text-right">
              <b-button-group
                size="sm"
                class="mx-1"
              >
                <b-btn v-b-toggle.collapseSource>Source</b-btn>
                <b-btn v-b-toggle.collapseHTML>HTML</b-btn>
                <jsfiddle-button
                  :example-name="exampleName"
                  :source="source"
                />
              </b-button-group>
            </b-col>
          </b-row>
        </div>
        <b-card-body>
          <div
            :is="currentExampleComponent"
            ref="compiled"
          />
        </b-card-body>
        <b-list-group flush>
          <b-collapse
            id="collapseSource"
            class="mt-2"
          >
            <b-list-group-item>
              <b-row>
                <b-col cols="8"><h6>Source</h6></b-col>
                <b-col class="text-right">
                  <template v-if="copiedSource">Copied!</template>
                  <b-button-group size="sm">
                    <b-button
                      :disabled="copiedSource"
                      @click="copySource"
                    >
                      Copy
                    </b-button>
                  </b-button-group>
                </b-col>
              </b-row>
              <code
                class="hljs html"
                v-html="sourceFormatted"
              ></code>
            </b-list-group-item>
          </b-collapse>
          <b-collapse
            id="collapseHTML"
            class="mt-2"
          >
            <b-list-group-item>
              <b-row>
                <b-col cols="8"><h6>HTML Output</h6></b-col>
                <b-col class="text-right">
                  <template v-if="copiedOutput">Copied!</template>
                  <b-button-group size="sm">
                    <b-button
                      :disabled="copiedOutput"
                      @click="copyHtml"
                    >
                      Copy
                    </b-button>
                  </b-button-group>
                </b-col>
              </b-row>
              <code
                class="hljs html"
                v-html="renderedHtmlFormatted"
              ></code>
            </b-list-group-item>
          </b-collapse>
        </b-list-group>
      </b-card>
    </div>
    <b-alert
      v-else-if="exampleName"
      show
      variant="warning"
    >No Example found with the name "{{ exampleName }}"</b-alert>
  </div>
</template>
