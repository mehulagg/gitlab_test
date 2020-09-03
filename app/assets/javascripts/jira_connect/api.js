import axios from 'axios';

export async function removeSubscription(subscriptionObject) {
  const jwt = await AP.context.getToken();
  return axios.delete(subscriptionObject.path, {
    data: {
      jwt,
    },
  });
}

export async function addSubscription(actionUrl, namespaceObject) {
  const jwt = await AP.context.getToken();
  return axios.post(actionUrl, {
    jwt,
    namespace_path: namespaceObject.path,
  });
}
