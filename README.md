> **Moved.** todone now lives in the [todone-today](https://github.com/todone-today) organisation, split into [server](https://github.com/todone-today/server), [clients](https://github.com/todone-today/clients), [sdk](https://github.com/todone-today/sdk) and [contributing-docs](https://github.com/todone-today/contributing-docs). This repo is archived; the terminal app's last version is tag `tui-final`.

# todone

**https://todone.today** · An open-source todo app: sticky notes you drag onto a day, a calendar to plan the week on, and teams to share it with. It works offline.

The code is organised like the [Bitwarden](https://github.com/bitwarden) repos, one folder per concern. Each folder stands on its own (its own `package.json`, lockfile and checks) and will become its own repo.

| Folder | What it is |
|---|---|
| [`server/`](server) | The API: accounts and teams (Better Auth), lists, integrations, push reminders, the public calendar and Markdown links, database migrations, Docker Compose |
| [`clients/`](clients) | The apps people use. Today `apps/web`, the Next.js web app |
| [`sdk/`](sdk) | `@todone/sdk`, the logic the server and the apps share: the task model and its Markdown format, calendar maths, export, sync planning |
| [`contributing-docs/`](contributing-docs) | How to run and change it: setup, architecture, design and product notes, the legal and DPDP review |

The terminal app this project started as is retired; its last version is tagged [`tui-final`](../../tree/tui-final).

## Run it

See [contributing-docs/README.md](contributing-docs/README.md). In short: `cd server && npm install && npm run local`, then `cd clients/apps/web && npm install && npm run dev` and open http://localhost:3000.

## License

Copyright © 2026 Kartikey Kushwah. GPL-3.0. You can use, change and share todone; if you distribute a modified version, you must release its source under the GPL too. See [LICENSE](LICENSE).
