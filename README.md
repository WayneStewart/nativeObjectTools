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

### API Changes
Some Object Tools plugin commands can't be matched exactly to a native 4D component. To see a list of API differences, look at this document.

**[OTr-API-Differences.md](OTr-API-Differences.md)**

### I Really Hate OTr_
If you don't like seeing OTr_ everywhere, check out the folder renaming. This contains a 4D project that will rename all the **'OTr_'**, prefixes to **'OT '**. If you run this and then quit and restart nativeObjectTools you should see all is correct.  


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

## Building the Component

OTr can be built as a 4D component either manually or via an automated build method.

**Manual build:** Use the 4D Design menu option **Build Application…** at any time. Note that the method documentation will not be automatically updated when building this way.

**Automated build:** Run the method `__BuildComponent`. This updates the method documentation and includes it in the component before building. The process is:

1. Run `__BuildComponent`.
2. If all settings are in place, the component is built and revealed on disk.
3. If no settings document exists yet, a template is written to the correct location — proceed to step 4.
4. Edit the settings document either via **Design > Build Application…** or by editing the XML directly.
5. On macOS with 4D 20 or later, add your Apple Developer ID to the settings so the component is correctly signed.
6. Save the settings and return to step 1.

## Project Structure

```
OTr/
├── README.md                              (this file)
├── 4D-Method-Writing-Guide.md             (coding standard for OTr methods)
├── OTr-Specification.md                   (master specification; start here)
├── OTr-Types-Reference.md                 (type constant mapping)
├── Documentation/                         (phase specifications & explorer method documentation)
├── Examples/                              (An example host database for running tests)
├── LegacyDocumentation/                   (original ObjectTools documentation in various formats)
├── Project/                               (4D source methods)
├── Renaming/                              (a 4D project to rename methods from Otr to 'OT ' and vice versa)
```

See **[OTr-Specification.md](OTr-Specification.md)** for the master overview and command reference.

## Testing

Comprehensive unit tests are provided for all implemented phases. Test methods are named `____Test_Phase_*` and can be run directly from the 4D Method Editor.

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
