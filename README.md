# CrossPaste

[![CI](https://github.com/MahadImran/crosspaste/actions/workflows/ci.yml/badge.svg)](https://github.com/MahadImran/crosspaste/actions/workflows/ci.yml)

CrossPaste is a small Rails and Hotwire app for moving text, links, and short codes between devices with almost no setup. Create a room, share the code, and keep one live text surface in sync across everyone connected to it.

## What It Does

- Creates short-lived rooms with human-readable codes
- Syncs shared text across connected clients with Turbo Streams
- Supports quick join flows from phone or desktop
- I̶n̶c̶l̶u̶d̶e̶s̶ ̶Q̶R̶ ̶g̶e̶n̶e̶r̶a̶t̶i̶o̶n̶ ̶w̶o̶r̶k̶ ̶f̶o̶r̶ ̶e̶a̶s̶i̶e̶r̶ ̶t̶r̶a̶n̶s̶f̶e̶r̶ ̶b̶e̶t̶w̶e̶e̶n̶ ̶d̶e̶v̶i̶c̶e̶s̶  (Not Yet!)
- Uses a lightweight dawn/night theme with system-default startup behavior

## Stack

- Rails 8
- Hotwire, Turbo, and Stimulus
- SQLite locally and PostgreSQL on managed hosting
- RQRCode
- Docker for production runtime

## Local Development

Requirements:

- Ruby `3.3.10`
- Bundler

Setup:

```bash
bundle install
bin/rails db:prepare
bin/dev
```

If you are not using the Rails dev script, you can also run:

```bash
bin/rails server
```

Then open `http://127.0.0.1:3000`.

## Test Suite

```bash
bin/rails test
```

## Hosting and CI/CD

GitHub Actions runs Rails tests, lint, dependency audits, and a production Docker
smoke test against PostgreSQL. The smoke test creates a room, saves text, and verifies the Turbo Stream over a WebSocket.

1. Create a free [Neon](https://console.neon.tech/) project for this app. Copy the
   direct PostgreSQL connection string with TLS enabled.
2. In [Render](https://dashboard.render.com/), choose **New → Blueprint** and connect
   this GitHub repository. The Blueprint selects a free Docker web service and
   prompts for the connection string as `DATABASE_URL`.
3. After the first deploy, open the service URL and check `/up`. Render deploys
   subsequent updates to `main` after GitHub checks pass.

The Docker entrypoint runs `bin/rails db:prepare` before starting Puma.
Keep one Puma process and one web instance for room broadcasts. A deploy can
briefly disconnect sockets. The Blueprint generates and retains the Rails
session secret and room encryption keys.

Render Free has a shared monthly allowance across services and can take about
a minute to start after going idle. See [Render's free tier](https://render.com/docs/free)
and [Neon plans](https://neon.com/pricing).
