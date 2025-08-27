export interface WebViewPluginPlugin {
  openWebview(options: OpenVideoWebviewOptions): Promise<void>;
  closeVideoWebview(): Promise<void>;
  checkPermissions(): Promise<PermissionStatus>;
  requestPermissions(): Promise<PermissionStatus>;
  setWebviewOptions(options: WebviewOptions): Promise<void>;
}

export interface OpenVideoWebviewOptions {

  /**
   * URL a cargar en el WebView
   */
  url: string;

  /**
   * User Agent personalizado (opcional)
   */
  userAgent?: string;

  /**
   * Headers adicionales para la solicitud (opcional)
   */
  headers?: { [key: string]: string };

  /**
   * Permite JavaScript (por defecto: true)
   */
  allowJavaScript?: boolean;

  /**
   * Permite geolocalización (por defecto: true)
   */
  allowGeolocation?: boolean;

  /**
   * Permite reproducción de medios sin gesto de usuario (por defecto: true)
   */
  allowMediaPlayback?: boolean;

  /**
   * Habilita depuración web (solo desarrollo)
   */
  debugEnabled?: boolean;

  /**
   * Título de la barra de navegación (opcional)
   */
  title?: string;
}

export interface WebviewOptions {
  /**
   * Habilita cookies de terceros (por defecto: true)
   */
  allowThirdPartyCookies?: boolean;

  /**
   * Almacenamiento local habilitado (por defecto: true)
   */
  allowLocalStorage?: boolean;

  /**
   * Permite apertura de ventanas emergentes (por defecto: false)
   */
  allowPopups?: boolean;

  /**
   * Zoom habilitado (por defecto: false)
   */
  allowZoom?: boolean;
}

export interface PermissionStatus {
  camera: PermissionState;
  microphone: PermissionState;
}

export type PermissionState = 'prompt' | 'prompt-with-rationale' | 'granted' | 'denied';
