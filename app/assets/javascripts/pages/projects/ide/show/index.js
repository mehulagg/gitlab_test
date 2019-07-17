import $ from 'jquery';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import { __ } from '~/locale';

const url = document.querySelector('#ide.ide-loading').dataset.terminalsUrl;
const branch = document.querySelector('#ide.ide-loading').dataset.branch;
var buildData;
axios
.post(url, {
  branch: branch,
})
.then(({ data }) => {
  console.log(data)
  buildData = data;

  waitUntilRunning()
})
.catch((error) => {
  console.log(error)
  createFlash(__('Error creating the ide.'))
});


function fetchBuild() {
  axios
  .get(buildData.show_path)
  .then(({ data }) => {
    console.log(data)
    buildData = data;
  })
  .catch((error) => {
    createFlash(__('Cannot get terminal info.'))
  });
}

function waitUntilRunning() {
  processBuild()
  if (buildData.status == "pending") {
    setTimeout(waitUntilRunning, 5000);
  }
}

function processBuild() {
  if (buildData.status == "running") {
    redirectToIde()
  } else if (buildData.status == "pending") {
    fetchBuild()
  } else {
    createFlash(__('Error build status.'));
  }
}

function redirectToIde() {
  const { protocol, hostname, port } = window.location;
  var proxyUrl = protocol+"//"+hostname+":"+port+buildData.proxy_path+"?service=build&port=3000"
  window.location.replace(proxyUrl);
}

// document.addEventListener('DOMContentLoaded', () => {
//   const url = document.querySelector('.js-graphs-show').dataset.projectGraphPath;

//   axios
//   .post(url)
//   .then(({ data }) => {
//     const graph = new ContributorsStatGraph();
//     graph.init(data);

//     $('#brush_change').change(() => {
//       graph.change_date_header();
//       graph.redraw_authors();
//     });

//     $('.stat-graph').fadeIn();
//     $('.loading-graph').hide();
//   })
//   .catch(() => flash(__('Error fetching contributors data.')));
// });
