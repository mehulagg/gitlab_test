/**
 * @module cookies
 */
import Cookies from 'js-cookie';

export const setCookie = (name, value, headers) => {
  const httpHeaders = Object.assign({ secure: gon.secure_cookies }, headers);
  console.log("=== setting " + name + " " + JSON.stringify(httpHeaders));
  return Cookies.set(name, value, httpHeaders)
}
