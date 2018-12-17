## Usage

Using the tooltip component is recommended if you have HTML content.
It is also currently required if the tooltip content needs to change while it's visible (see [this upstream issue]).
In all other cases, please use the directive.

[this upstream issue]: https://github.com/bootstrap-vue/bootstrap-vue/issues/2142

**Using the component**
~~~js
<gl-button ref="someButton">
  ...
</gl-button>

<gl-tooltip :target="() => $refs.someButton">
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

The container in the examples is not needed in CE/EE, but at the moment we scope the styles for design.gitlab.com for the usage of application.css.

[`<b-tooltip>`]: https://bootstrap-vue.js.org/docs/components/tooltip

[`v-b-tooltip`]: https://bootstrap-vue.js.org/docs/directives/tooltip
