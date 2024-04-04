# std.quote
This page will be expanded upon in the future.

## Definitions
| Glyph | Name      | Effect     | Usage                   |
|-------|-----------|------------|-------------------------|
| `⊥`   | `REDUCE`  | `A B -- C` | `[1 2 3] [+] ⊥`         |
| `Σ`   | `SUM`     | `A -- B`   | `[1 2 3] Σ`             |
| `∀`   | `FORALL`  | `A B -- C` | `[1 2 3] [: ×] ∀`       |
| `⊑`   | `PICK`    | `A -- B`   | `3 ⊑`                   |
| `˝`   | `REVERSE` | `A -- B`   | `[1 2 3] ˝`             |
| `@`   | `AT`      | `A B -- C` | `[1 2 3] 0 @`           |
| `∊`   | `FILTER`  | `A B -- C` | `[1 2 3 4] [0 1 0 1] ∊` |
| `⍷`   | `EFILTER` | `A B -- C` | `[1 2 3 4] [2 % 0 =] ⍷` |
| `,,`  | `RANGE`   | `A B -- ?` | `1 10 ,,`               |
| `..`  | `QRANGE`  | `A B -- C` | `1 10 ..`               |