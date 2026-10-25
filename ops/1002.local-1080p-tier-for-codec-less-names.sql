-- @operation: export
-- @entity: batch
-- @name: local 1080p tier for codec-less names
-- @exportedAt: 2026-10-25T00:00:00.000Z
-- ============================================================================
-- Fork-local override (not upstreamed).
--
-- The Compact and Efficient profiles give the 1080p WEB-DL and Bluray tier
-- score only through the codec-specific formats (AVC / HEVC), which match
-- the release title. At import, Radarr and Sonarr score the torrent or file
-- name instead of the indexer title. Some uploads are named like
-- "Title (Year).NoTag.mkv", with no codec. Neither tier format matches, the
-- score falls from ~900000 to ~0, and the upgrade gets stuck as "Not a Custom
-- Format upgrade". Source and resolution survive (they are re-parsed from the
-- grab history), the codec does not.
--
-- Two additive formats restore the tier when the name carries no codec at
-- all. They take the HEVC score of each profile that already scores the
-- HEVC variant: the grab was approved on the full indexer title, so a
-- codec-less name at import is lost information, not a downgrade. Titles
-- that name a codec are unaffected. Existing formats and scores are not
-- modified, so upstream merges do not conflict.
-- ============================================================================

-- 1080p WEB-DL No Codec ------------------------------------------------------
INSERT INTO custom_formats (name, description)
SELECT '1080p WEB-DL No Codec', '1080p WEB-DL whose name carries no AVC/HEVC tag (fork-local).'
WHERE NOT EXISTS (SELECT 1 FROM custom_formats WHERE name = '1080p WEB-DL No Codec');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
SELECT '1080p WEB-DL No Codec', v.name, v.type, 'all', v.negate, 1
FROM (
  SELECT '1080p' AS name, 'resolution' AS type, 0 AS negate
  UNION ALL SELECT 'WEB-DL', 'source', 0
  UNION ALL SELECT 'Not HDLight', 'release_title', 1
  UNION ALL SELECT 'Not AVC', 'release_title', 1
  UNION ALL SELECT 'Not HEVC', 'release_title', 1
) v
WHERE NOT EXISTS (
  SELECT 1 FROM custom_format_conditions c
  WHERE c.custom_format_name = '1080p WEB-DL No Codec' AND c.name = v.name
);

INSERT OR IGNORE INTO condition_resolutions (custom_format_name, condition_name, resolution)
VALUES ('1080p WEB-DL No Codec', '1080p', '1080p');
INSERT OR IGNORE INTO condition_sources (custom_format_name, condition_name, source)
VALUES ('1080p WEB-DL No Codec', 'WEB-DL', 'web_dl');
INSERT OR IGNORE INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('1080p WEB-DL No Codec', 'Not HDLight', 'HDLight'),
       ('1080p WEB-DL No Codec', 'Not AVC', 'AVC'),
       ('1080p WEB-DL No Codec', 'Not HEVC', 'HEVC');

-- 1080p Bluray No Codec ------------------------------------------------------
INSERT INTO custom_formats (name, description)
SELECT '1080p Bluray No Codec', '1080p Bluray whose name carries no AVC/HEVC tag (fork-local).'
WHERE NOT EXISTS (SELECT 1 FROM custom_formats WHERE name = '1080p Bluray No Codec');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
SELECT '1080p Bluray No Codec', v.name, v.type, 'all', v.negate, 1
FROM (
  SELECT '1080p' AS name, 'resolution' AS type, 0 AS negate
  UNION ALL SELECT 'Bluray', 'source', 0
  UNION ALL SELECT 'Not AVC', 'release_title', 1
  UNION ALL SELECT 'Not HEVC', 'release_title', 1
) v
WHERE NOT EXISTS (
  SELECT 1 FROM custom_format_conditions c
  WHERE c.custom_format_name = '1080p Bluray No Codec' AND c.name = v.name
);

INSERT OR IGNORE INTO condition_resolutions (custom_format_name, condition_name, resolution)
VALUES ('1080p Bluray No Codec', '1080p', '1080p');
INSERT OR IGNORE INTO condition_sources (custom_format_name, condition_name, source)
VALUES ('1080p Bluray No Codec', 'Bluray', 'bluray');
INSERT OR IGNORE INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('1080p Bluray No Codec', 'Not AVC', 'AVC'),
       ('1080p Bluray No Codec', 'Not HEVC', 'HEVC');

-- Scores: copy the HEVC variant's score, per profile and arr type ------------
INSERT OR IGNORE INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT quality_profile_name, '1080p WEB-DL No Codec', arr_type, score
FROM quality_profile_custom_formats
WHERE custom_format_name = '1080p WEB-DL HEVC' AND score > 0;

INSERT OR IGNORE INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT quality_profile_name, '1080p Bluray No Codec', arr_type, score
FROM quality_profile_custom_formats
WHERE custom_format_name = '1080p Bluray HEVC' AND score > 0;
