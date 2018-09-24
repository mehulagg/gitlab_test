# Link

<!-- STORY -->

## Usage
~~~js
<gl-link />
~~~

## Props

| Property | Type | Default Value | Validation |
|---|---|---|---|
| target | String | null | |

In addition to the props listed in the table above, Link uses the same props as [`<b-link>`].

## Under the hood
Link uses [`<b-link>`] internally.

When setting target to `_blank`, the rel attribute gets set automatically to "noopener noreferrer", this is done to avoid the `window.opener` [API exploit]. If you set the `rel` attribute manually, this will overwrite the aforementioned logic. 

## Additional notes

The rel attribute gets set regardless if the URL in the `href` attribute belongs to the same domain or not, this will by addressed by [GitLab UI #58]

[`<b-link>`]: https://bootstrap-vue.js.org/docs/components/link

[API exploit]: https://www.jitbit.com/alexblog/256-targetblank---the-most-underestimated-vulnerability-ever/
[GitLab UI #58]: https://gitlab.com/gitlab-org/gitlab-ui/issues/58
