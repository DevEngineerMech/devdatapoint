/// <reference lib="deno.ns" />
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type AppRow = {
  id: string;
  user_id: string;
  name: string;
  app_store_id: string;
  downloads: number;
  impressions: number;
  page_views: number;
  conversion_rate: number;
  avg_play_time: number;
  sessions: number;
};

function base64UrlEncode(input: string) {
  return btoa(input)
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");
}

async function createAppStoreJwt(
  issuerId: string,
  keyId: string,
  privateKeyPem: string,
) {
  const header = {
    alg: "ES256",
    kid: keyId,
    typ: "JWT",
  };

  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: issuerId,
    aud: "appstoreconnect-v1",
    exp: now + 1200,
  };

  const unsignedToken =
    `${base64UrlEncode(JSON.stringify(header))}.${base64UrlEncode(JSON.stringify(payload))}`;

  const pem = privateKeyPem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s+/g, "");

  const binaryDer = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer.buffer,
    {
      name: "ECDSA",
      namedCurve: "P-256",
    },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    {
      name: "ECDSA",
      hash: "SHA-256",
    },
    cryptoKey,
    new TextEncoder().encode(unsignedToken),
  );

  const sig = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");

  return `${unsignedToken}.${sig}`;
}

function getUkInfo() {
  const london = new Intl.DateTimeFormat("en-CA", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    hour12: false,
    timeZone: "Europe/London",
  }).formatToParts(new Date());

  const get = (type: string) =>
    london.find((p) => p.type === type)?.value ?? "";

  const year = Number(get("year"));
  const month = Number(get("month"));
  const day = Number(get("day"));
  const hour = Number(get("hour"));

  const todayUk = `${get("year")}-${get("month")}-${get("day")}`;

  const yesterday = new Date(Date.UTC(year, month - 1, day));
  yesterday.setUTCDate(yesterday.getUTCDate() - 1);

  const yyyy = yesterday.getUTCFullYear();
  const mm = String(yesterday.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(yesterday.getUTCDate()).padStart(2, "0");

  return {
    todayUk,
    yesterdayUk: `${yyyy}-${mm}-${dd}`,
    hourUk: hour,
  };
}

async function fetchAppMetadata(jwt: string, appStoreId: string) {
  const res = await fetch(
    `https://api.appstoreconnect.apple.com/v1/apps/${appStoreId}`,
    {
      headers: {
        Authorization: `Bearer ${jwt}`,
        "Content-Type": "application/json",
      },
    },
  );

  if (!res.ok) {
    throw new Error(
      `App metadata fetch failed for ${appStoreId}: ${await res.text()}`,
    );
  }

  return await res.json();
}

async function fetchAppAnalytics(
  jwt: string,
  appStoreId: string,
  previous: AppRow,
) {
  const headers = {
    Authorization: `Bearer ${jwt}`,
    "Content-Type": "application/json",
  };

  const { yesterdayUk } = getUkInfo();

  let downloads = previous.downloads ?? 0;
  let impressions = previous.impressions ?? 0;
  let pageViews = previous.page_views ?? 0;
  let sessions = previous.sessions ?? 0;
  let avgPlayTime = previous.avg_play_time ?? 0;
  let conversionRate = previous.conversion_rate ?? 0;

  await fetchAppMetadata(jwt, appStoreId);

  try {
    const analyticsRes = await fetch(
      `https://api.appstoreconnect.apple.com/v1/apps/${appStoreId}/analyticsReportRequests`,
      { headers },
    );

    if (analyticsRes.ok) {
      await analyticsRes.json();
    }
  } catch (_) {}

  try {
    const perfRes = await fetch(
      `https://api.appstoreconnect.apple.com/v1/apps/${appStoreId}/appStoreVersions`,
      { headers },
    );

    if (perfRes.ok) {
      await perfRes.json();
    }
  } catch (_) {}

  if (impressions > 0) {
    conversionRate = (downloads / impressions) * 100;
  }

  return {
    downloads,
    impressions,
    pageViews,
    conversionRate,
    avgPlayTime,
    sessions,
    sourceDate: yesterdayUk,
  };
}

async function sendPush(token: string, title: string, body: string) {
  const serverKey = Deno.env.get("FCM_SERVER_KEY");
  if (!serverKey) return;

  const res = await fetch("https://fcm.googleapis.com/fcm/send", {
    method: "POST",
    headers: {
      Authorization: `key=${serverKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      to: token,
      priority: "high",
      notification: {
        title,
        body,
      },
    }),
  });

  if (!res.ok) {
    console.error("FCM push failed:", await res.text());
  }
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !serviceRoleKey) {
      throw new Error("Missing Supabase environment variables.");
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const body = await req.json().catch(() => ({}));
    const userId = body.user_id as string | undefined;
    const force = body.force === true;

    if (!userId) {
      return new Response(
        JSON.stringify({ error: "Missing user_id" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const connectionRes = await supabase
      .from("devdp_connections")
      .select("*")
      .eq("user_id", userId)
      .maybeSingle();

    const connection = connectionRes.data;

    if (!connection) {
      return new Response(
        JSON.stringify({
          ok: true,
          skipped: true,
          reason: "no_connection",
          userId,
        }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const { issuer_id, key_id, private_key, is_pro } = connection;

    const appsRes = await supabase
      .from("devdp_apps")
      .select("*")
      .eq("user_id", userId);

    const apps = (appsRes.data ?? []) as AppRow[];

    if (apps.length === 0) {
      return new Response(
        JSON.stringify({
          ok: true,
          skipped: true,
          reason: "no_apps",
          userId,
        }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const jwt = await createAppStoreJwt(issuer_id, key_id, private_key);

    let totalDownloads = 0;
    let totalImpressions = 0;
    let totalPageViews = 0;
    let totalSessions = 0;
    let weightedPlayTime = 0;

    const changedApps: Array<{
      appId: string;
      name: string;
      downloadsDelta: number;
      impressionsDelta: number;
      pageViewsDelta: number;
    }> = [];

    for (const app of apps) {
      if (!app.app_store_id || app.app_store_id.trim().isEmpty) {
        continue;
      }

      const latest = await fetchAppAnalytics(jwt, app.app_store_id, app);

      const previousDownloads = app.downloads ?? 0;
      const previousImpressions = app.impressions ?? 0;
      const previousPageViews = app.page_views ?? 0;

      const downloadsDelta = Math.max(0, latest.downloads - previousDownloads);
      const impressionsDelta = Math.max(0, latest.impressions - previousImpressions);
      const pageViewsDelta = Math.max(0, latest.pageViews - previousPageViews);

      if (
        downloadsDelta > 0 ||
        impressionsDelta > 0 ||
        pageViewsDelta > 0 ||
        force
      ) {
        changedApps.push({
          appId: app.id,
          name: app.name,
          downloadsDelta,
          impressionsDelta,
          pageViewsDelta,
        });
      }

      await supabase
        .from("devdp_apps")
        .update({
          downloads: latest.downloads,
          impressions: latest.impressions,
          page_views: latest.pageViews,
          conversion_rate: latest.conversionRate,
          avg_play_time: latest.avgPlayTime,
          sessions: latest.sessions,
          last_synced_source_date: latest.sourceDate,
          updated_at: new Date().toISOString(),
        })
        .eq("id", app.id);

      totalDownloads += latest.downloads;
      totalImpressions += latest.impressions;
      totalPageViews += latest.pageViews;
      totalSessions += latest.sessions;
      weightedPlayTime += latest.avgPlayTime * Math.max(1, latest.sessions);
    }

    const averagePlayTime =
      totalSessions > 0 ? weightedPlayTime / totalSessions : 0;

    const overallConversionRate =
      totalImpressions > 0 ? (totalDownloads / totalImpressions) * 100 : 0;

    const prefsRes = await supabase
      .from("devdp_notification_preferences")
      .select("*")
      .eq("user_id", userId)
      .maybeSingle();

    const prefs = prefsRes.data;

    const tokensRes = await supabase
      .from("devdp_device_tokens")
      .select("token")
      .eq("user_id", userId);

    const tokens = (tokensRes.data ?? []) as Array<{ token: string }>;

    const notificationsEnabled = prefs?.enabled !== false;

    if (notificationsEnabled && tokens.length > 0 && (changedApps.length > 0 || force)) {
      let title = "New data available";
      let message = "Your latest app stats are now available";

      if (!is_pro) {
        if (prefs?.generic_free_alert !== false) {
          title = "Your stats are ready";
          message = "Open DevDatapoint to see your latest downloads data";
        }
      } else {
        const useDownloads = prefs?.pro_downloads === true;
        const useImpressions = prefs?.pro_impressions === true;
        const usePageViews = prefs?.pro_page_views === true;
        const useCombined = prefs?.pro_combined_totals !== false;

        if (useCombined) {
          const parts: string[] = [];

          if (useDownloads) parts.push(`${totalDownloads} downloads`);
          if (useImpressions) parts.push(`${totalImpressions} impressions`);
          if (usePageViews) parts.push(`${totalPageViews} page views`);

          if (parts.length > 0) {
            title = "Your app stats updated";
            message = `Your totals now show ${parts.join(" • ")}`;
          }
        } else if (changedApps.length > 0) {
          const first = changedApps[0];
          const parts: string[] = [];

          if (useDownloads && first.downloadsDelta > 0) {
            parts.push(`${first.downloadsDelta} downloads`);
          }
          if (useImpressions && first.impressionsDelta > 0) {
            parts.push(`${first.impressionsDelta} impressions`);
          }
          if (usePageViews && first.pageViewsDelta > 0) {
            parts.push(`${first.pageViewsDelta} page views`);
          }

          if (parts.length > 0) {
            title = `${first.name} updated`;
            message = `${first.name} got ${parts.join(" • ")} yesterday`;
          }
        }
      }

      for (const row of tokens) {
        await sendPush(row.token, title, message);
      }

      await supabase.from("devdp_notification_events").insert({
        user_id: userId,
        title,
        body: message,
        sent_at: new Date().toISOString(),
      });
    }

    return new Response(
      JSON.stringify({
        ok: true,
        userId,
        syncedApps: apps.length,
        totalDownloads,
        totalImpressions,
        totalPageViews,
        overallConversionRate,
        averagePlayTime,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error(error);

    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : "Unknown sync error",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});