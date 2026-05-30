import "jsr:@supabase/functions-js/edge-runtime.d.ts"

interface PrayerTimesRow {
  date: string
  fajr: string
  sunrise: string
  dhuhr: string
  asr: string
  maghrib: string
  isha: string
  timezone: string
}

function clean(raw: string): string {
  const space = raw.indexOf(" ")
  return space > 0 ? raw.substring(0, space) : raw
}

function schemaHeaders(key: string, schema: string): Record<string, string> {
  return {
    "Content-Type": "application/json",
    apikey: key,
    Authorization: `Bearer ${key}`,
    "Accept-Profile": schema,
    "Content-Profile": schema,
  }
}

Deno.serve(async (req: Request) => {
  const url = new URL(req.url)
  const date = url.searchParams.get("date") ?? new Date().toISOString().split("T")[0]
  const lat = url.searchParams.get("lat") ?? "21.4225"
  const lng = url.searchParams.get("lng") ?? "39.8262"
  const method = url.searchParams.get("method") ?? "4"

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!

  const cacheRes = await fetch(
    `${supabaseUrl}/rest/v1/rpc/get_prayer_times_cached`,
    {
      method: "POST",
      headers: schemaHeaders(supabaseKey, "qadaa"),
      body: JSON.stringify({ p_date: date }),
    },
  )

  if (cacheRes.ok) {
    const cached: PrayerTimesRow[] = await cacheRes.json()
    if (Array.isArray(cached) && cached.length > 0) {
      return new Response(JSON.stringify(cached[0]), {
        headers: { "Content-Type": "application/json" },
      })
    }
  }

  const apiUrl =
    `https://api.aladhan.com/v1/timings/${date}?latitude=${lat}&longitude=${lng}&method=${method}`
  const apiRes = await fetch(apiUrl)

  if (!apiRes.ok) {
    return new Response(JSON.stringify({ error: "Failed to fetch prayer times" }), {
      status: 502,
      headers: { "Content-Type": "application/json" },
    })
  }

  const apiData = await apiRes.json()
  const timings = apiData.data.timings as Record<string, string>
  const meta = apiData.data.meta as Record<string, unknown>

  const row: PrayerTimesRow = {
    date,
    fajr: clean(timings["Fajr"]),
    sunrise: clean(timings["Sunrise"]),
    dhuhr: clean(timings["Dhuhr"]),
    asr: clean(timings["Asr"]),
    maghrib: clean(timings["Maghrib"]),
    isha: clean(timings["Isha"]),
    timezone: (meta["timezone"] as string) ?? "Asia/Amman",
  }

  const insertRes = await fetch(`${supabaseUrl}/rest/v1/prayer_times`, {
    method: "POST",
    headers: schemaHeaders(supabaseKey, "qadaa"),
    body: JSON.stringify(row),
  })
  if (!insertRes.ok) {
    console.error("Cache insert failed:", await insertRes.text())
  }

  return new Response(JSON.stringify(row), {
    headers: { "Content-Type": "application/json" },
  })
})
