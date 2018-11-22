<template>
  <div>
    <button
      v-gl-modal-directive="'basic-modal-id'"
      type="button"
    >
      Open modal
    </button>
    <gl-modal
      modal-id="basic-modal-id"
      title="Example title"
      no-fade
    >
      This is my content
    </gl-modal>
  </div>
</template>
