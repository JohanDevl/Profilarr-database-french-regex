-- @operation: export
-- @entity: batch
-- @name: local finite max for open-ended size bands
-- @exportedAt: 2026-10-24T00:00:00.000Z
-- ============================================================================
-- Fork-local override (not upstreamed).
--
-- The top size bands ("... Size > N GiB") leave max_bytes NULL. Profilarr
-- compiles NULL to `max: 0`, and Sonarr/Radarr reject the custom format with
-- "'Max' must be greater than 'N'", so those bands never reach the Arrs.
-- Give every open-ended band a 1000 GiB ceiling. The statement is a no-op
-- once upstream bounds them, and it also covers bands added later.
-- ============================================================================
UPDATE condition_sizes
SET max_bytes = 1073741824000
WHERE max_bytes IS NULL
  AND min_bytes IS NOT NULL;
