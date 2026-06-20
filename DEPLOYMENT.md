# 🚀 Production Deployment — Backend on Hugging Face Spaces, Frontend on Vercel

This guide takes Liprerie from local docker-compose to a public production
deployment:

- **Backend** (Spring Boot) → Hugging Face **Space** (Docker SDK)
- **Database** → **Neon** managed Postgres
- **Email** → **Resend** (SMTP)
- **Frontend** (Next.js) → **Vercel**
- **Rate limiting** → **Upstash** Redis

```
Browser ──HTTPS──> Vercel (Next.js)  ──server-to-server──> HF Space (Spring Boot) ──> Neon Postgres
   │                                                              │
   └────────── GET /images/** (book covers, direct) ─────────────┘
```

The browser only talks to Vercel, **except** for book-cover images, which are
loaded directly from the backend via `NEXT_PUBLIC_BACKEND_URL`. Passkey
(WebAuthn) ceremonies happen in the browser on the **Vercel** origin — this is
why `WEBAUTHN_RP_ID` / `FRONT_END_ORIGIN` must be the **Vercel** domain, not the
HF domain.

> Deploy order: **DB → Backend → Frontend**. The backend needs the frontend
> origin for CORS/WebAuthn, and the frontend needs the backend URL — so you will
> set one placeholder, deploy, then come back and fill the real URLs (see
> [Cross-wiring](#5-cross-wiring-the-two-domains)).

---

## 1. Database — Neon

1. Create a project at <https://neon.tech> and a database (e.g. `polylivredb`).
2. Copy the **JDBC** connection string (Connection Details → "Java"/"JDBC"),
   keeping `?sslmode=require`. It looks like:
   ```
   jdbc:postgresql://ep-xxxx.eu-central-1.aws.neon.tech/polylivredb?sslmode=require
   ```
3. Note the username and password — these become `SPRING_DATASOURCE_*`.

On first boot `JPA_DDL_AUTO=update` creates the schema and `DataSeeder` loads the
mock catalog. Switch `JPA_DDL_AUTO` to `validate` once the schema is stable.

---

## 2. Email — Resend (SMTP)

1. In <https://resend.com> verify a sending domain (or use `onboarding@resend.dev`
   for testing) and create an **API key**.
2. SMTP settings → `MAIL_*` secrets:
   | Var | Value |
   | --- | --- |
   | `MAIL_HOST` | `smtp.resend.com` |
   | `MAIL_PORT` | `587` |
   | `MAIL_USERNAME` | `resend` |
   | `MAIL_PASSWORD` | your Resend API key (`re_…`) |
   | `MAIL_AUTH` | `true` |
   | `MAIL_STARTTLS` | `true` |
   | `MAIL_FROM` | an address on your verified domain |

Magic-link login fails silently (logged only) without valid SMTP — passkeys
still work.

---

## 3. Backend — Hugging Face Space

The backend repo (`poly-livre-backend`) is HF-ready: it has a `Dockerfile`,
listens on `8080`, and its `README.md` carries the Space front matter
(`sdk: docker`, `app_port: 8080`).

1. Create a new **Space** → SDK **Docker** → **Blank**.
2. Push the backend repo to the Space (from inside the `backend/` submodule):
   ```bash
   cd backend
   git remote add hf https://huggingface.co/spaces/<user>/<space-name>
   git push hf HEAD:main
   ```
   (Authenticate with an HF access token as the git password.)
3. In **Space → Settings → Variables and secrets**, add everything from
   [`backend/.env.example`](./backend/.env.example). Mark credentials as
   **Secrets**; `SERVER_PORT`, `RP_NAME`, `*_LOG_LEVEL` can be plain Variables.

   **Critical:**
   - `SPRING_PROFILES_ACTIVE=prod` — enables fail-fast + INFO logging.
   - **Generate fresh JWT keys** (commands in `backend/.env.example`). Do **not**
     reuse the committed dev keys — they are public and tokens would be forgeable.
   - `WEBAUTHN_RP_ID` = Vercel domain only, e.g. `your-app.vercel.app`
     (no `https://`, no port, no path).
   - `FRONT_END_ORIGIN` = full Vercel origin, e.g. `https://your-app.vercel.app`.

4. The Space builds the Docker image and starts. Verify:
   - `https://<user>-<space>.hf.space/swagger-ui/index.html`
   - `https://<user>-<space>.hf.space/v3/api-docs` (used by the healthcheck)

> HF free CPU Spaces sleep when idle and Neon auto-suspends, so the first request
> after inactivity is slow (cold start). That's expected for a demo.

---

## 4. Frontend — Vercel

1. Import the `poly-livre-frontend` repo in Vercel (framework auto-detected as
   Next.js; no `vercel.json` needed).
2. Add the environment variables from [`frontend/.env.example`](./frontend/.env.example)
   for the **Production** environment:
   - `BACKEND_URL` and `NEXT_PUBLIC_BACKEND_URL` → the HF Space URL.
   - `NEXT_PUBLIC_TESTING_MODE=true` (keeps the password gate; the password is
     the backend `APP_PASSWORD`).
   - `UPSTASH_REDIS_REST_URL` / `UPSTASH_REDIS_REST_TOKEN` — **required in prod**
     (rate limiting throws without them). Create a free DB at <https://upstash.com>.
3. Deploy. Note the resulting domain (e.g. `your-app.vercel.app`).

---

## 5. Cross-wiring the two domains

Because each side references the other, finalise after both exist:

1. Set the HF Space `FRONT_END_ORIGIN` + `WEBAUTHN_RP_ID` to the **real Vercel
   domain** and restart the Space.
2. Set the Vercel `BACKEND_URL` + `NEXT_PUBLIC_BACKEND_URL` to the **real HF
   Space URL** and redeploy.
3. If you later add a custom domain on Vercel, update `WEBAUTHN_RP_ID` /
   `FRONT_END_ORIGIN` to match — **existing passkeys stop working if the rp-id
   changes**, since they are bound to the original domain.

---

## 6. Post-deploy smoke test

- [ ] Open the Vercel URL → redirected to `/auth-testing-mode`.
- [ ] Enter `APP_PASSWORD` → reach the catalog; **book covers load** (proves
      `NEXT_PUBLIC_BACKEND_URL` + `/images/**` work).
- [ ] Swagger UI reachable on the HF Space.
- [ ] Register a passkey, then log in with it (proves `WEBAUTHN_RP_ID` /
      `origin` are correct).
- [ ] Request a magic link → email arrives from `MAIL_FROM` (proves Resend SMTP).
- [ ] HF logs show `The following 1 profile is active: "prod"` and INFO-level
      logging (no DEBUG, no leaked SQL/secrets).

---

## What changed for production (summary)

| Area | Before | After |
| --- | --- | --- |
| Secrets | JWT keys + `APP_PASSWORD` had working committed defaults | `prod` profile requires them (fail-fast); fresh keys mandated |
| WebAuthn `rp-id` | reused DB `HOST` (broken cross-domain) | dedicated `WEBAUTHN_RP_ID` = frontend domain |
| Server port | implicit 8080 | env-driven (`SERVER_PORT`/`PORT`), `app_port: 8080` declared for HF |
| Logging | `DEBUG` hardcoded | env-driven, `INFO` in prod |
| Database | compose-only Postgres | `SPRING_DATASOURCE_URL` passthrough → Neon |
| Email `From` | unset (Resend would reject) | `MAIL_FROM` set on every message |
| Backend image | no dep cache / healthcheck | cached deps, container-aware heap, healthcheck |
| Next images | only `http://localhost` allowed | `https://*.hf.space` allowed |

See per-service variable references in [`backend/.env.example`](./backend/.env.example)
and [`frontend/.env.example`](./frontend/.env.example).
