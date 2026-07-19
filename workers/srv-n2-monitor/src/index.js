const TARGETS = ["https://libresearch.space/", "https://pasted.space/"];
const TIMEOUT_MS = 10000;

async function probe(url) {
  try {
    const res = await fetch(url, {
      redirect: "manual",
      signal: AbortSignal.timeout(TIMEOUT_MS),
      headers: { "cache-control": "no-cache" },
      cf: { cacheTtl: 0 },
    });
    return { url, ok: res.status < 500, status: res.status };
  } catch (e) {
    return { url, ok: false, status: 0, detail: String(e) };
  }
}

async function notify(env, text) {
  if (!env.ALERT_WEBHOOK) return;
  const res = await fetch(env.ALERT_WEBHOOK, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ content: text }),
  });
  if (!res.ok) {
    console.error(JSON.stringify({ msg: "alert delivery failed", status: res.status }));
  }
}

export default {
  async scheduled(_, env) {
    const results = await Promise.all(TARGETS.map(probe));

    for (const r of results) {
      const prev = await env.STATE.get(r.url);
      if (!r.ok && prev !== "down") {
        await notify(env, `🔴 **DOWN** ${r.url} (status ${r.status})`);
        await env.STATE.put(r.url, "down");
      } else if (r.ok && prev === "down") {
        await notify(env, `🟢 **RECOVERED** ${r.url} (status ${r.status})`);
        await env.STATE.put(r.url, "up");
      }
      console.log(JSON.stringify(r));
    }

    const down = results.filter((r) => !r.ok);
    if (down.length) {
      throw new Error(`down: ${down.map((r) => `${r.url} (${r.status})`).join(", ")}`);
    }
  },
};
