<template>
  <div>
    <gl-button id="pop-basic">Popover Button</gl-button>
    <gl-popover 
      target="pop-basic"
      placement="top"
      title="This is a Popover!"
      triggers="hover focus"
      content="With a placement of top"
    />
  </div>
</template>
