import { WebPlugin } from '@capacitor/core';

import type { WebViewPluginPlugin } from './definitions';

export class WebViewPluginWeb extends WebPlugin implements WebViewPluginPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
