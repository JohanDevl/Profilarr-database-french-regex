-- @operation: export
-- @entity: batch
-- @name: local french missing requires a non-french language
-- @exportedAt: 2026-10-24T00:00:00.000Z
-- ============================================================================
-- Fork-local override (not upstreamed).
--
-- At import, Sonarr scores the torrent or file name instead of the indexer
-- title. Groups such as Amen name their files without a MULTI/VFF tag, so
-- French Missing (-999999) fires and upgrades get stuck as "Not a Custom
-- Format upgrade". The existing "French Except" language condition does not
-- help: in Sonarr, except means "any language other than French", which a
-- French+English file always satisfies.
--
-- A required, negated "Language = French" condition keeps grab-time behaviour
-- (languages there come from the release title) and turns the format off at
-- import when MediaInfo reports a French audio track.
-- ============================================================================
INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
SELECT 'French Missing', 'Not French Language', 'language', 'all', 1, 1
WHERE EXISTS (SELECT 1 FROM custom_formats WHERE name = 'French Missing')
  AND NOT EXISTS (
    SELECT 1 FROM custom_format_conditions
    WHERE custom_format_name = 'French Missing' AND name = 'Not French Language'
  );

INSERT INTO condition_languages (custom_format_name, condition_name, language_name, except_language)
SELECT 'French Missing', 'Not French Language', 'French', 0
WHERE EXISTS (
    SELECT 1 FROM custom_format_conditions
    WHERE custom_format_name = 'French Missing' AND name = 'Not French Language'
  )
  AND NOT EXISTS (
    SELECT 1 FROM condition_languages
    WHERE custom_format_name = 'French Missing' AND condition_name = 'Not French Language'
  );
