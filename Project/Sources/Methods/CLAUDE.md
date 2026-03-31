# Claude Code Instructions for 4D Methods

## Method Types

4D has several kinds of methods:
- **Project methods** - standalone procedures/functions callable from anywhere
- **Test methods** - project methods prefixed with `Test_` that validate code
- **Form methods** - bound to a specific form (event handler)
- **Object methods** - bound to a specific form object (button, input, etc.)

This directory contains **project methods** and **test methods**.

## Method File Format

```4d
// ----------------------------------------------------
// Project Method: MethodName ($param1_t : Text {; $param2_i : Integer}) --> $result_o : Object

// Brief description of what this method does

// Parameters:
//   $param1_t  : Text    : Description of parameter
//   $param2_i  : Integer : Description of parameter (optional)

// Returns:
//   $result_o : Object : Description of return value

// Created by Author, YYYY-MM-DD
// ----------------------------------------------------

#DECLARE($param1_t : Text; $param2_i : Integer)->$result_o : Object

var $local_t : Text
var $count_i : Integer

// implementation...
```

The `// ----` boxed header is the standard format. All project methods **must** use `#DECLARE` for parameters.

## Modifications
- Modification notes are placed under the Created by line in the method header and above the trailing `// ----` boxed header demarcation line
- An extra-long comment should be split over multiple lines and indented slightly
- Example shown below:

```4d
// Created by Wayne Stewart, 2019-10-05
// Wayne Stewart, 2021-08-11 - Tooltip will now show the parameters
// Wayne Stewart, 2026-03-29 - Swapped method to #DECLARE and added optional silent flag.
// Wayne Stewart, 2026-03-30 - Improved markdown output formatting 
//       (paragraph spacing, parameter/return tables, and no-parameter display).
// ----------------------------------------------------

```



## Method Naming Conventions

### Module Pattern

Methods belonging to a logical module use a short uppercase prefix followed by an underscore:

```
[MODULE]_[camelCase subject]_[action or verb]
```

Examples:
- `MATH_divide` - Math module: division utility
- `ORD_newOrder` - Order module: create new order
- `SHIP_newShipment` - Shipping module: create shipment
- `TRXN_status_update` - Transaction module: update status

### General Pattern

```
[PascalCase subject]_[action or verb]
```

Examples:
- `InventoryExceptions_report` - generate exceptions report
- `InventoryExceptionsReport_print` - print the report
- `InventoryExceptions_delete` - delete exceptions
- `InventoryExceptionsForm_show` - display the form

### Test Method Pattern

```
Test_[ClassName or Subject]
```

Examples:
- `Test_Coords` - tests for Coords class
- `Test_FormBuilder` - tests for FormBuilder class
- `Test_widget_base` - tests for _widget_base class
- `Test_widgets` - tests for multiple widget subclasses

## Test Method Format

Test methods are the standard way to verify code correctness in 4D. They use `ASSERT()` and follow a consistent structure:

```4d
// ----------------------------------------------------
// Project Method: Test_ClassName ()

// Unit tests for ClassName

// Created by Author (YYYY-MM-DD)
//     author@example.com
// ----------------------------------------------------

#DECLARE()

var $obj_o : cs.ClassName

//MARK:- test constructor
$obj_o := cs.ClassName.new("test"; 42)
ASSERT($obj_o.name = "test"; "name should be 'test' but is " + $obj_o.name)
ASSERT($obj_o.count = 42; "count should be 42 but is " + String($obj_o.count))

//MARK:- test computed getters
$obj_o := cs.ClassName.new(10; 20; 100; 50)
ASSERT($obj_o.left = 10; "left should be 10 but is " + String($obj_o.left))
ASSERT($obj_o.right = 110; "right should be 110 but is " + String($obj_o.right))

//MARK:- test setters
$obj_o := cs.ClassName.new(0; 0; 100; 100)
$obj_o.width := -50
ASSERT($obj_o.width = 50; "width should be absolute value 50 but is " + String($obj_o.width))

//MARK:- test validation
$obj_o := cs.ClassName.new(""; 0; 0; 0; 0)
var $issues_c : Collection := $obj_o.validate()
ASSERT($issues_c.length >= 1; "validation should have issues for empty name")

var $hasNameError_b : Boolean := False
var $issue_o : Object
For each ($issue_o; $issues_c)
	If ($issue_o.message = "Name cannot be empty")
		$hasNameError_b := True

	End if

End for each
ASSERT($hasNameError_b; "validation should report empty name error")

//MARK:- test serialisation round-trip
$obj_o := cs.ClassName.new("test"; 10; 20; 100; 50)
$obj_o.type := "button"
$obj_o.addEvent("onClick")
var $serialised_o : Object := $obj_o.toObject()
ASSERT($serialised_o.type = "button"; "toObject type should be 'button'")
ASSERT($serialised_o.left = 10; "toObject left should be 10")

// test fromObject
var $obj2_o : cs.ClassName := cs.ClassName.new("test2"; 0; 0; 0; 0)
$obj2_o.fromObject($serialised_o)
ASSERT($obj2_o.left = 10; "fromObject left should be 10")

//MARK:- test clone
$obj_o := cs.ClassName.new("original"; 10; 20; 100; 50)
var $clone_o : cs.ClassName := $obj_o.clone()
ASSERT($clone_o.name = "original"; "clone name should match")
$clone_o.x := 999
ASSERT($obj_o.x = 10; "original should be unchanged after modifying clone")

//MARK:- test edge cases
// empty collections
$obj_o.alignLeft([])  // should return without error

// boundary values
$obj_o := cs.ClassName.new(0; 0; 0; 0)
ASSERT($obj_o.width = 0; "zero width should be allowed")

//MARK:- done
ALERT(Current method name + " - all tests done.")
```

### Test Method Principles

1. **Structure**: Use `//MARK:-` sections to organise tests by feature area
2. **Fresh state**: Create a new instance for each test section to avoid state leakage
3. **ASSERT messages**: Always include both the expected AND actual value:
   ```4d
   // GOOD - shows what went wrong
   ASSERT($obj_o.x = 10; "$obj_o.x should be 10 but is " + String($obj_o.x))

   // BAD - no diagnostic info
   ASSERT($obj_o.x = 10; "x is wrong")
   ```
4. **Coverage**: Test in this order:
   - Constructor and defaults
   - Getters and computed properties
   - Setters (including validation/rejection of invalid values)
   - Public methods
   - Validation
   - Serialisation (toObject/toJson)
   - Deserialisation (fromObject/newFromJson)
   - Clone/copy (verify deep independence)
   - Edge cases (empty collections, null inputs, boundary values)
5. **Completion**: Every test method ends with:
   ```4d
   //MARK:- done
   ALERT(Current method name + " - all tests done.")
   ```

### Testing Multiple Related Classes

When testing subclasses or related classes, group them in a single test method with major section separators:

```4d
//MARK:- _widget_button tests
// ... button tests ...

//MARK:- _widget_input tests
// ... input tests ...

//MARK:- _widget_text tests
// ... text tests ...

//MARK:- done
ALERT(Current method name + " - all tests done.")
```

## Parameters and Return Values

All project methods use `#DECLARE` for parameters:

```4d
// Method with parameters and return value
#DECLARE($input_t : Text; $count_i : Integer)->$result_c : Collection

// implementation...
```

### In class methods, use typed parameters:

```4d
Function calculate($price_r : Real; $quantity_i : Integer) -> $total_r : Real
	$total_r := $price_r * $quantity_i
	return $total_r
```

### Optional parameters:

```4d
// Use curly braces in the header to denote optional parameters
// ----------------------------------------------------
// Project Method: MyMethod ($name_t : Text {; $options_o : Object}) --> $result_o : Object
// ...

#DECLARE($name_t : Text; $options_o : Object)->$result_o : Object

If (Count parameters < 2) | ($options_o = Null)
	$options_o := {}  // use defaults

End if
```

## Migration Strategy

When touching existing classic methods, assess priority for ORDA migration:

### High Priority - Migrate Now
- Contains magic numbers (hardcoded values)
- Used by new ORDA code
- Frequently called
- Thread-unsafe (uses global state)

### Medium Priority - Refactor Over Time
- Long methods (>200 lines)
- Complex business logic
- Validated but inflexible

### Low Priority - Leave Alone
- Simple utilities that work
- Rarely called
- Stable and tested

### Migration Pattern
```4d
// BEFORE (Classic)
QUERY([customer]; [customer]status = "Active")
SELECTION TO ARRAY([customer]name; aNames)

// AFTER (ORDA)
var $names_c : Collection
$names_c := ds.customer.query("status = :1"; "Active").toCollection().extract("name")
```
