# Link

<!-- STORY -->

## Usage
~~~js
<gl-link />
~~~

## Additional notes
When setting target to `_blank`, the rel attribute gets set automatically to "noopener noreferrer", this is done to avoid the `window.opener` [API exploit]. If you set the `rel` attribute manually, this will overwrite the aforementioned logic.

[API exploit]: https://www.jitbit.com/alexblog/256-targetblank---the-most-underestimated-vulnerability-ever/
