## Usage
Using the tooltip component is recommended if you have HTML content. In all other cases, please use the directive.

**Using the component**
~~~js
<gl-button id="ref2">
  ...
</gl-button>

<gl-tooltip
  target="ref2"
>
  some <em>tooltip<em/> text
</gl-tooltip>
~~~

**Using the directive**
~~~js
<element
  v-gl-tooltip.${modifier}
  title="some tooltip text"
>
  ...
</element>
~~~

## Directive attributes

`v-gl-tooltip` directive uses the same attributes as [`v-b-tooltip`].

## Under the hood
Tooltip uses [`<b-tooltip>`] and [`v-b-tooltip`] internally.

[`<b-tooltip>`]: https://bootstrap-vue.js.org/docs/components/tooltip

[`v-b-tooltip`]: https://bootstrap-vue.js.org/docs/directives/tooltip
