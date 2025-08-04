import { registerPlugin } from '@capacitor/core';
import { WebViewPluginPlugin } from './definitions';

export const WebViewPlugin = registerPlugin<WebViewPluginPlugin>('WebViewPlugin');

export default WebViewPlugin;
