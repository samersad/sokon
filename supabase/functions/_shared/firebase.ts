import { importPKCS8, SignJWT } from "npm:jose";

export type FirebaseServiceAccount = {
  project_id: string;
  private_key_id: string;
  private_key: string;
  client_email: string;
  client_id: string;
  auth_uri: string;
  token_uri: string;
  auth_provider_x509_cert_url: string;
  client_x509_cert_url: string;
  universe_domain?: string;
};

function normalizePrivateKey(privateKey: string) {
  return privateKey
    .trim()
    .replace(/^"|"$/g, "")
    .replace(/\\n/g, "\n");
}

async function readServiceAccountSource(source: string) {
  const trimmed = source.trim();
  if (!trimmed) {
    return "";
  }

  if (trimmed.startsWith("{")) {
    return trimmed;
  }

  try {
    return await Deno.readTextFile(trimmed);
  } catch {
    return trimmed;
  }
}

export async function resolveFirebaseServiceAccount() {
  const inlineJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON") ?? "";
  const filePath = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_PATH") ?? "";

  const sourceCandidates = [inlineJson, filePath].filter((value) =>
    value.trim().length > 0
  );

  if (sourceCandidates.length === 0) {
    throw new Error(
      "Missing Firebase service account. Set FIREBASE_SERVICE_ACCOUNT_JSON or FIREBASE_SERVICE_ACCOUNT_PATH.",
    );
  }

  let lastError: string | undefined;
  for (const candidate of sourceCandidates) {
    const serviceAccountJson = await readServiceAccountSource(candidate);
    if (!serviceAccountJson) {
      continue;
    }

    try {
      const parsed = JSON.parse(
        serviceAccountJson,
      ) as Partial<FirebaseServiceAccount>;
      const serviceAccount: FirebaseServiceAccount = {
        project_id: parsed.project_id ?? "",
        private_key_id: parsed.private_key_id ?? "",
        private_key: normalizePrivateKey(parsed.private_key ?? ""),
        client_email: parsed.client_email ?? "",
        client_id: parsed.client_id ?? "",
        auth_uri: parsed.auth_uri ?? "https://accounts.google.com/o/oauth2/auth",
        token_uri: parsed.token_uri ?? "https://oauth2.googleapis.com/token",
        auth_provider_x509_cert_url:
          parsed.auth_provider_x509_cert_url ??
          "https://www.googleapis.com/oauth2/v1/certs",
        client_x509_cert_url: parsed.client_x509_cert_url ?? "",
        universe_domain: parsed.universe_domain,
      };

      if (
        !serviceAccount.private_key ||
        !serviceAccount.client_email ||
        !serviceAccount.token_uri
      ) {
        throw new Error(
          "Firebase service account is missing private_key, client_email, or token_uri.",
        );
      }

      return serviceAccount;
    } catch (error) {
      lastError = error instanceof Error ? error.message : String(error);
    }
  }

  throw new Error(
    `Invalid Firebase service account configuration: ${lastError ?? "no readable JSON source found"}`,
  );
}

export async function getGoogleAccessToken(
  serviceAccount?: FirebaseServiceAccount,
) {
  const resolvedServiceAccount =
    serviceAccount ?? await resolveFirebaseServiceAccount();

  const normalizedServiceAccount: FirebaseServiceAccount = {
    ...resolvedServiceAccount,
    private_key: normalizePrivateKey(resolvedServiceAccount.private_key),
    token_uri: resolvedServiceAccount.token_uri ||
      "https://oauth2.googleapis.com/token",
  };

  const now = Math.floor(Date.now() / 1000);
  const alg = "RS256";
  const key = await importPKCS8(normalizedServiceAccount.private_key, alg);

  const jwt = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg, typ: "JWT" })
    .setIssuer(normalizedServiceAccount.client_email)
    .setAudience(normalizedServiceAccount.token_uri)
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(key);

  const response = await fetch(normalizedServiceAccount.token_uri, {
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
