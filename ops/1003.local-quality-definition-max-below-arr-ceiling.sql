-- @operation: export
-- @entity: batch
-- @name: local quality definition max below arr ceiling
-- @exportedAt: 2026-10-25T00:00:00.000Z
-- ============================================================================
-- Fork-local override (not upstreamed).
--
-- The quality definitions set max_size to the arr ceiling (Sonarr 1000,
-- Radarr 2000 MB/min), meaning "unlimited". Profilarr's drift check rewrites
-- an actual max equal to that ceiling to null, but compares it with the
-- stored 1000 / 2000 as is (max_size is NOT NULL). Every quality then shows
-- as drifted ("Quality Definitions 0 / 1") although the sync applied fine.
--
-- One below the ceiling is still effectively unlimited, and the drift check
-- compares like with like. Preferred sizes (990 / 1990) stay below the max.
-- ============================================================================
UPDATE sonarr_quality_definitions
SET max_size = 999
WHERE max_size >= 1000;

UPDATE radarr_quality_definitions
SET max_size = 1999
WHERE max_size >= 2000;
