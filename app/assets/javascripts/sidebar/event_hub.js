import mitt from 'mitt';

const eventHub =  () => {
  const emitter = mitt();

  emitter.$on = emitter.on;
  emitter.$off = emitter.off;
  emitter.$emit = emitter.emit;

  return emitter;
};

export default eventHub();
