export function supported() {
  return Boolean(
    navigator.credentials &&
      navigator.credentials.create &&
      navigator.credentials.get &&
      window.PublicKeyCredential,
  );
}

// adapted from https://stackoverflow.com/a/21797381/8204697
function base64UrlToBuffer(base64) {
  const binaryString = window.atob(base64.replace(/_/g, '/').replace(/-/g, '+'));
  const len = binaryString.length;
  const bytes = new Uint8Array(len);
  for (let i = 0; i < len; i += 1) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;
}

// adapted from https://stackoverflow.com/a/9458996/8204697
function bufferToBase64Url(buffer) {
  if (typeof buffer === 'string') {
    return buffer;
  }

  let binary = '';
  const bytes = new Uint8Array(buffer);
  const len = bytes.byteLength;
  for (let i = 0; i < len; i += 1) {
    binary += String.fromCharCode(bytes[i]);
  }
  return window
    .btoa(binary)
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

export function convertGetParams(webauthnParams) {
  const convertedParams = {
    ...webauthnParams,
    challenge: base64UrlToBuffer(webauthnParams.challenge),
  };
  if (convertedParams.allowCredentials) {
    convertedParams.allowCredentials = webauthnParams.allowCredentials.map(credential => ({
      ...credential,
      id: base64UrlToBuffer(credential.id),
    }));
  }
  return convertedParams;
}

export function convertGetResponse(webauthnResponse) {
  const convertedResponse = {
    id: webauthnResponse.id,
    type: webauthnResponse.type,
    rawId: bufferToBase64Url(webauthnResponse.rawId),
    response: {},
    clientExtensionResults: webauthnResponse.getClientExtensionResults(),
  };

  ['clientDataJSON', 'authenticatorData', 'signature', 'userHandle'].forEach(property => {
    convertedResponse.response[property] = bufferToBase64Url(webauthnResponse.response[property]);
  });

  return convertedResponse;
}

export function convertCreateParams(webauthnParams) {
  const convertedParams = {
    ...webauthnParams,
    challenge: base64UrlToBuffer(webauthnParams.challenge),
    user: {
      ...webauthnParams.user,
      id: base64UrlToBuffer(webauthnParams.user.id),
    },
  };
  if (convertedParams.excludeCredentials) {
    convertedParams.excludeCredentials = webauthnParams.excludeCredentials.map(credential => ({
      ...credential,
      id: base64UrlToBuffer(credential.id),
    }));
  }
  return convertedParams;
}

export function convertCreateResponse(webauthnResponse) {
  const convertedResponse = {
    id: webauthnResponse.id,
    rawId: bufferToBase64Url(webauthnResponse.rawId),
    response: {},
    clientExtensionResults: webauthnResponse.getClientExtensionResults(),
    type: webauthnResponse.type,
  };

  ['clientDataJSON', 'attestationObject'].forEach(property => {
    convertedResponse.response[property] = bufferToBase64Url(webauthnResponse.response[property]);
  });

  return convertedResponse;
}
