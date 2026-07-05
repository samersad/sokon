import { createClient } from "jsr:@supabase/supabase-js@2";
import { SignJWT, importPKCS8 } from "npm:jose";

type Payload = {
  receiverId?: string;
  senderId?: string;
  chatId?: string;
  title?: string;
  body?: string;
  type?: string;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

async function getGoogleAccessToken(serviceAccountJson: string) {
  const serviceAccount = JSON.parse(serviceAccountJson);
  const now = Math.floor(Date.now() / 1000);
  const alg = "RS256";
  const key = await importPKCS8(serviceAccount.private_key, alg);

  const jwt = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg, typ: "JWT" })
    .setIssuer(serviceAccount.client_email)
    .setAudience(serviceAccount.token_uri)
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(key);

  const response = await fetch(serviceAccount.token_uri, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`Google token request failed: ${response.status} ${text}`);
  }

  const data = await response.json();
  return data.access_token as string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const {
      receiverId,
      senderId,
      chatId,
      title = "New Message",
      body = "You have a new message.",
      type = "new_message",
    } = (await req.json()) as Payload;

    if (!receiverId) {
      return new Response(
        JSON.stringify({ error: "receiverId is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const serviceAccountJson =
      Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON") ?? "";
    const firebaseProjectId = Deno.env.get("FIREBASE_PROJECT_ID") ?? "";

    if (!supabaseUrl || !serviceRoleKey) {
      throw new Error("Missing Supabase admin environment variables.");
    }
    if (!serviceAccountJson || !firebaseProjectId) {
      throw new Error("Missing Firebase environment variables.");
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey);
    const { data: receiver, error: receiverError } = await supabase
      .from("users")
      .select("fcmToken")
      .eq("id", receiverId)
      .maybeSingle();

    if (receiverError) {
      throw receiverError;
    }

    let senderPhotoUrl = "";
    if (senderId) {
      const { data: sender, error: senderError } = await supabase
        .from("users")
        .select("photoUrl")
        .eq("id", senderId)
        .maybeSingle();

      if (senderError) {
        throw senderError;
      }

      senderPhotoUrl = (sender?.photoUrl as string | null | undefined) ?? "";
    }

    const token = receiver?.fcmToken as string | null | undefined;
    if (!token) {
      return new Response(
        JSON.stringify({ delivered: false, reason: "receiver_has_no_token" }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const accessToken = await getGoogleAccessToken(serviceAccountJson);
    const fcmResponse = await fetch(
      `https://fcm.googleapis.com/v1/projects/${firebaseProjectId}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token,
            notification: {
              title,
              body,
              ...(senderPhotoUrl ? { image: senderPhotoUrl } : {}),
            },
            data: {
              type,
              receiverId,
              senderId: senderId ?? "",
              chatId: chatId ?? "",
              imageUrl: senderPhotoUrl,
            },
            android: {
              priority: "high",
              notification: {
                channel_id: "high_importance_channel",
                ...(senderPhotoUrl ? { image: senderPhotoUrl } : {}),
              },
            },
          },
        }),
      },
    );

    if (!fcmResponse.ok) {
      const text = await fcmResponse.text();
      throw new Error(`FCM send failed: ${fcmResponse.status} ${text}`);
    }

    return new Response(JSON.stringify({ delivered: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
