<template>
  <div id="popovercontainer">
    <gl-button id="pop-basic">Popover Button</gl-button>
    <gl-popover 
      target="pop-basic"
      container="popovercontainer"
      placement="top"
      title="This is a Popover!"
      triggers="hover focus"
      content="With a placement of top"
    />
  </div>
</template>
