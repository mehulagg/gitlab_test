import axios from '~/lib/utils/axios_utils';
import { SET_ENDPOINT, SET_SHOW_CALLOUT } from './mutations_types';

export const dismissCallout = ({ dispatch }, params) => {
  axios
    .post(params.endpoint, { feature_name: params.calloutId })
    /* An error means the callout dismissal is not persisted.
         As the only downside is that it will appear again to the user,
        the error is silenced. We don't want to disrupt the UX. */
    .catch(() => {})
    .finally(() => dispatch('setShowCallout', false));
};

export const setEndpoint = ({ commit }, endpoint) => commit(SET_ENDPOINT, endpoint);

export const setShowCallout = ({ commit }, show) => commit(SET_SHOW_CALLOUT, show);
