# Adapter status

Status is recorded per operation, never per vendor, with a date, in `run.json` under `adapters`.

## Values, weakest to strongest

| Status | Meaning |
|---|---|
| `researched` | Vendor documentation only |
| `present` | The tool exists in this session, unauthenticated |
| `authenticated` | Credentials were accepted |
| `tested` | This operation produced a correct output on this machine, with the date |
| `unavailable` | The operation cannot be used |

Researched, present, authenticated, and tested are four different claims. Never report a stronger one than the evidence supports.

## Rules

- Use an operation only at `authenticated` or above. Anything weaker goes to its fallback, and the report names it.
- The first use of an `authenticated` operation in a run is itself the test; record it as such with the date.
- Each row needs a status, a dated evidence note, and a named fallback.
- The run must complete with every remote operation `unavailable`.

## Operations and fallbacks

| Operation | What it does | Fallback |
|---|---|---|
| `create-design`, `edit-design` | build or change a design in a remote design tool | local composition from the design spec |
| `read-design` | read exact style values from a remote design | a written specification from the user, plus `needs-confirmation` markers |
| `export-still` | export a still from a remote design | headless rasterization of the local composition |
| `render-video` | render a video remotely | local assembly of stills and footage |
| `generate-media` | produce generated images, video, or voice | none; `deny` by default, use `coded-graphics` |
| `schedule-post` | schedule a post | a manual posting package in `delivery.md` |
| `read-metrics` | read the user's own results | none needed; an export the user supplies is read by the scout, and its absence blocks nothing |

## Row format for run.json

`operation`, `backend`, `status`, `date` (YYYY-MM-DD), `evidence` (one line), `fallback`.
