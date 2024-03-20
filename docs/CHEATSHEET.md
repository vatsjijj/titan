# Titan "Cheat Sheet"
Where do I begin?

Maybe with some arithmetic?

```
1 2 + 3 × 3 - 2 ÷
```

Some comments?

```
⋮ Comment one!
⋮ Comment two!!!
```

Oh, I know!

With the classic hello world, of course!

```
"Hello, world!" .
```

*"But wait!! Where's my newline?"*

Don't worry, we'll get to that.

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

*"Wait? No SWAP, ROT, OVER, or anything else? This language is utterly useless!"*

Again, don't worry, wait a bit more and I'll get to that later.

## Primitive Types
Titan only has *three* primitive types.

- Quote. Quotes are programs contained within the current program, and are operable data.
- Number. Numbers are, well, numbers. They are represented as 64 bit wide floating point numbers.
- Char. Characters are, you guessed it, characters.

It may look like Titan has a string type, but strings are actually desugared into quotes of characters.

## Imports
Imports in Titan are extremely easy, and this may be the shortest section of this sheet.

```
using std.out
```

And that's it. It searches for a file located at `$(cwd)/std/out.ttn`, reads it, and takes a pass over it. Simple.

## Quotes and Functions
In Titan, programs and functions depend heavily on quotes. As you may have noticed, the predefined functions you currently have at your desposal are extremely limited and are useless on their own.

This is why you may (will) want to define new functions. Functions are quotes that are applied implicitly, and this makes them quite efficient.

You can define new functions very easily.

```
add2 == [2 +]

decr == [1 -]

incr == [1 +]
```

This is the heart of Titan, and is the main way you will write programs. In fact, this is likely going to be the last section of this cheat sheet! Titan is extremely simple.

In fact, let's define a very useful function. Something you'll probably want to use.

```
⟷ == [1 ⋄]
```

This is `SWAP` in all of its glory. It pulls the second element on the stack to the top. In fact, defining `ROT` is just as easy.

```
⍉ == [2 ⋄]
```

You want `OVER`? Well here you go!

```
≍ == [⟷ : ⍉ ⟷]
```

But enough with these *boring* functions, let's do something extra useful. Something like... Defining a conditional `IF`!

```
?  == [⋄ ⟷ / ∘]
```

*"Wait... That's it?!"*

Yes, yes it is, considering we have `TRUE` and `FALSE` defined as `[1]` and `[0]` respectively, this is actually extremely clever.

It pulls the respective condition, swaps it out with the unneeded one, slashes it, and then applies the needed condition.

And just like that, you have `IF`!

```
["True!" .] ["False!" .] T ?
```

Want a loop? Easy!

```
∇ == [
   1 -
   >s2
   :s2 /
   [<s2 ∇] ∪
   [<s2 / /]
   :s ¬1 ≠ ?
]
```

Okay, admittedly, this is *not* so easy, and uses many words defined in the standard library. This would take a while to explain actually, but it's used quite simply.

```
["Loop! " .] 5 ∇
```

This will loop five times, unsurprisingly printing `Loop! ` five times as well.

Now remember how much you wanted that newline? You've earned it, here it is.

```
.nl == [`%n` ⟷ . .]
```

__*More will likely be added to this document in the future.*__