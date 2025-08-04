import { registerPlugin } from '@capacitor/core';

import type { WebViewPluginPlugin } from './definitions';

const WebViewPlugin = registerPlugin<WebViewPluginPlugin>('WebViewPlugin', {
  web: () => import('./web').then((m) => new m.WebViewPluginWeb()),
});

export * from './definitions';
export { WebViewPlugin };
