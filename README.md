# todone

An open-source todo app for the web: sticky notes you drag onto a day, a calendar to plan the week on, and teams to share it with. It works offline.

- Lists of sticky notes; drop one note on another to make it a step
- Stickers for when, how long, priority and repeats (daily, weekdays, weekends, …)
- A day, week, month and year calendar; drag tasks onto a time and stretch them to fit
- Brainstorm: loose ideas that become tasks when you drag them onto a list
- Teams with members, roles and invitations
- Google Calendar, Notion, Obsidian (Markdown), Discord, a calendar feed for Apple and Outlook, and push reminders
- Export everything as JSON or CSV; delete your account any time

The terminal app this project started as is retired; its last version is tagged [`tui-final`](../../tree/tui-final).

## Run it

```sh
cd clients/apps/web
npm install
npm run local
```

`npm run local` runs Postgres inside Node (PGlite, data in `.pglite`), migrates it and starts the app on http://localhost:3000. To run everything with Docker instead: `docker compose up`.

### On your own server

The Compose file runs Postgres and the app (bound to this machine only), a `reminders` service that sends push reminders every 10 minutes, and an optional Cloudflare Tunnel to publish it (`--profile tunnel` with `CLOUDFLARE_TUNNEL_TOKEN`; point the tunnel's public hostname at `http://web:3000`). Set `BETTER_AUTH_URL` to the public address and `BETTER_AUTH_SECRET` to a long random string.

`.drone.yml` deploys it with Drone's Docker runner: every push is linted, tested and built, and a push to `main` rebuilds and restarts the Compose project on the host. Mark the repo **Trusted** in Drone (the deploy step uses the host's Docker socket) and add the settings as Drone secrets (`better_auth_secret`, `better_auth_url`, `postgres_password`, `vapid_public_key`, `vapid_private_key`, `cron_secret`, `cloudflare_tunnel_token`, and the optional GitHub and Google keys).

## Test

```sh
cd clients/apps/web && npm test
```

## Author

Kartikey Kushwah <kushwah.kartikey@icloud.com>

## License

Copyright © 2026 Kartikey Kushwah. GPL-3.0. You can use, change and share todone; if you distribute a modified version, you must release its source under the GPL too. See [LICENSE](LICENSE).
