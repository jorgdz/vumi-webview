export interface OpenWebviewOptions {
  url: string;
}

export interface WebViewPluginPlugin {
  openWebview(options: OpenWebviewOptions): Promise<void>;
}
