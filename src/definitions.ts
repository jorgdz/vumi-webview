export interface WebViewPluginPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
