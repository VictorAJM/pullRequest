import { Elysia } from "elysia";
import { deviceAuthPlugin } from "@services/device_auth";
import { registerRoute } from "@routes/register";
import { oauthRoute } from "@routes/oauth";
import { playlistsRoutes } from "@routes/playlists";
import { playlistTransferRoutes } from "@routes/transfer";

const app = new Elysia()
  .get('/', () => 'Hi 🫣')
  .use(registerRoute)
  .use(deviceAuthPlugin)
  .use(oauthRoute)
  .use(playlistTransferRoutes)
  .use(playlistsRoutes)
  .listen(3000);

console.log('🦊 Server is running')
