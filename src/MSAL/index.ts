import { Plugins } from '@capacitor/core';
const { msal } = Plugins;

export class MSALAuthentication implements acquireTokenInteractivelyInterface {
  // Initialize MSAL with appId
  async msalInit(options: MSALOption): Promise<{ value: boolean }> {
    const response = await msal.msalInit(options);
    return response.clientID;
  }
  async initMSAL(options: MSALOption): Promise<IAuthenticationResult[]> {
    const response = await msal.initMSAL(options);
    return response.accessToken;
  }

  async aquireTokenAsync(): Promise<any> {
    const response = await msal.aquireTokenAsync();
    return response.accessToken;
  }
  async aquireTokenAsyncSilent(
    ClientID: String,
    GraphURI: String,
    Authority: String,
    RedirectUri: String,
  ): Promise<IAuthenticationResult[]> {
    const response = await msal.aquireTokenAsyncSilent({
      ClientID,
      GraphURI,
      Authority,
      RedirectUri,
    });
    return response.accessToken;
  }

  async currentAccount(
    ClientID: String,
    GraphURI: String,
    Authority: String,
    RedirectUri: String,
  ): Promise<any[]> {
    const response = await msal.currentAccount({
      ClientID,
      GraphURI,
      Authority,
      RedirectUri,
    });
    return response.cachedToken;
  }
  async signOut(
    ClientID: String,
    GraphURI: String,
    Authority: String,
    RedirectUri: String,
  ): Promise<any[]> {
    const response = await msal.signOut({
      ClientID,
      GraphURI,
      Authority,
      RedirectUri,
    });
    return response.cachedToken;
  }
}

export interface acquireTokenInteractivelyInterface {
  msalInit(options: MSALOption): Promise<{ value: boolean }>;
  initMSAL(options: MSALOption): Promise<IAuthenticationResult[]>;
  aquireTokenAsync(): Promise<any>;
  aquireTokenAsyncSilent(
    ClientID: string,
    GraphURI: string,
    Authority: string,
    RedirectUri: string,
  ): Promise<IAuthenticationResult[]>;
  currentAccount(
    ClientID: string,
    GraphURI: string,
    Authority: string,
    RedirectUri: string,
  ): Promise<IADTokenCacheItem[]>;
  signOut(
    ClientID: string,
    GraphURI: string,
    Authority: string,
    RedirectUri: string,
  ): Promise<any[]>;
}
export interface IAuthenticationResult {
  accessToken: string;
}
export interface IADTokenCacheItem {
  accessToken: string;
  accessTokenType: string;
  refreshToken: string;
  expiresOn: boolean;
}

export interface AuthenticateBaseOptions {
  /**
   * The app id (client id) you get from the oauth provider like Google, Facebook,...
   *
   * required!
   */
  clientID: string;
  /**
   * The base url for retrieving tokens depending on the response type from a OAuth 2 provider. e.g. https://accounts.google.com/o/oauth2/auth
   *
   * required!
   */
  graphURI: string;
  /**
   * Tells the authorization server which grant to execute. Be aware that a full code flow is not supported as clientCredentials are not included in requests.
   *
   * But you can retrieve the authorizationCode if you don't set a accessTokenEndpoint.
   *
   * required!
   */
  authority: string;
  /**
   * Url to  which the oauth provider redirects after authentication.
   *
   * required!
   */
  redirectUri: string;
  scope?: string;
  /**
   * A unique alpha numeric string used to prevent CSRF. If not set the plugin automatically generate a string
   * and sends it as using state is recommended.
   */
  state?: string;
  /**
   * Additional parameters for the created authorization url
   */
  additionalParameters?: { [key: string]: string };
}

export interface MSALOption {
  ClientID: string;
  Authority: string;
  RedirectUri: string;
  Scope?: Array<string>;
}
