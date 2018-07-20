import vue from 'rollup-plugin-vue';
import resolve from 'rollup-plugin-node-resolve';
import glob from 'glob';

export default glob
  .sync('components/**.vue')
  .map((input) => {
    const vueFilename = input.slice('components/'.length);
    const outputFilename = vueFilename.slice(0, -1 * '.vue'.length);

    return {
      input,
      output: {
        format: 'esm',
        file: `dist/${outputFilename}.js`
      },
      plugins: [
        vue(),
        resolve(),
      ]
    };
  });
