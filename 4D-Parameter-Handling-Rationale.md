# Input parameters in 4D: why they stay read-only, and how to default a missing optional parameter

**Audience:** Claude Code (or any developer) working in a 4D project.
**Scope:** project methods and class functions declared with `#DECLARE` /
`Function`. Covers 4D v19 through v21-R3, with the v19 differences called out
explicitly.

All version-specific claims below were checked against the offline 4D
documentation set (`Concepts/parameters`, `Concepts/data-types`,
`Concepts/interpreted`, `Concepts/dt_collection`, and the `Count parameters`
command page) for versions 18, 19, 20 and 21-R3. Where the documentation
changed between versions, the change is stated.

---

## 1. The two rules

1. **Never assign to an input parameter.** Treat `$inFoo_t`, `$1`, `$2` … as
   immutable within the method. If you need a modified or defaulted value,
   copy it into a working local variable and modify that.
2. **Detect a missing optional parameter with `Count parameters`, not by
   inspecting the parameter's value.**

The canonical shape:

```4d
#DECLARE($inValue_t : Text; $inStart_i : Integer)->$result_i : Integer

var $startAt_i : Integer

If (Count parameters<2)
	$startAt_i:=1
Else 
	$startAt_i:=$inStart_i
End if 

// …everything below uses $startAt_i, never $inStart_i
```

The rest of this document explains why.

---

## 2. What a 4D parameter actually is

From `Concepts/parameters` → *Values or references* (wording identical in v19
and v21-R3):

> When you pass a parameter, 4D always evaluates the parameter expression in
> the context of the calling method and sets the *resulting value* to the local
> variables in the class function or subroutine. … Since its scope is local, if
> the value of a parameter is modified in the class function/subroutine, it
> does not change the value in the calling method.

So for **scalars** (Text, Integer, Real, Boolean, Date, Time, Picture, BLOB,
Pointer), a parameter is a local copy. Writing `$1:=Uppercase($1)` is legal and
harmless to the caller. The 4D documentation itself uses exactly that example.

For **Object and Collection**, the same section adds a critical qualification
(*Particular cases: objects and collections*):

> Object and Collection data types can only be handled through a reference
> (i.e. an internal *pointer*). Consequently, when using such data types as
> parameters, `$1, $2...` do not contain *values* but *references*. Modifying
> the value of the `$1, $2...` parameters within the subroutine will be
> propagated wherever the source object or collection is used.

This asymmetry is the root of the whole convention. Two statements that look
almost identical do entirely different things:

```4d
$inOptions_o.verbose:=True   // mutates the CALLER's object
$inOptions_o:=New object     // rebinds the LOCAL alias only; caller unaffected
```

(4D Server note from the same section: when parameters cross machines — for
example with *Execute on Server* — copies are sent instead of references, so
the mutation-propagates behaviour silently stops being true. One more reason
not to build logic on it.)

---

## 3. Why not to reassign an input parameter

Reassignment is not illegal and it does not corrupt 4D's parameter stack. The
objections are about correctness of reasoning and maintainability, and one of
them is a real bug class.

### 3.1 It creates two disagreeing sources of truth

`Count parameters` reports **how many arguments the caller actually passed**.
It is fixed for the duration of the call and is unaffected by anything you
assign. So after this:

```4d
If (Count parameters<2)
	$inStart_i:=1          // BAD: defaulting into the parameter
End if 
```

…the method is in a state where `$inStart_i=1` but `Count parameters` still
says the second argument was never supplied. Any later code — a logging call,
a guard, a pass-through to a lower layer, a maintainer's `Count parameters>=2`
test added six months from now — will read the arity and reach the opposite
conclusion from the variable. Keeping `$inStart_i` pristine means the two
signals never diverge: the parameter is *what the caller said*, the working
local is *what we decided*.

This matters most in layered code that forwards arguments downward, where the
lower layer re-derives its own defaults.

### 3.2 The object case is an actual bug, not a style preference

Consider "defaulting" an omitted object parameter by assigning to it, then
populating it:

```4d
#DECLARE($inName_t : Text; $inOptions_o : Object)

If (Count parameters<2)
	$inOptions_o:=New object      // BAD
End if 

$inOptions_o.resolved:=True       // sometimes visible to the caller,
                                  // sometimes not
```

The behaviour of the last line now depends on the call site:

- Caller **omitted** the argument → `$inOptions_o` is a brand-new local object;
  the caller sees nothing.
- Caller **passed** an object → `$inOptions_o` is the caller's reference; the
  caller's object is silently mutated.

Same code, two different contracts, decided by arity. Copy into a working
variable and the ambiguity disappears, because the intent is now written down:

```4d
var $options_o : Object

If (Count parameters<2) | ($inOptions_o=Null)
	$options_o:=New object        // v19-safe; v20+ may use {}
Else 
	$options_o:=$inOptions_o      // deliberate: shares the caller's reference
End if 
```

If the method must *not* mutate the caller's object, make that explicit too —
`$options_o:=OB Copy($inOptions_o)`.

### 3.3 You lose the original argument

Error messages, logging, retry logic, and post-hoc validation all want the
value as supplied. `OTr`-style code that reports *"index 0 out of range for
array 'x'"* needs the offending input, not the clamped substitute. Once
overwritten, the original is unrecoverable.

The same applies in the 4D debugger: the parameter rows in the Watch pane are
the most direct evidence of what the caller did. Overwriting them removes the
first thing you would look at.

### 3.4 Sentinel defaults collide with legitimate values

Because a defaulted parameter is indistinguishable from a passed one, teams
reach for sentinels (`-1`, `""`, `0`) to mark "not supplied". Every sentinel is
a value some caller will eventually pass in earnest. Arity is the only signal
that cannot collide with data.

### 3.5 The type is fixed anyway

A declared parameter's type is fixed by the `#DECLARE` / `Function` prototype
and cannot be changed (`Concepts/interpreted`: *"You cannot change the data
type of any variable or array"* in compiled mode). So the parameter is a poor
scratch variable regardless — it can only ever hold one type, and the compiler
will reject the flexible use you were reaching for.

Note also (v21-R3, *Returned value*): a parameter name may be declared only
once, and the same name cannot serve as both input and output —
`Function myTransform($x : Integer) -> $x : Integer` is an error. 4D's own
design pushes input and output apart; the convention follows it.

### 3.6 It makes the naming convention load-bearing

With an `$inXxx_` prefix and a no-reassignment rule, a reader can trust the
prefix absolutely: anything named `$in…` is the caller's data, unmodified,
anywhere in the method. That is a property worth more than the two lines it
costs.

---

## 4. Detecting a missing optional parameter

### 4.1 `Count parameters` is the only reliable test

From the `Count parameters` command page: *"Number of parameters actually
passed."* Everything else fails:

| Test | Why it fails |
|---|---|
| `$inStart_i=0` | Indistinguishable from a caller who passed `0`. |
| `$inName_t=""` | Indistinguishable from a caller who passed `""`. |
| `Undefined($inStart_i)` | `Concepts/interpreted` states that in **compiled** mode *"the `Undefined` function always returns False for variables. Variables are always defined."* The test therefore behaves differently interpreted vs compiled — the worst possible failure mode. |
| `$inOptions_o=Null` | Works only for Object/Collection, and still cannot distinguish "omitted" from "explicitly passed `Null`". Useful **in addition to** the arity test, not instead of it. |

Why the value tests are hopeless: `Concepts/parameters` → *Initialization*
(present from v19 onward) states that declared parameters *"are initialized to
the default value corresponding to their type, which they will keep during the
session as long as they have not been assigned."* A missing parameter is
therefore not "absent" — it is a perfectly ordinary empty value of the right
type, byte-for-byte identical to one a caller could have passed.

The v19 default-value table (`Concepts/data-types` → *Default values*):

| Type | Default |
|---|---|
| Text | `""` |
| Integer / Real | `0` |
| Boolean | `False` |
| Date | `00-00-00` |
| Time | `00:00:00` |
| Picture | size 0 |
| BLOB | size 0 |
| Pointer | `Nil=true` |
| **Object** | **`null`** |
| **Collection** | **`null`** |
| Variant | `undefined` |

Two consequences worth internalising:

- An omitted **Object** or **Collection** parameter is `Null`, so
  `$inOptions_o.key` on a missing parameter raises a runtime error. Object
  parameters always need a guard before first use.
- An omitted **Variant** parameter is `undefined`, which is the one case where
  `Undefined()` is informative — but only for Variant, and `Count parameters`
  remains clearer.

### 4.2 The canonical patterns

**Scalar with a default:**

```4d
#DECLARE($inText_t : Text; $inPrettyPrint_b : Boolean)->$result_t : Text

var $prettyPrint_b : Boolean

If (Count parameters<2)
	$prettyPrint_b:=False
Else 
	$prettyPrint_b:=$inPrettyPrint_b
End if 
```

**Object of options:**

```4d
#DECLARE($inName_t : Text; $inOptions_o : Object)->$result_o : Object

var $options_o : Object

If (Count parameters<2) | ($inOptions_o=Null)
	$options_o:=New object          // v19-safe
Else 
	$options_o:=$inOptions_o
End if 
```

The `| ($inOptions_o=Null)` arm is belt-and-braces: it also covers a caller
that passed `Null` explicitly. Note that `|` is 4D's *bitwise* OR; in
conditions prefer `||`. Check the project's own convention — some codebases
standardise on `||`/`&&` throughout, in which case write
`If ((Count parameters<2) || ($inOptions_o=Null))`.

**Reading option properties without further guards.** Once `$options_o` is a
real object, the wrapper functions absorb missing properties:

```4d
$depth_i:=Num($options_o.depth)          // Null → 0
$label_t:=String($options_o.label)       // Null → ""
```

This is the technique the 4D documentation itself recommends under *Using
object properties as named parameters*.

### 4.3 Structural constraints to remember

- **Optional parameters are positional, from the right.** You cannot skip a
  middle one; a caller wanting the third must supply a placeholder for the
  second (`APPEND TEXT(vtSomeText;"";$wpArea)` in 4D's own example). If a
  method has more than about two optional parameters, switch to a single
  options object.
- **`Count parameters` is only meaningful in a method called by another
  method.** The command page states that a project method attached to a menu
  gets `0`. Code reachable both ways needs care.
- **Extra parameters beyond those declared are allowed**, arrive as `Variant`,
  and are reached via `${N}` indirection with `Count parameters` as the loop
  bound.

---

## 5. What differs on 4D v19

This is the section that most often trips up code written against v20+
documentation and then back-ported.

### 5.1 The documented guarantee for missing parameters is weaker

- **v18** — the *Optional parameters* section says only: *"4D project methods
  also accept such optional parameters, starting from the right. The issue with
  optional parameters is how to handle the case where some of them are missing
  in the called method — it should never produce an error. A good practice is
  to assign default values to unused parameters."* There is no *Initialization*
  section at all.
- **v19** — adds the *Initialization* section (declared parameters are
  initialised to their type default), but the *Optional parameters* section
  still carries only the v18 "good practice" wording.
- **v20 and later** — the *Optional parameters* section gains an explicit
  guarantee: *"If you call a method or function with less parameters than
  declared, missing parameters are processed as default values in the called
  code, according to their type"*, with a worked example.

Practical reading: on v20+ you may lean on defaults as specified behaviour. On
v19 the two statements have to be assembled by the reader, and v18's advice was
to default them yourself. Treat `Count parameters` as mandatory on v19 rather
than optional polish — and note that v18's "assign default values to unused
parameters" is precisely the habit this document argues against. Do the
defaulting; do it in a working local.

### 5.2 No `return` statement

The `return` statement was added in **19 R4** (per the version-history table on
the `return {expression}` section of `Concepts/parameters`). On 19.x LTS it does
not exist. Consequences:

- You cannot early-exit after detecting a missing or invalid parameter.
- Control flow must be structured with `If` / `Case of` and a single final
  assignment to the declared return variable.
- This is exactly the pressure that tempts people to default into the parameter
  and "fall through". Resist it: the `If`/`Else` copy into a working local is
  four lines and works on every version.

### 5.3 No object or collection literals

`{}` and `[]` literal syntax arrived in **v20** (the v19 `Concepts/collection`
page documents only `New collection`; the v20 page introduces *collection
literal* and *object literals*). So v19-compatible defaulting must be written:

```4d
$options_o:=New object        // NOT {}
$items_c:=New collection      // NOT []
```

Any v20-era snippet of the form `$options_o:={}` needs translating before it
goes into a v19 target.

### 5.4 No typed array declarations with `var`

The v19 `Concepts/variables` page states that arrays are declared with the
dedicated commands (`ARRAY LONGINT(alAnArray;10)`). Use classic initialisation:

```4d
ARRAY LONGINT($items_ai;0)     // NOT: var $items_ai : Array Integer
```

Arrays also cannot be passed as parameters by value at all — the documentation
notes that *"tables or array expressions can only be passed as reference using
a pointer"*. A pointer parameter is a reference by definition, so the
no-reassignment rule extends to it in a stronger form: never write
`$inArrayPtr_p:=…` (which retargets the local pointer), and be deliberate about
`$inArrayPtr_p->:=…` (which writes through to the caller's array).

### 5.5 Variadic declaration syntax

The `...` variadic notation in prototypes is a later addition (documented in
21-R3, which also refers to the `${N}`-style declaration as *"the legacy
syntax"*). On v19, declare generic parameters the legacy way and iterate with
`For($i;1;Count parameters)` plus `${$i}`.

### 5.6 `Compiler_` methods

On v19 and v20 LTS, keep `Compiler_xxx` declarations for methods that use
sequential `$1`/`$2` parameters. Methods declared with `#DECLARE` are
self-declaring, but do not delete existing `Compiler_` entries as part of a
modernisation pass unless every call path has been converted.

---

## 6. Anti-patterns, with the fix

```4d
// ANTI-PATTERN 1 — defaulting into the parameter
If (Count parameters<2)
	$inStart_i:=1
End if 
// FIX: copy into $startAt_i via If/Else, leave $inStart_i alone.


// ANTI-PATTERN 2 — value-based presence test
If ($inStart_i=0)
	$inStart_i:=1
End if 
// FIX: If (Count parameters<2) — a caller passing 0 is not a caller
//      passing nothing.


// ANTI-PATTERN 3 — Undefined() on a scalar parameter
If (Undefined($inStart_i))
	…
End if 
// FIX: never; always False in compiled mode. Use Count parameters.


// ANTI-PATTERN 4 — reusing a parameter as a loop/scratch variable
$inText_t:=Replace string($inText_t;"a";"b")
$inText_t:=Replace string($inText_t;"c";"d")
// FIX: var $work_t : Text ; $work_t:=$inText_t ; then transform $work_t.


// ANTI-PATTERN 5 — instantiating an omitted object parameter in place
If (Count parameters<2)
	$inOptions_o:=New object
End if 
$inOptions_o.flag:=True
// FIX: see §3.2 — copy to $options_o so the mutation contract is explicit.
```

---

## 7. Checklist

- [ ] No assignment to any `$inXxx_*`, `$1`, `$2` … anywhere in the method body.
- [ ] Every optional parameter has an `If (Count parameters<N) … Else … End if`
      block that populates a working local.
- [ ] The body references only the working locals, never the raw parameters,
      after that block.
- [ ] Object/Collection parameters are guarded for `Null` before first property
      access.
- [ ] No `Undefined()` test on a scalar parameter.
- [ ] Mutation of a caller-supplied object is either intended and commented, or
      avoided with `OB Copy`.
- [ ] **Targeting v19:** no `return`, no `{}` / `[]` literals, no
      `var … : Array …`, `New object` / `New collection` used for defaults.

---

## 8. Sources

Offline 4D documentation set (`static-doc-en`), pages consulted per version:

- `Concepts/parameters` — v18, v19, v20, v21-R3 (*Passing parameters*,
  *Initialization*, *Optional parameters*, *Values or references*, *Particular
  cases: objects and collections*, *Returned value*, `return {expression}`
  history table)
- `Concepts/data-types` — v19 (*Default values*)
- `Concepts/interpreted` — v19 (*Differences between interpreted and compiled
  code*)
- `Concepts/dt_collection` — v19 and v20 (literal syntax)
- `Concepts/variables` — v19 (array declaration)
- `commands/count-parameters` — v21-R3
