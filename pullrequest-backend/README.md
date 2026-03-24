# pullRequest API

## API Authentication
To authenticate users we are using generated deviceId's instead of accounts and passwords.

All requests except `/register`, expect the following headers:
- `x-device-id`: The id assigned to the device by the `/register` endpoint.
- `x-timestamp`: The current timestam in milliseconds from the Unix Epoch.
- `x-signed-timestamp`: The same timeestamp signed by the RSA private key coresponding with the public key sent to the `/register` endpoint.

## Registering a new device
To register a new device/user, you should make a  post request to `register` with the body field `public_key`, correspoinding to the public RSA key generated for that device.

This endpoint will return a json object with the field `device_id`, which is the Id the device has to use for all future authenticated requests.

## Authenticating with Youtube/Google and Spotify API's
To authenticate with the music service API's, the client needs to request an Authorization Code, and use the `oauth/register_code` endpoint.

The Backend will handle the exchange of the Authorization Code for the acutal API access tokens.

## Development
To start the development server run:
```bash
bun run dev
```

Open http://localhost:3000/ with your browser to see the result.

## API Endpoints

### `POST /register`
#### Body:
```ts
{
  public_key: string // RSA Public key
}
```
#### Returns:
```ts
{
  device_id: string // Device ID associated to the device
}
```

### `POST /oauth/register_code`
#### Headers:
```ts
{
  "x-device-id": string,
  "x-timestamp": string,
  "x-signed-timestamp": string
}
```
#### Body:
```ts
{
  platform: "ytm" | "spotify",
  code: string // Authorization code
}
```
#### Returns:
```ts
{
  success: boolean,
  message: string
}
```

### `GET /oauth/status`
#### Headers:
```ts
{
  "x-device-id": string,
  "x-timestamp": string,
  "x-signed-timestamp": string
}
```
#### Returns:
```ts
{
  ytm: boolean, // true if user is authenticated with YouTube Music
  spotify: boolean // true if user is authenticated with Spotify
}
```

### `GET /playlists/list`
#### Headers:
```ts
{
  "x-device-id": string,
  "x-timestamp": string,
  "x-signed-timestamp": string
}
```
#### Query Parameters:
```ts
{
  platform: "ytm" | "spotify"
}
```
#### Returns:
```ts
Array<{
  platform: "ytm" | "spotify",
  id: string,
  title: string,
  itemCount: number,
  thumbnail: {
    url: string,
    height: number,
    width: number
  }
}>
```

### `GET /playlists/contents`
#### Headers:
```ts
{
  "x-device-id": string,
  "x-timestamp": string,
  "x-signed-timestamp": string
}
```
#### Query Parameters:
```ts
{
  playlist_id: string,
  platform: "ytm" | "spotify"
}
```
#### Returns:
```ts
{
  next: boolean,
  items: Array<{
    platform: "ytm" | "spotify",
    id: string,
    title: string,
    artist: string,
    thumbnail: {
      url: string,
      height: number,
      width: number
    }
  }>
}
```

### `POST /transfer/start`
#### Headers:
```ts
{
  "x-device-id": string,
  "x-timestamp": string,
  "x-signed-timestamp": string
}
```
#### Body:
```ts
{
  platform_from: "ytm" | "spotify", // Platform where the playlist is coming from
  playlist_id: string // ID of the playlist
}
```
#### Returns:
```ts
{
  success: boolean,
  message: string
}
```
*(Optionally returns 409 Conflict if a transfer is already active)*

### `GET /transfer/updates`
#### Headers:
```ts
{
  "x-device-id": string,
  "x-timestamp": string,
  "x-signed-timestamp": string
}
```
#### Returns:
Server-Sent Events (SSE) stream.
```ts
// Event data format
{
  status: "starting" | "in_progress" | "completed" | "error",
  totalItems?: number, // Present on in_progress
  currentItem?: number, // Present on in_progress
  currentSong?: string, // Present on in_progress
  type?: "sync" // Present on initial sync event
}
```
