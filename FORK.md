# Fork notes

Working fork of [Jojont54/Profilarr-database-french-regex](https://github.com/Jojont54/Profilarr-database-french-regex). Local changes stay here and are never sent upstream as pull requests.

## Local ops

Local changes live in `ops/` as files numbered **1000 and up**. Profilarr applies ops in numeric order and refuses two files with the same number. Upstream numbers stay low, so the two sets never collide, and local ops always run after upstream ops.

Write local ops so they still work when upstream changes the same rows: guarded `INSERT ... WHERE NOT EXISTS` and `UPDATE ... WHERE <old state>`, never a blind `DELETE` + `INSERT`.

| Op | Why |
| --- | --- |
| `1000.local-finite-max-for-open-ended-size-bands.sql` | Open-ended size bands compile to `max: 0`, which the Arrs reject with HTTP 400 |
| `1001.local-french-missing-require-non-french-language.sql` | French Missing fires at import on file names without a language tag (Amen), which blocks upgrades |

## Syncing upstream

```sh
git fetch upstream
git merge upstream/stable
git push origin stable
```

The `upstream` remote has its push URL disabled. If a merge conflicts, it can only be in a file that both sides edited (README, `pcd.json`). Keep upstream's version unless a local change is meant to override it.
