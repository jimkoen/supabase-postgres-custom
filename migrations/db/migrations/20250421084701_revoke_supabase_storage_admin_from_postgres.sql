-- migrate:up
revoke supabase_storage_admin from postgres;
revoke create on schema storage from postgres;
revoke all on storage.migrations from anon, authenticated, service_role, postgres;

revoke supabase_auth_admin from postgres;
revoke create on schema auth from postgres;
revoke all on auth.schema_migrations from dashboard_user, postgres;

revoke supabase_realtime_admin from postgres;
revoke create on schema realtime from postgres;
revoke all on schema_migrations from postgres, dashboard_user, anon, authenticated, service_role;

-- migrate:down
