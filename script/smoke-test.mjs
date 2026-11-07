import assert from "node:assert/strict"

const base = new URL(process.argv[2])
const home = await fetch(base, { signal: AbortSignal.timeout(5000) })
assert.equal(home.status, 200)
const html = await home.text()
const csrf = html.match(/name="csrf-token" content="([^"]+)"/)?.[1]
const cookie = home.headers.getSetCookie()[0]?.split(";")[0]
assert.ok(csrf && cookie, "Expected a Rails session cookie and CSRF token")

const headers = { "X-CSRF-Token": csrf, Cookie: cookie }
const creation = await fetch(new URL("/rooms", base), {
  method: "POST",
  headers,
  redirect: "manual",
  signal: AbortSignal.timeout(5000)
})
assert.equal(creation.status, 302)
const roomUrl = new URL(creation.headers.get("location"))
assert.match(roomUrl.pathname, /^\/rooms\/[a-z0-9]{6}$/)

// The app is behind a TLS terminator in production. The smoke test connects
// directly to Puma and sends the HTTPS origin a browser would use.
const room = await fetch(new URL(roomUrl.pathname, base), { signal: AbortSignal.timeout(5000) })
assert.equal(room.status, 200)
const stream = (await room.text()).match(/signed-stream-name="([^"]+)"/)?.[1]
assert.ok(stream, "Expected a signed Turbo stream")

const socketUrl = new URL("/cable", base)
socketUrl.protocol = base.protocol === "https:" ? "wss:" : "ws:"
const socket = new WebSocket(socketUrl, {
  protocols: ["actioncable-v1-json"],
  headers: { Origin: roomUrl.origin }
})
const identifier = JSON.stringify({ channel: "Turbo::StreamsChannel", signed_stream_name: stream })
const text = "CrossPaste production smoke test " + "🌙".repeat(3000)

try {
  await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error("Timed out waiting for the Turbo Stream update")), 10000)
    const fail = (error) => {
      clearTimeout(timer)
      reject(error)
    }
    socket.addEventListener("error", () => fail(new Error("Action Cable handshake failed")))
    socket.addEventListener("close", () => fail(new Error("Action Cable closed before the update")))
    socket.addEventListener("message", async ({ data }) => {
      try {
        const event = JSON.parse(data)
        if (event.type === "welcome") {
          socket.send(JSON.stringify({ command: "subscribe", identifier }))
        } else if (event.type === "confirm_subscription") {
          const response = await fetch(new URL(roomUrl.pathname, base), {
            method: "PATCH",
            headers,
            body: new URLSearchParams({ "room[text]": text }),
            redirect: "manual",
            signal: AbortSignal.timeout(5000)
          })
          assert.equal(response.status, 302)
        } else if (event.type === "reject_subscription") {
          throw new Error("Action Cable rejected the room subscription")
        } else if (event.identifier === identifier && typeof event.message === "string") {
          assert.ok(event.message.includes(text), "Expected the saved text in the Turbo Stream")
          clearTimeout(timer)
          resolve()
        }
      } catch (error) {
        fail(error)
      }
    })
  })
} finally {
  socket.close()
}

const updated = await fetch(new URL(roomUrl.pathname, base), { signal: AbortSignal.timeout(5000) })
assert.ok((await updated.text()).includes(text), "Expected the text to be saved in the room")
console.log("Room creation, live sync, and PostgreSQL persistence passed")
