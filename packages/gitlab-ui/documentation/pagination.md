# Pagination

<!-- STORY -->

## Pagination
~~~js
<gl-pagination />
~~~

## Props

| Property | Type | Default Value | Validation |
|---|---|---|---|
| change | Function | null | |
| page | Number | null | |
| perPage | Number | null | |
| totalItem | Number | null | |
| limit | Object | <code>{ <br /> &nbsp; xs: 1, <br /> &nbsp;  sm: 3, <br /> &nbsp; md: 5, <br /> &nbsp; default: 11 <br />}</code> | The object must contain the  `xs`, `sm`, `md` and `default` keys |

In addition to the props listed in the table above, Pagination uses the same props as [`<b-pagination>`].

> Note: The limits prop is used to define pagination link limits based on Bootstrap's breakpoint sizes. It is strongly recommended you provide a 'default' property, even if you have accounted for all breakpoint sizes. While unlikely, it is possible breakpoints could change, thus, a default property ensures a graceful fallback. 

> Note: The component will not render any UI if the total items available for display is less than the max items per page.

## Under the hood
Pagination uses [`<b-pagination>`] internally.

[`<b-pagination>`]: https://bootstrap-vue.js.org/docs/components/pagination
