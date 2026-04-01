# CrossPaste

CrossPaste is a small Rails and Hotwire app for moving text, links, and short codes between devices with almost no setup. Create a room, share the code, and keep one live text surface in sync across everyone connected to it.

## What It Does

- Creates short-lived rooms with human-readable codes
- Syncs shared text across connected clients with Turbo Streams
- Supports quick join flows from phone or desktop
- Includes QR generation work for easier transfer between devices
- Uses a lightweight dawn/night theme with system-default startup behavior

## Stack

- Rails 8
- Hotwire, Turbo, and Stimulus
- SQLite
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

## Production Notes

This app is set up to run well as a small single-server Rails deployment with Docker. The current live deployment uses:

- Docker on a VPS
- Nginx as the public reverse proxy
- Let’s Encrypt for TLS
- A persistent Docker volume for SQLite and uploaded/generated storage data

Live app:

- `https://crosspaste.mahadimran.me`

Repository:

- `https://github.com/MahadImran/crosspaste`
