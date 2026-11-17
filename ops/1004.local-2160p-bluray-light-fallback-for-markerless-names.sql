-- @operation: export
-- @entity: batch
-- @name: local 2160p Bluray light fallback for marker-less names
-- @exportedAt: 2026-11-17T00:00:00.000Z
-- ============================================================================
-- Fork-local override (not upstreamed).
--
-- 2160p Compact FR scores 2160p Bluray encodes only through
-- '2160p 4KLight Bluray', which needs "4KLight" in the name. Indexers often
-- add the marker to the title while the torrent / file name has none, e.g.
--   grab:   Alien.3.1992...MULTi.VFI.2160p.BluRay.4KLight.AC3.5.1.x265-FYT
--   file:   Alien.3.1992...MULTi.VFI.2160p.BluRay.AC3.5.1.x265-FYT.mkv
-- The grab scores ~961200, the file ~1200: the import is refused as
-- "Not a Custom Format upgrade", and once imported by hand the file stays
-- upgradable by anything, so the same 4KLight release gets grabbed again
-- (409 loop, as with the CherryCoke files).
--
-- This additive format gives the '2160p 4KLight Bluray' score back to a
-- 2160p Bluray x265 name WITHOUT the marker, capped at 15 GiB so only
-- light-sized encodes qualify (the 'x265' regex already excludes remuxes).
-- Same score as '2160p 4KLight Bluray', so a marker-less file and the same
-- release with the marker are equal: no regrab loop. Compact team tiers are
-- excluded exactly like in '2160p 4KLight Bluray' (copied, not hard-coded).
-- Existing formats and scores are not modified.
-- ============================================================================

INSERT INTO custom_formats (name, description)
SELECT '2160p Bluray Light Fallback',
       '2160p Bluray x265 up to 15 GiB whose name lost the 4KLight marker (fork-local).'
WHERE NOT EXISTS (SELECT 1 FROM custom_formats WHERE name = '2160p Bluray Light Fallback');

INSERT OR IGNORE INTO custom_format_tags (custom_format_name, tag_name)
SELECT '2160p Bluray Light Fallback', t.tag_name
FROM custom_format_tags t
WHERE t.custom_format_name = '2160p 4KLight Bluray';

-- Fixed conditions ------------------------------------------------------------
INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
SELECT '2160p Bluray Light Fallback', v.name, v.type, 'all', v.negate, 1
FROM (
  SELECT '2160p' AS name, 'resolution' AS type, 0 AS negate
  UNION ALL SELECT 'Bluray', 'source', 0
  UNION ALL SELECT 'x265', 'release_title', 0
  UNION ALL SELECT 'Not 4KLight', 'release_title', 1
  UNION ALL SELECT 'Size', 'size', 0
) v
WHERE NOT EXISTS (
  SELECT 1 FROM custom_format_conditions c
  WHERE c.custom_format_name = '2160p Bluray Light Fallback' AND c.name = v.name
);

INSERT OR IGNORE INTO condition_resolutions (custom_format_name, condition_name, resolution)
VALUES ('2160p Bluray Light Fallback', '2160p', '2160p');
INSERT OR IGNORE INTO condition_sources (custom_format_name, condition_name, source)
VALUES ('2160p Bluray Light Fallback', 'Bluray', 'bluray');
INSERT OR IGNORE INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('2160p Bluray Light Fallback', 'x265', 'x265'),
       ('2160p Bluray Light Fallback', 'Not 4KLight', '4KLight');
INSERT OR IGNORE INTO condition_sizes (custom_format_name, condition_name, min_bytes, max_bytes)
VALUES ('2160p Bluray Light Fallback', 'Size', 1, 16106127360);

-- Compact team exclusions, copied from '2160p 4KLight Bluray' ----------------
INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
SELECT '2160p Bluray Light Fallback', c.name, c.type, c.arr_type, c.negate, c.required
FROM custom_format_conditions c
WHERE c.custom_format_name = '2160p 4KLight Bluray'
  AND c.type = 'release_title' AND c.negate = 1
  AND NOT EXISTS (
    SELECT 1 FROM custom_format_conditions x
    WHERE x.custom_format_name = '2160p Bluray Light Fallback' AND x.name = c.name
  );

INSERT OR IGNORE INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
SELECT '2160p Bluray Light Fallback', p.condition_name, p.regular_expression_name
FROM condition_patterns p
JOIN custom_format_conditions c
  ON c.custom_format_name = p.custom_format_name AND c.name = p.condition_name
WHERE p.custom_format_name = '2160p 4KLight Bluray'
  AND c.type = 'release_title' AND c.negate = 1;

-- Score: same as '2160p 4KLight Bluray', per profile and arr type ------------
INSERT OR IGNORE INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT quality_profile_name, '2160p Bluray Light Fallback', arr_type, score
FROM quality_profile_custom_formats
WHERE custom_format_name = '2160p 4KLight Bluray' AND score > 0;
