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

Deno.serve(async (req: Request) => {
  const url = new URL(req.url)
  const date = url.searchParams.get("date") ?? new Date().toISOString().split("T")[0]
  const lat = url.searchParams.get("lat") ?? "21.4225"
  const lng = url.searchParams.get("lng") ?? "39.8262"
  const method = url.searchParams.get("method") ?? "4"

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!

  const headers = {
    "Content-Type": "application/json",
    apikey: supabaseKey,
    Authorization: `Bearer ${supabaseKey}`,
  }

  const cacheRes = await fetch(
    `${supabaseUrl}/rest/v1/rpc/qadaa.get_prayer_times_cached`,
    {
      method: "POST",
      headers,
      body: JSON.stringify({ p_date: date }),
    },
  )

  if (cacheRes.ok) {
    const cached: PrayerTimesRow | null = await cacheRes.json()
    if (cached) {
      return new Response(JSON.stringify(cached), {
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

  await fetch(`${supabaseUrl}/rest/v1/qadaa/prayer_times`, {
    method: "POST",
    headers,
    body: JSON.stringify(row),
  }).catch(() => {})

  return new Response(JSON.stringify(row), {
    headers: { "Content-Type": "application/json" },
  })
})
