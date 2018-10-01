# Button

<!-- STORY -->

## Usage
~~~js
<gl-button />
~~~

### Button link
~~~js
<gl-button href="#"/>
~~~

A button link is a link that is styled to look like a button, semantically speaking it's a `<a>` tag
with the necessary classes added to make it look like a button, it shares the same functionality as [`<gl-link>`]

> Note: Setting a `target` attribute without a `href` attribute, will not create any side effects. Without the presence of a `href` attribute, this component will render a `<button>`.

## Props

| Property | Type | Default Value | Validation |
|---|---|---|---|
| target | String | null | |

In addition to the props listed in the table above, Button uses the same props as [`<b-button>`].

## Under the hood
Link uses [`<b-button>`] internally.

[`<gl-link>`]: https://gitlab.com/gitlab-org/gitlab-ui/blob/master/documentation/link.md
[`<b-button>`]: https://bootstrap-vue.js.org/docs/components/button
