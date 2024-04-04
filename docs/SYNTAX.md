# Syntax
Titan's syntax is detailed in this file, hopefully in a rather clean and clear manner.

## Ordering
Titan is a [concatenative language](https://concatenative.org/wiki/view/Concatenative%20language). That means that you compose functions rather than just applying them. Titan is evaluated from left to right and therefore follows a more traditional postfix notation ordering.

## Comments
Comments in Titan are prefixed with the glyph `⋮` and continue until the end of the line.

```
⋮ This is a comment!
⋮ There are only comments that span single lines, not multiple.
```

## Functions
Functions in Titan are declared with the `==` token.

```
add2 == [2 +]
```

An identifier is expected on the left side and a quotation is expected on the right side.

## Quotations
Quotations are integral to Titan and are generally considered the core of the language. Anything between `[` and `]` is considered part of the quotation, and strings are desugared into quotations of characters.

```
[1 2 3]
[`a` `b` `c`]
[3 2 1 + ×]
[[1 2] [3 4]]
"Hello, world!"
```

## Imports
Titan handles file imports with the `using` keyword.

```
using std.out
```