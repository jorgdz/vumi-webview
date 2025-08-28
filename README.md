# vumi-webview

A webview plugins for capacitor applications

## Install

```bash
npm install vumi-webview
npx cap sync
```

## API

<docgen-index>

* [`openWebview(...)`](#openwebview)
* [`closeVideoWebview()`](#closevideowebview)
* [`checkWebViewPermissions()`](#checkwebviewpermissions)
* [`requestWebViewPermissions()`](#requestwebviewpermissions)
* [`setWebviewOptions(...)`](#setwebviewoptions)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### openWebview(...)

```typescript
openWebview(options: OpenVideoWebviewOptions) => Promise<void>
```

| Param         | Type                                                                        |
| ------------- | --------------------------------------------------------------------------- |
| **`options`** | <code><a href="#openvideowebviewoptions">OpenVideoWebviewOptions</a></code> |

--------------------


### closeVideoWebview()

```typescript
closeVideoWebview() => Promise<void>
```

--------------------


### checkWebViewPermissions()

```typescript
checkWebViewPermissions() => Promise<PermissionStatus>
```

**Returns:** <code>Promise&lt;<a href="#permissionstatus">PermissionStatus</a>&gt;</code>

--------------------


### requestWebViewPermissions()

```typescript
requestWebViewPermissions() => Promise<PermissionStatus>
```

**Returns:** <code>Promise&lt;<a href="#permissionstatus">PermissionStatus</a>&gt;</code>

--------------------


### setWebviewOptions(...)

```typescript
setWebviewOptions(options: WebviewOptions) => Promise<void>
```

| Param         | Type                                                      |
| ------------- | --------------------------------------------------------- |
| **`options`** | <code><a href="#webviewoptions">WebviewOptions</a></code> |

--------------------


### Interfaces


#### OpenVideoWebviewOptions

| Prop                     | Type                                    | Description                                                             |
| ------------------------ | --------------------------------------- | ----------------------------------------------------------------------- |
| **`url`**                | <code>string</code>                     | URL a cargar en el WebView                                              |
| **`userAgent`**          | <code>string</code>                     | User Agent personalizado (opcional)                                     |
| **`headers`**            | <code>{ [key: string]: string; }</code> | Headers adicionales para la solicitud (opcional)                        |
| **`allowJavaScript`**    | <code>boolean</code>                    | Permite JavaScript (por defecto: true)                                  |
| **`allowGeolocation`**   | <code>boolean</code>                    | Permite geolocalización (por defecto: true)                             |
| **`allowMediaPlayback`** | <code>boolean</code>                    | Permite reproducción de medios sin gesto de usuario (por defecto: true) |
| **`debugEnabled`**       | <code>boolean</code>                    | Habilita depuración web (solo desarrollo)                               |
| **`title`**              | <code>string</code>                     | Título de la barra de navegación (opcional)                             |


#### PermissionStatus

| Prop             | Type                                                        |
| ---------------- | ----------------------------------------------------------- |
| **`camera`**     | <code><a href="#permissionstate">PermissionState</a></code> |
| **`microphone`** | <code><a href="#permissionstate">PermissionState</a></code> |


#### WebviewOptions

| Prop                         | Type                 | Description                                                  |
| ---------------------------- | -------------------- | ------------------------------------------------------------ |
| **`allowThirdPartyCookies`** | <code>boolean</code> | Habilita cookies de terceros (por defecto: true)             |
| **`allowLocalStorage`**      | <code>boolean</code> | Almacenamiento local habilitado (por defecto: true)          |
| **`allowPopups`**            | <code>boolean</code> | Permite apertura de ventanas emergentes (por defecto: false) |
| **`allowZoom`**              | <code>boolean</code> | Zoom habilitado (por defecto: false)                         |


### Type Aliases


#### PermissionState

<code>'prompt' | 'prompt-with-rationale' | 'granted' | 'denied'</code>

</docgen-api>
