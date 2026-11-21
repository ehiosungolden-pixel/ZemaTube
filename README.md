# ZemaTube

A responsive YouTube-inspired video-sharing app starter built with React, Vite and Supabase. It includes a dark/light interface, home feed, categories, search, Shorts-style discovery page, watch page, authentication UI, upload flow, and a Supabase schema for profiles, videos, comments, likes and subscriptions.

## 1. Run locally

Install Node.js 20+ then:

```bash
npm install
cp .env.example .env
npm run dev
```

Open the local URL printed by Vite.

## 2. Connect Supabase

1. Create a project at https://supabase.com.
2. Open **SQL Editor** in your Supabase dashboard.
3. Paste and run `supabase/schema.sql`.
4. In **Project Settings → API**, copy the Project URL and anon/public key.
5. Put them in `.env` as `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.
6. Restart `npm run dev`.

Never put a Supabase service-role key in frontend code.

## 3. Current implementation

- Auth: Supabase email/password sign-up and sign-in.
- Upload: video upload to the `videos` Storage bucket and metadata insert.
- Feed: loads public videos from Supabase when available; otherwise sample demo cards are shown.
- Watch page: player, related videos, local interactive likes/subscriptions/comments prototype.
- Theme preference: saved locally in the browser.

## 4. Important next production steps

This is a functional starter, not yet a production-scale YouTube replacement. Before public launch, add:
- Persisted likes, comments, subscriptions and watch history (the database tables are included).
- Video view counting and creator/channel pages.
- Thumbnail upload and editing.
- Video transcoding into adaptive HLS/DASH, CDN delivery, resumable uploads and storage quotas. Supabase Storage alone is not a complete streaming pipeline.
- Search indexing, moderation/reporting, copyright process, abuse prevention and rate limits.
- Admin dashboard, analytics, accessibility testing, backups and privacy/terms pages.

Large video hosting and transcoding can become expensive. Set upload limits and usage alerts before inviting public users.
