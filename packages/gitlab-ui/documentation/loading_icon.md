# Loading Icon

<!-- STORY -->

## Usage
~~~js
<gl-loading-icon />
~~~

## Props
| Property | Type | Default Value | Validation |
|---|---|---|---|
| label | String | Loading | |
| size | Number | 1 | 1 to 5 |
| inline | Boolean | false | |

## Under the hood
Loading icon uses [Font Awesome 4.7.0]'s `fa-spinner` to render the spinner.

## Additional notes
There are future plans to remove the Font Awesome dependency, in favor of a custom SVG spinner as detailed in [CE #20084].

[Font Awesome 4.7.0]: https://fontawesome.com/v4.7.0/
[CE #20084]: https://gitlab.com/gitlab-org/gitlab-ce/issues/20084
