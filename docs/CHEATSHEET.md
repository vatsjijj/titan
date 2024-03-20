# Titan "Cheat Sheet"
Where do I begin?

With the classic hello world, of course!

```
"Hello, world!" .
```

*"But wait!! Where's my newline?"* you may cry, and don't worry, we'll get to that.

## Primitive Functions
Titan has a small number of primitive functions, which consists of basic arithmetic operations and comparison operations.

There are some functions of note, though.

- `∪`, known as `UNION`. It will concatenate two quotes together.
- `∘`, known as `APPLY`. It will apply any given quote to the current context.
- `'`, known as `ENQUOTE`. It will transform any value on the top of the stack into a quote.
- `:`, known as `DUP`. It will duplicate the top of the stack.
- `.`, known as `DISPLAY`. It will pop and print the top of the stack to the standard output.
- `/`, known as `SLASH`. No, this is not division. This will pop the top of the stack.
- `⋄`, known as `SNATCH`. This will pull a value `N` deep into the stack to the top of the stack.
- `>s`, known as `MOVESECONDARY`. This will move a value from the top of the stack to the secondary stack.
- `<s`, known as `TAKESECONDARY`. This will move a value from the top of the secondary stack to the main stack.
- `#`, known as `CARDINALITY`. This will pop a quote off the top of the stack and push the length of that quote onto the stack.

## Primitive Types
Titan only has *three* primitive types.

- Quote. Quotes are programs contained within the current program, and are operable data.
- Number. Numbers are, well, numbers. They are represented as 64 bit wide floating point numbers.
- Char. Characters are, you guessed it, characters.

It may look like Titan has a string type, but strings are actually desugared into quotes of characters.