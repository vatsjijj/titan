# Builtins
This page will be expanded upon in the future.

## Definitions
| Glyph | Name           | Effect     | Usage           |
|-------|----------------|------------|-----------------|
| `+`   | `PLUS`         | `A B -- C` | `1 2 +`         |
| `-`   | `MINUS`        | `A B -- C` | `1 2 -`         |
| `×`   | `TIMES`        | `A B -- C` | `1 2 ×`         |
| `÷`   | `DIVIDE`       | `A B -- C` | `1 2 ÷`         |
| `%`   | `MODULO`       | `A B -- C` | `1 2 %`         |
| `\|`  | `ABSOLUTE`     | `A -- B`   | `¬10 \|`        |
| `∪`   | `UNION`        | `A B -- C` | `[1 2] [3 4] ∪` |
| `∘`   | `APPLY`        | `A -- ?`   | `[1 2 3 4] ∘`   |
| `'`   | `ENQUOTE`      | `A -- B`   | `1 '`           |
| `:`   | `DUP`          | `A -- A A` | `1 :`           |
| `=`   | `EQUAL`        | `A B -- C` | `1 2 =`         |
| `≠`   | `NOTEQUAL`     | `A B -- C` | `1 2 ≠`         |
| `.`   | `DISPLAY`      | `A -- `    | `1 .`           |
| `/`   | `SLASH`        | `A -- `    | `1 /`           |
| `⋄`   | `SNATCH`       | `? -- ?`   | `2 1 0 2 ⋄`     |
| `<`   | `LESS`         | `A B -- C` | `1 2 <`         |
| `>`   | `GREATER`      | `A B -- C` | `1 2 >`         |
| `≤`   | `LESSEQUAL`    | `A B -- C` | `1 2 ≤`         |
| `≥`   | `GREATEREQUAL` | `A B -- C` | `1 2 ≥`         |
| `>s`  | `MOVS`         | `A -- `    | `1 >s`          |
| `<s`  | `TAKES`        | ` -- A`    | `<s`            |
| `#`   | `CARDINALITY`  | `A -- B`   | `[1 2 3] #`     |

**Note**: Secondary stack effects are not shown.