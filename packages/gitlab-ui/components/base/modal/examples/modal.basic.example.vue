<template>
  <div>
    <button
      v-gl-modal-directive="'test-modal-id'"
      type="button"
    >
      Open modal
    </button>
    <gl-modal
      modal-id="test-modal-id"
      title="Example title"
      no-fade
    >
      This is my content
    </gl-modal>
  </div>
</template>
