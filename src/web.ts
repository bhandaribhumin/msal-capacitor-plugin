import { WebPlugin } from '@capacitor/core';
import { IAuthenticationResult } from './MSAL/index';

export class msalWeb extends WebPlugin {
  constructor() {
    super({
      name: 'MSALiOS',
      platforms: ['web'],
    });
  }
  async acquireTokenInteractively(
    clientID: string,
    redirectURL: string,
  ): Promise<IAuthenticationResult[]> {
    return Promise.reject('Web Plugin Not implemented');
  }
}

const MSAL = new msalWeb();

export { MSAL };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(MSAL);
