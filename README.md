# OTr — Native ObjectTools Replacement

A native 4D implementation of the ObjectTools 5.0 plugin API, eliminating the dependency on a third-party binary plugin whilst maintaining backward compatibility with existing code.

## The Problem

For decades, ObjectTools has been a critical component in many 4D applications—providing a handle-based object registry and a comprehensive API for manipulating complex data structures. However, ObjectTools has become unsustainable:

- **End of life:** The original developer has retired after 43 years of software development and 25 years of supporting ObjectTools. Active4D (the companion plugin) and ObjectTools are no longer commercially viable.
- **No longer maintained:** Without ongoing support, the closed-source plugin cannot be updated for future 4D versions, creating a long-term maintenance burden for applications that depend on it.
- **Compatibility issues:** Recent 4D updates (e.g., Tahoe 26.4) have introduced compatibility problems with the ObjectTools plugin, causing applications to crash on login.
- **Migration pressure:** Developers using ObjectTools must either port their applications away from the plugin or risk being locked to legacy 4D versions.

## The Solution

**OTr** replaces ObjectTools with a pure-4D implementation using native Object types. This approach:

- **Eliminates external dependencies** — No third-party binary plugin required; OTr is 100% native 4D project methods
- **Maintains API compatibility** — Existing code can migrate from `OT` to `OTr` with minimal refactoring (essentially a find-and-replace of command names)
- **Ensures long-term maintainability** — As a native 4D solution, OTr will continue to work with future 4D releases
- **Provides a clear migration path** — Detailed specifications and comprehensive test coverage ensure reliable porting of ObjectTools-dependent code

## Ch-ch-ch-ch-changes
Some Object Tools plugin commands can't be matched exactly to a native 4D component. To see a list of API differences, look at this document.

**[OTr-API-Differences.md](OTr-API-Differences.md)**

## Key Features

- **Handle-based object registry** — Preserves the familiar handle-based API from the original plugin
- **Full type support** — Scalar types (Long, Real, Text, Date, Time, Boolean), complex types (BLOB, Picture, Pointer, Record, Variable), nested objects, and arrays
- **Dotted-path navigation** — Access nested properties via paths like `"user.profile.email"`
- **Object introspection** — Query object structure, enumerate properties, compare items
- **Array operations** — Bulk storage and typed element access for collections
- **Import/export** — Binary BLOB serialisation with type metadata for round-trip fidelity
- **Comprehensive testing** — Unit tests for every phase covering edge cases and full API surface

## Quick Start

### Installation

1. Clone or download this repository
2. Open the 4D database project in 4D v19 LTS or later
3. All OTr methods are in the `Project/Sources/Methods/` folder, prefixed with `OTr_`

### Basic Usage

```4d
// Create a new object
$handle := OTr_New

// Store values (scalars)
OTr_PutText($handle; "name"; "Alice")
OTr_PutLong($handle; "age"; 30)
OTr_PutBoolean($handle; "active"; True)

// Retrieve values
$name := OTr_GetText($handle; "name")        // "Alice"
$age := OTr_GetLong($handle; "age")          // 30
$active := OTr_GetBoolean($handle; "active") // 1

// Dotted paths (automatic intermediate object creation)
OTr_PutText($handle; "contact.email"; "alice@example.com")
OTr_PutText($handle; "contact.phone"; "+1-555-0123")

// Export to JSON (for debugging, testing, data transfer)
$json := OTr_SaveToText($handle; True)  // Pretty-printed JSON
OTr_SaveToFile($handle; "/path/to/export.json")

// Clean up
OTr_Clear($handle)
```

### Migrate from ObjectTools

If your code uses the legacy ObjectTools plugin, migration is straightforward:

1. **Find and replace** — Replace `OT ` with `OTr_` in all method calls
   - `OT New` → `OTr_New`
   - `OT PutText` → `OTr_PutText`
   - `OT GetText` → `OTr_GetText`

2. **Remove legacy calls** — Delete any `OT Register` calls (OTr has a no-op replacement for compatibility)

3. **Review special types** — If your code uses Pointer, Record, or Variable types, refer to Phase 5 specification for serialisation details

4. **Test thoroughly** — Run your application's test suite to verify behaviour matches the original

## Project Structure

```
OTr/
├── README.md                              (this file)
├── OTr-Specification.md                   (master specification; start here)
├── OTr-Types-Reference.md                 (type constant mapping)
├── 4D-Method-Writing-Guide.md             (coding standard for OTr methods)
├── Documentation/
│   └── Specifications/
│       ├── OTr-Phase-001-Spec.md          (core infrastructure + simple export)
│       ├── OTr-Phase-002-Spec.md          (scalar put/get and object navigation)
│       ├── OTr-Phase-003-Spec.md          (object inspection and item utilities)
│       ├── OTr-Phase-004-Spec.md          (array operations)
│       ├── OTr-Phase-005-Spec.md          (complex types: BLOB, Picture, Pointer, Record, Variable)
│       ├── OTr-Phase-006-Spec.md          (full import/export with type preservation)
│       ├── OTr-Phase-007-020-Spec.md      (future extensions)
│       └── Retired/                       (historical specification versions)
├── Project/
│   └── Sources/Methods/
│       ├── OTr_New.4dm                    (public API methods)
│       ├── OTr_PutText.4dm
│       ├── OTr_GetText.4dm
│       ├── ... (all OTr_ methods)
│       ├── OTr_z*.4dm                     (private infrastructure methods)
│       ├── OTr_u*.4dm                     (utility methods)
│       └── ____Test_Phase_*.4dm           (comprehensive unit tests)
└── LegacyDocumentation/
    └── ObjectTools 5 Reference.pdf        (original ObjectTools documentation)
```

## Specifications

OTr is organised into implementation phases, each with detailed specifications:

- **Phase 1–1.5:** Core infrastructure and handle management; simple JSON export
- **Phase 2:** Scalar put/get and dotted-path object navigation
- **Phase 3:** Object inspection, property enumeration, item utilities
- **Phase 4:** Array storage and manipulation
- **Phase 5:** Complex types (BLOB, Picture, Pointer, Record, Variable)
- **Phase 6:** Full import/export with type metadata preservation
- **Phase 7+:** Future extensions and optimisations

See **[OTr-Specification.md](OTr-Specification.md)** for the master overview and command reference, or jump directly to a phase specification for detailed method signatures, behaviour, and examples.

## Testing

Comprehensive unit tests are provided for all implemented phases:

```4d
____Test_Phase_1         // Core infrastructure, handle lifecycle, options
____Test_Phase_2         // Scalar put/get, dotted paths, object embedding
____Test_Phase_3         // Object inspection, property enumeration
____Test_Phase_4         // Array operations
____Test_Phase_5         // Complex types
____Test_Phase_6         // Import/export round-trip
```

Run any test method to verify the implementation:

```4d
____Test_Phase_1  // Displays "all tests passed" or "FAILED" with details
```

## Coding Standard

All OTr methods follow the standard defined in **[4D-Method-Writing-Guide.md](4D-Method-Writing-Guide.md)**:

- `#DECLARE` with named parameters (no numbered parameters)
- Type suffixes on variable names (`_i` for Integer, `_t` for Text, etc.)
- Marked `"invisible":true` in method attributes (hidden from method explorer by default)
- Public API methods marked `"shared":true`; internal methods marked `"shared":false`
- Boxed method headers with clear documentation

## Requirements

- **4D v19 LTS** or later (4D v20 or later recommended)
- Native 4D Object type support (included in v19+)
- Project mode database (source files accessible)

## Acknowledgements and Inspiration

OTr builds on substantial prior work in the 4D community:

**Code and Architecture:**
- **Cannon Smith's Object Module** (https://www.synergyfarmsolutions.com/styled/index.html) — Many OTr methods are direct refactorings of Cannon's original code; the Constants module was adapted to create OTr constants
- **Rob Laveaux's Fnd_Dict Component** — Provided the foundational handle-based registry pattern that underpins OTr's storage model
- **Dave Batton's Foundation Component** (now maintained by Walt Nelson) — Established the coding style and component design principles that shaped OTr's architecture

**Historical Foundation:**
- **Steve Willis' Reusable Variable Space (Rvar) Module** — Early work on object encapsulation and variable spaces, presented in the 2007 4D Summit OTX session
- **2007 4D Summit OTX Session** — An early version of this component (simpler at the time) was based on Rvar, establishing the conceptual groundwork for handle-based object storage
- **2013 4D Summit Listbox Session** — Further refinement of object handling patterns, this time based on the Fnd_Dict concept.

OTr represents the evolution of these design patterns into a modern, native 4D implementation.

## Status

OTr v1.0 Beta 1 is feature-complete and in final pre-release verification:

**Completed:**
- **Phases 1–9** — Fully implemented and tested
- **Phase 10** — Logging and diagnostic support — implemented
- **Phase 15** — Parallel OT vs OTr side-by-side testing — 30/30 pass

A public release is imminent. The implementation reproduces the ObjectTools API with high fidelity, enabling reliable migration from the legacy plugin.

## Support & Contribution

For issues, questions, or contributions:

1. Refer to the relevant **phase specification** for detailed method documentation
2. Review the **unit tests** (`____Test_Phase_*.4dm`) for usage examples
3. Check the **[OTr-Types-Reference.md](OTr-Types-Reference.md)** for type constant mapping
4. Contact the maintainers for support or collaboration

## License

OTr is provided free to the 4D developer community. See the repository for licensing details.

---

**Start here:** Read [OTr-Specification.md](OTr-Specification.md) for a comprehensive overview of the architecture, constraints, and command reference. Then dive into the phase specifications for detailed method documentation.
