<script>
import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';
import kebabCase from 'lodash/kebabCase';
import camelCase from 'lodash/camelCase';
import merge from 'lodash/merge';
import isFunction from 'lodash/isFunction';
import isArray from 'lodash/isArray';
import isString from 'lodash/isString';
import isUndefined from 'lodash/isString';

import * as enumConstants from '../../stories/utils/constants.js';
import { getValidationInfoText } from '../../stories/utils/validation_utils.js';

import * as gitlabComponents from '../../index.js';

import * as Documentation from '../components_documentation.js';

Vue.use(BootstrapVue);

function getPropDefaultValue(defaultValue) {
  let returnValue = '';
  if (isFunction(defaultValue) && !isArray(defaultValue)) {
    returnValue = defaultValue();
  }
  if (!isString(defaultValue) && !isUndefined(defaultValue)) {
    returnValue = JSON.stringify(defaultValue);
  }
  if (defaultValue === '' || defaultValue === null || defaultValue === 'null') {
    returnValue = '';
  }
  if (isString(returnValue)) returnValue = returnValue.replace(/"/g, "'");
  return returnValue;
}

export default {
  props: {
    componentName: {
      type: String,
      default: 'Link',
    },
  },
  computed: {
    actualComponent() {
      if (gitlabComponents[this.componentName]) {
        return Vue.options.components[this.componentName] || {};
      }
      return {};
    },
    actualComponentOptions() {
      return this.actualComponent.options || {};
    },
    documentationInfo() {
      return (
        Documentation[
          Object.keys(Documentation).find(component => component.indexOf(this.componentName) > -1)
        ] || {}
      );
    },
    bootstrapComponentName() {
      return this.documentationInfo.bootstrapComponent || '';
    },
    bootstrapComponentLink() {
      return this.bootstrapComponentName.replace('b-', '').toLowerCase();
    },
    bootstrapComponentOptions() {
      const bootstrapComponent = Vue.options.components[camelCase(this.bootstrapComponentName)];
      return bootstrapComponent && bootstrapComponent.options ? bootstrapComponent.options : {};
    },
    componentPropertiesFields() {
      return {
        prop: { label: 'Property' },
        type: { label: 'Type' },
        required: { label: 'Required' },
        val: { label: 'Value' },
      };
    },
    eventsFields() {
      return {
        event: { label: 'Event' },
        args: { label: 'Arguments' },
        description: { label: 'Description' },
      };
    },
    componentProperties() {
      const { props } = this.actualComponentOptions;
      if (!props) return [];
      if (this.documentationInfo.propsInfo) {
        merge(props, this.documentationInfo.propsInfo);
      }
      return this.getPropsMap(props);
    },
    bootstrapComponentProperties() {
      const { props } = this.bootstrapComponentOptions;
      if (!props) return [];
      if (this.documentationInfo.bootstrapPropsInfo) {
        merge(props, this.documentationInfo.bootstrapPropsInfo);
      }
      return this.getPropsMap(props);
    },
    displayComponentProperties() {
      let returnProps = Object.assign([], this.componentProperties);
      const bootstrapProps = this.bootstrapComponentProperties;

      if (bootstrapProps && bootstrapProps.length > 0) {
        const applyableBootstrapProps = bootstrapProps.reduce((actualProps, prop) => {
          const checkComp = returnProps.find(checkProp => checkProp.prop === prop.prop);
          if (!checkComp) {
            prop._cellVariants = { prop: 'info' };
            actualProps.push(prop);
          }
          return actualProps;
        }, []);
        returnProps = returnProps.concat(applyableBootstrapProps);
      }

      return returnProps;
    },
    displayEvents() {
      return this.documentationInfo.events || [];
    },
    displaySlots() {
      return this.documentationInfo.slots || [];
    },
    followsDesignSystem() {
      return this.documentationInfo.followsDesignSystem || false;
    },
  },
  methods: {
    getPropsMap: props => {
      return Object.keys(props).map(prop => {
        const selProp = props[prop];

        // Copying over values if available from documentation definition
        const propsInfo = {
          prop: kebabCase(prop),
          required: selProp.required,
          additionalInfo: selProp.additionalInfo,
          validationInfo: getValidationInfoText(selProp.validation),
        };

        // Figuring out the actual type of this property
        const baseType = selProp.type || Object;
        if (Array.isArray(baseType)) {
          propsInfo.type = baseType.map(t => t.name).join(' or ');
        } else {
          propsInfo.type = baseType.name;
        }

        // Getting the defaultValue and setting it then also the value
        propsInfo.val = getPropDefaultValue(selProp.default);

        // If we have an enum on this property we assign it and look up its values in the constant file
        if (selProp.enum) {
          propsInfo.enum = selProp.enum;
          propsInfo.enumValues = Object.values(enumConstants[selProp.enum]);
        }

        return propsInfo;
      });
    },
  },
};
</script>

<template>
  <div v-if="actualComponent.options">
    <b-alert 
      v-if="!followsDesignSystem"
      show
      variant="warning"
    >
      This component does not yet conform to the correct styling defined in our <a href="https://design.gitlab.com/">Design System</a>. Refer to the <a href="https://design.gitlab.com/">Design System</a> documentation when referencing visuals for this component.
    </b-alert>

    <div v-if="displayComponentProperties.length > 0">
      <h3>Props</h3>
      <b-table
        :items="displayComponentProperties"
        :fields="componentPropertiesFields"
        small
        head-variant="default"
        striped
      >
        <template 
          slot="prop"
          slot-scope="field"
        >
          <div>
            <span :title="field.item._cellVariants ? 'Inherited from Vue Bootstrap' : ''">{{ field.value }}</span>
          </div>
        </template>
        <template 
          slot="required"
          slot-scope="data"
        >
          <span v-if="data.value===true">✅</span>
          <span v-else>❎</span>
        </template>
        <template
          slot="val"
          slot-scope="data"
        >
          <code v-if="data.value">
            {{ data.value }}
          </code> 
          <template v-if="data.item.validationInfo">
            ({{ data.item.validationInfo }})
          </template>
          <div v-if="data.item.additionalInfo">
            <i>{{ data.item.additionalInfo }}</i>
          </div>
          <template v-if="data.item.enum">
            <div>{{ data.item.enum }}: <i>{{ data.item.enumValues.join(', ') }}</i></div>
          </template>
        </template>
      </b-table>
    </div>

    <div v-if="displaySlots.length > 0">
      <h4>Slots</h4>
      <b-table
        :items="displaySlots"
        small
        head-variant="default"
        striped
      />
    </div>

    <div v-if="displayEvents.length > 0">
      <h4>Events</h4>
      <b-table
        :items="displayEvents"
        :fields="eventsFields"
        small
        head-variant="default"
        striped
      >
        <template
          slot="args"
          slot-scope="field"
        >
          <div
            v-for="argument in field.value"
            :key="`event-${field.item.event}-${argument.arg ? argument.arg : 'none'}`">
            <code v-if="argument.arg">{{ argument.arg }}</code>
            <span>{{ argument.description }}</span>>
          </div>
        </template>
      </b-table>
    </div>

    <h3>Import</h3>

    <p>
      <code>import { {{ componentName }} } from '@gitlab/ui';</code>
    </p>

    <template v-if="bootstrapComponentName">
      <h3 id="under-the-hood">vue-bootstrap component</h3>
      <p>This component uses <a :href="`https://bootstrap-vue.js.org/docs/components/${bootstrapComponentLink}`" target="blank"><code>&lt;{{ bootstrapComponentName }}&gt;</code></a> from vue-bootstrap internally. So please take a look also there at their extensive documentation.</p>
    </template>
  </div>
  <b-alert 
    v-else
    show
    variant="warning"
  >
    No gitlab-ui component found with the name {{ componentName }}
  </b-alert>
</template>
