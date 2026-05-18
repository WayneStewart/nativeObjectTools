// build-otr-docs.mjs — run from Resources/about/
// Generates the OTr component reference site from Documentation/Methods/*.md

import fs from "node:fs";
import path from "node:path";

const root = path.resolve("../..");
const outDir = path.resolve(".");
const commandsDir = path.join(outDir, "commands");
const assetsDir = path.join(outDir, "assets");
const docsDir = path.join(root, "Documentation", "Methods");

// ── Method groups ─────────────────────────────────────────────────────────────

const methodGroups = [
  {
    id: "handle",
    title: "Handle management",
    summary: "Create, copy, and release OTr object handles.",
    methods: [
      "OTr_New", "OTr_Clear", "OTr_ClearAll", "OTr_Copy",
      "OTr_IsObject", "OTr_GetActiveHandleCount", "OTr_GetHandleList",
      "OTr_Register", "OTr_CompiledApplication",
    ],
  },
  {
    id: "get-scalar",
    title: "Get scalars",
    summary: "Retrieve a single typed value from an object by tag path.",
    methods: [
      "OTr_GetText", "OTr_GetString", "OTr_GetLong", "OTr_GetReal",
      "OTr_GetBoolean", "OTr_GetDate", "OTr_GetTime",
      "OTr_GetBLOB", "OTr_GetNewBLOB", "OTr_GetPicture",
      "OTr_GetPointer", "OTr_GetVariable",
      "OTr_GetObject", "OTr_GetRecord", "OTr_GetRecordTable",
    ],
  },
  {
    id: "put-scalar",
    title: "Put scalars",
    summary: "Store a single typed value in an object at a tag path.",
    methods: [
      "OTr_PutText", "OTr_PutString", "OTr_PutLong", "OTr_PutReal",
      "OTr_PutBoolean", "OTr_PutDate", "OTr_PutTime",
      "OTr_PutBLOB", "OTr_PutPicture", "OTr_PutPointer",
      "OTr_PutVariable", "OTr_PutObject", "OTr_PutRecord",
    ],
  },
  {
    id: "get-array",
    title: "Get arrays",
    summary: "Copy an OTr-stored array into a 4D process array.",
    methods: [
      "OTr_GetArray",
      "OTr_GetArrayText", "OTr_GetArrayString", "OTr_GetArrayLong",
      "OTr_GetArrayReal", "OTr_GetArrayBoolean", "OTr_GetArrayDate",
      "OTr_GetArrayTime", "OTr_GetArrayBLOB", "OTr_GetArrayPicture",
      "OTr_GetArrayPointer",
    ],
  },
  {
    id: "put-array",
    title: "Put arrays",
    summary: "Store a 4D process array into an OTr object.",
    methods: [
      "OTr_PutArray",
      "OTr_PutArrayText", "OTr_PutArrayString", "OTr_PutArrayLong",
      "OTr_PutArrayReal", "OTr_PutArrayBoolean", "OTr_PutArrayDate",
      "OTr_PutArrayTime", "OTr_PutArrayBLOB", "OTr_PutArrayPicture",
      "OTr_PutArrayPointer",
    ],
  },
  {
    id: "items",
    title: "Item operations",
    summary: "Inspect, enumerate, copy, rename, and delete named items.",
    methods: [
      "OTr_ItemExists", "OTr_ItemType", "OTr_ItemCount",
      "OTr_IsEmbedded", "OTr_DeleteItem", "OTr_CopyItem", "OTr_RenameItem",
      "OTr_GetAllProperties", "OTr_GetAllNamedProperties",
      "OTr_GetNamedProperties", "OTr_GetItemProperties",
      "OTr_IncludeShadowKey",
    ],
  },
  {
    id: "array-ops",
    title: "Array operations",
    summary: "Sort, search, resize, and compare OTr arrays.",
    methods: [
      "OTr_FindInArray", "OTr_SortArrays", "OTr_ArrayType",
      "OTr_ResizeArray", "OTr_SizeOfArray",
      "OTr_InsertElement", "OTr_DeleteElement", "OTr_CompareItems",
    ],
  },
  {
    id: "serial",
    title: "Serialisation",
    summary: "Load and save objects as JSON text, BLOB, file, XML, GZIP, or clipboard.",
    methods: [
      "OTr_LoadFromText", "OTr_SaveToText",
      "OTr_LoadFromBlob", "OTr_SaveToBlob",
      "OTr_BLOBToObject", "OTr_ObjectToBLOB", "OTr_ObjectToNewBLOB",
      "OTr_LoadFromFile", "OTr_SaveToFile",
      "OTr_LoadFromGZIP", "OTr_SaveToGZIP",
      "OTr_LoadFromXML", "OTr_SaveToXML",
      "OTr_LoadFromXMLFile", "OTr_SaveToXMLFile",
      "OTr_SaveToXMLSAX", "OTr_SaveToXMLFileSAX",
      "OTr_LoadFromClipboard", "OTr_SaveToClipboard",
      "OTr_ImportLegacyBlob",
    ],
  },
  {
    id: "config",
    title: "Configuration & info",
    summary: "Query version, configure behaviour, and inspect object metadata.",
    methods: [
      "OTr_GetVersion", "OTr_Info", "OTr_ObjectSize",
      "OTr_GetOptions", "OTr_SetOptions",
      "OTr_SetDateMode", "OTr_SetErrorHandler", "OTr_LogLevel",
      "OTr_ObjectViewer", "OTr_LoadAndViewOTBlob",
    ],
  },
  {
    id: "lifecycle",
    title: "Lifecycle",
    summary: "Database startup and shutdown integration.",
    methods: ["OTr_onStartup", "OTr_onExit"],
  },
];

const publicMethods = methodGroups.flatMap((g) => g.methods);

// Methods that have no ObjectTools 5.0 equivalent
const noOtEquivalent = new Set([
  "OTr_LoadFromText", "OTr_LoadFromGZIP", "OTr_SaveToGZIP",
  "OTr_LoadFromXMLFile", "OTr_SaveToXMLFile",
  "OTr_SaveToXMLSAX", "OTr_SaveToXMLFileSAX",
  "OTr_ImportLegacyBlob", "OTr_GetActiveHandleCount", "OTr_GetHandleList",
  "OTr_IncludeShadowKey", "OTr_Register", "OTr_LoadAndViewOTBlob",
  "OTr_ObjectViewer", "OTr_CompiledApplication", "OTr_GetVersion",
  "OTr_onStartup", "OTr_onExit",
]);

// Methods where behaviour differs from ObjectTools (flagged in docs)
const changedBehaviour = new Set([
  "OTr_SaveToText", "OTr_LoadFromBlob", "OTr_SaveToBlob",
  "OTr_BLOBToObject", "OTr_ObjectToBLOB", "OTr_ObjectToNewBLOB",
]);

function otName(otrName) {
  if (noOtEquivalent.has(otrName)) return null;
  return "OT " + otrName.replace(/^OTr_/, "");
}

// ── Docs parser ───────────────────────────────────────────────────────────────

function readDoc(name) {
  const file = path.join(docsDir, `${name}.md`);
  if (!fs.existsSync(file)) return { name, title: name, signature: name, description: "", params: [], attributes: "", raw: "" };
  const raw = fs.readFileSync(file, "utf8").replace(/\r\n/g, "\n").replace(/\r/g, "\n");
  const withoutComment = raw.replace(/^<!--[\s\S]*?-->\s*/, "");
  const lines = withoutComment.split("\n");

  const titleLineIdx = lines.findIndex((l) => l.startsWith("## "));
  const title = titleLineIdx >= 0 ? lines[titleLineIdx].replace(/^##\s+/, "").trim() : name;

  // Signature: first non-empty line after title
  let sigIdx = titleLineIdx + 1;
  while (sigIdx < lines.length && lines[sigIdx].trim() === "") sigIdx++;
  let signature = lines[sigIdx]?.trim() ?? name;
  // Guard against bad extractions
  if (signature.length > 160 || signature.startsWith("|") || signature.startsWith("var ") || signature.startsWith("/*")) {
    signature = name;
  }

  // Find attributes line
  const attrIdx = lines.findIndex((l) => l.startsWith("Attributes:"));
  const attributes = attrIdx >= 0 ? lines[attrIdx].replace(/^Attributes:\s*/, "").trim() : "";

  // Find parameter table start
  const tableIdx = lines.findIndex((l) => l.startsWith("|") && /Parameter/.test(l));

  // Description lines: between signature and attributes/table
  const descEnd = attrIdx >= 0 ? attrIdx : (tableIdx >= 0 ? tableIdx : lines.length);
  const descLines = lines.slice(sigIdx + 1, descEnd).join("\n");

  // Parameter rows
  let params = [];
  if (tableIdx >= 0) {
    params = lines
      .slice(tableIdx + 2)
      .filter((l) => l.startsWith("|"))
      .map((l) => l.split("|").slice(1, -1).map((c) => c.trim().replace(/\\_/g, "_").replace(/\\\s+/g, " ").trim()))
      .filter((cells) => cells.length >= 2 && !cells.every((c) => /^-+$/.test(c)))
      .map((cells) => ({ name: cells[0], type: cells[1], dir: cells[2] ?? "", desc: cells[3] ?? cells[2] ?? "" }));
  }

  // Brief one-line description (first substantive paragraph, no bold headers)
  const brief = descLines
    .split(/\n{2,}/)
    .map((p) => p.trim().replace(/\n/g, " "))
    .find((p) => p && !p.startsWith("**") && !p.startsWith("#")) ?? "";

  return { name, title, signature: cleanText(signature), description: renderDescription(descLines), brief: cleanText(clipText(brief, 240)), params, attributes };
}

// ── Markdown-ish renderer for description bodies ──────────────────────────────

function renderDescription(raw) {
  if (!raw.trim()) return "";
  const paragraphs = raw.split(/\n{2,}/).map((p) => p.trim()).filter(Boolean);
  const out = [];
  let listItems = [];

  function flushList() {
    if (listItems.length) {
      out.push(`<ul>${listItems.map((li) => `<li>${inlineMarkdown(li)}</li>`).join("")}</ul>`);
      listItems = [];
    }
  }

  for (const para of paragraphs) {
    // Section headers: **ORIGINAL DOCUMENTATION**, **WARNING: ...**, **NOTE:**
    const boldHeader = para.match(/^\*\*([^*]+)\*\*\s*$/);
    if (boldHeader) {
      flushList();
      const heading = boldHeader[1].trim();
      const cls = heading.startsWith("WARNING") ? "notice warning"
        : heading.startsWith("NOTE") ? "notice note"
        : "notice original";
      out.push(`<p class="${cls}-heading">${escapeHtml(heading)}</p>`);
      continue;
    }

    // Combined bold-header + body on same line: **WARNING: Changed Behaviour**\ntext
    const inlineBold = para.match(/^\*\*([^*]+)\*\*\n([\s\S]+)$/);
    if (inlineBold) {
      flushList();
      const heading = inlineBold[1].trim();
      const body = inlineBold[2];
      const cls = heading.startsWith("WARNING") ? "warning"
        : heading.startsWith("NOTE") ? "note"
        : "original";
      out.push(`<div class="notice ${cls}"><strong>${escapeHtml(heading)}</strong><p>${inlineMarkdown(body.replace(/\n/g, " "))}</p></div>`);
      continue;
    }

    // List items
    if (para.startsWith("- ") || para.includes("\n- ")) {
      flushList();
      const items = para.split("\n").filter((l) => l.startsWith("- ")).map((l) => l.slice(2));
      const preList = para.split("\n").filter((l) => !l.startsWith("- ") && l.trim());
      if (preList.length) out.push(`<p>${inlineMarkdown(preList.join(" "))}</p>`);
      out.push(`<ul>${items.map((li) => `<li>${inlineMarkdown(li)}</li>`).join("")}</ul>`);
      continue;
    }

    flushList();
    out.push(`<p>${inlineMarkdown(para.replace(/\n/g, " "))}</p>`);
  }
  flushList();
  return out.join("\n");
}

function inlineMarkdown(text) {
  let s = escapeHtml(text);
  // Code spans
  s = s.replace(/`([^`]+)`/g, "<code>$1</code>");
  // Bold-italic (order matters: longer before shorter)
  s = s.replace(/\*\*\*([^*]+)\*\*\*/g, "<strong><em>$1</em></strong>");
  s = s.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
  s = s.replace(/\*([^*]+)\*/g, "<em>$1</em>");
  // Escape already handled — unescape _ that was escaped in markdown source
  s = s.replace(/\\_/g, "_");
  return s;
}

// ── Syntax highlighter ────────────────────────────────────────────────────────

const otrConstants = [
  "OTR IP Arrays", "OTR Storage", "OTR Get Element", "OTR Put Element",
  "OT Log Off", "OT Log Debug", "OT Log Info", "OT Log Notice", "OT Log Warn", "OT Log Error",
  "OT Is Character", "OT Character array", "OT Is Object", "OT Is Record",
  "True", "False", "Null",
];
const otrKeywords = [
  "var", "If", "Else", "End if", "Case of", "End case",
  "For each", "End for each", "For", "End for",
  "While", "End while", "Use", "End use",
  "Return", "#DECLARE",
];

function codeBlock(code, opts = {}) {
  const highlighted = code.split("\n").map((line) => highlightLine(line, opts)).join("\n");
  return `<pre class="code"><code>${highlighted}</code></pre>`;
}

function highlightLine(line, opts = {}) {
  const ci = findCommentIndex(line);
  const codePart = ci >= 0 ? line.slice(0, ci) : line;
  const comment = ci >= 0 ? line.slice(ci) : "";
  const code = codePart.split(/("[^"]*")/g).map((part) => {
    if (part.startsWith('"') && part.endsWith('"')) return `<span class="tok-string">${escapeHtml(part)}</span>`;
    return highlightSegment(part, opts);
  }).join("");
  return code + (comment ? `<span class="tok-comment">${escapeHtml(comment)}</span>` : "");
}

function findCommentIndex(line) {
  let inStr = false;
  for (let i = 0; i < line.length - 1; i++) {
    if (line[i] === '"') inStr = !inStr;
    if (!inStr && line[i] === "/" && line[i + 1] === "/") return i;
  }
  return -1;
}

function highlightSegment(seg, opts = {}) {
  let s = escapeHtml(seg);
  s = replaceOutside(s, /\b(\d+)\b/g, '<span class="tok-number">$1</span>');
  s = replaceOutside(s, /\$[A-Za-z0-9_{}]+/g, '<span class="tok-local">$&</span>');
  s = replaceOutside(s, /\.([A-Za-z][A-Za-z0-9_]*)/g, '.<span class="tok-attr">$1</span>');
  for (const kw of otrKeywords.slice().sort((a, b) => b.length - a.length)) {
    s = replaceOutside(s, new RegExp(`\\b${reEscape(kw)}\\b`, "g"), `<span class="tok-kw">${escapeHtml(kw)}</span>`);
  }
  for (const c of otrConstants.slice().sort((a, b) => b.length - a.length)) {
    s = replaceOutside(s, new RegExp(`\\b${reEscape(c)}\\b`, "g"), `<span class="tok-const">${escapeHtml(c)}</span>`);
  }
  for (const m of publicMethods.slice().sort((a, b) => b.length - a.length)) {
    const label = escapeHtml(m);
    const isCurrent = opts.current === m;
    const linked = !isCurrent && opts.commandHrefPrefix !== undefined;
    const inner = linked
      ? `<a class="tok-cmd code-cmd-link" href="${opts.commandHrefPrefix ?? ""}${slug(m)}.html">${label}</a>`
      : `<span class="tok-cmd">${label}</span>`;
    s = replaceOutside(s, new RegExp(`\\b${reEscape(m)}\\b`, "g"), inner);
  }
  return s;
}

function replaceOutside(html, pat, rep) {
  return html.split(/(<[^>]+>)/g).map((p) => p.startsWith("<") ? p : p.replace(pat, rep)).join("");
}

// ── Layout ────────────────────────────────────────────────────────────────────

function layout({ title, crumb, body, depth = "root", isHome = false }) {
  const pre = depth === "sub" ? "../" : "";
  const bc = buildBreadcrumb(crumb, pre, isHome);
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(title)} — OTr Reference</title>
  <link rel="stylesheet" href="${pre}assets/styles.css">
</head>
<body>
  <header class="site-header">
    <nav class="breadcrumb" aria-label="Breadcrumb">${bc}</nav>
    <div class="masthead">
      <a class="brand" href="${pre}index.html">Native Object Tools</a>
      <div class="top-links">
        <a href="${pre}index.html">Overview</a>
        <a href="${pre}commands.html">Commands</a>
        <a href="${pre}alpha.html">A–Z</a>
        <a href="${pre}naming.html">OT&thinsp;→&thinsp;OTr</a>
        <a href="${pre}why.html">Why OTr?</a>
      </div>
    </div>
  </header>
  <main class="page-shell">
${body}
  </main>
</body>
</html>
`;
}

function buildBreadcrumb(crumb, pre, isHome) {
  if (isHome) return `<span aria-current="page">Home</span>`;
  const home = `<a href="${pre}index.html">Home</a>`;
  return home + crumb.map((item, idx) => {
    const last = idx === crumb.length - 1;
    const href = last ? "" : bcHref(item, pre);
    const text = escapeHtml(typeof item === "string" ? item : item.label);
    const content = href ? `<a href="${href}">${text}</a>` : `<span aria-current="page">${text}</span>`;
    return `<span class="sep">/</span>${content}`;
  }).join("");
}

function bcHref(item, pre) {
  switch (item) {
    case "Commands": return `${pre}commands.html`;
    case "A–Z": return `${pre}alpha.html`;
    case "OT → OTr": return `${pre}naming.html`;
    case "Why OTr?": return `${pre}why.html`;
    default: return "";
  }
}

// ── Pages ─────────────────────────────────────────────────────────────────────

function indexPage(docs) {
  const quickStart = `// Create a new object and store some values
var $h_i : Integer
$h_i := OTr_New

OTr_PutLong($h_i; "customerID"; 1042)
OTr_PutText($h_i; "name"; "Acme Corp")
OTr_PutBoolean($h_i; "active"; True)

// Read values back by tag path
var $name_t : Text
$name_t := OTr_GetText($h_i; "name")  // → "Acme Corp"

// Nested paths work with dot notation
OTr_PutLong($h_i; "address.postcode"; 2000)

// Serialise to JSON
var $json_t : Text
$json_t := OTr_SaveToText($h_i; True)

// Release when done
OTr_Clear($h_i)`;

  const namingExample = `// ObjectTools 5.0 plugin
OT PutLong ($handle; "id"; 1042)
$name := OT GetText ($handle; "name")

// OTr component — same semantics, new name
OTr_PutLong($handle_i; "id"; 1042)
$name_t := OTr_GetText($handle_i; "name")`;

  const groupCards = methodGroups.map((g) => {
    const count = g.methods.filter((m) => docs[m]).length;
    return `<div class="group-card">
        <h3><a href="commands.html#${g.id}">${escapeHtml(g.title)}</a></h3>
        <p>${escapeHtml(g.summary)}</p>
        <p class="group-count">${count} method${count !== 1 ? "s" : ""}</p>
      </div>`;
  }).join("\n      ");

  const body = `    <section class="hero">
      <p class="eyebrow">Component reference</p>
      <h1>Native Object Tools</h1>
      <p class="hero-tagline">A native 4D replacement for the ObjectTools&nbsp;5.0 plugin</p>
      <div class="hero-actions">
        <a class="button" href="commands.html">Browse commands</a>
        <a class="button secondary" href="naming.html">OT&thinsp;→&thinsp;OTr naming</a>
      </div>
    </section>

    <section class="two-col">
      <div>
        <h2>What is OTr?</h2>
        <p>OTr stores typed 4D values—scalars, arrays, nested objects, pictures, BLOBs, records—in native 4D Objects indexed by dotted string tag paths. Objects are referenced by integer handles, exactly as in the original ObjectTools plugin.</p>
        <p>Because OTr is a compiled 4D component rather than a binary plugin, it works identically on Apple Silicon and Intel Macs, on Windows, and under all 4D execution modes including compiled and preemptive-capable processes.</p>
        <p>The public method names use the <code>OTr_</code> prefix. For drop-in compatibility with existing code that calls <code>OT xxx</code>, the host project can install thin wrapper methods that forward to the component.</p>
      </div>
      <div>${codeBlock(quickStart, { commandHrefPrefix: "commands/" })}</div>
    </section>

    <section class="two-col">
      <div>
        <h2>OT vs OTr</h2>
        <p>ObjectTools plugin methods were named with a space: <code>OT GetText</code>, <code>OT PutLong</code>. The OTr equivalent replaces <code>OT&nbsp;</code> with <code>OTr_</code>: <code>OTr_GetText</code>, <code>OTr_PutLong</code>.</p>
        <p>For the handful of OTr methods that have no ObjectTools equivalent—such as <code>OTr_LoadFromText</code> and <code>OTr_GetVersion</code>—the naming convention still applies but there is no legacy call to migrate from.</p>
        <p>A small number of serialisation methods produce output that is <em>not</em> compatible with the plugin's own format. Those methods carry a warning in their reference page.</p>
        <a class="button secondary" href="naming.html">Full OT&thinsp;→&thinsp;OTr name map</a>
      </div>
      <div>${codeBlock(namingExample, { commandHrefPrefix: "commands/" })}</div>
    </section>

    <section>
      <h2>Method groups</h2>
      <div class="group-grid">
      ${groupCards}
      </div>
    </section>`;

  fs.writeFileSync(path.join(outDir, "index.html"), layout({ title: "Overview", crumb: [], body, isHome: true }));
}

function commandsPage(docs) {
  const sections = methodGroups.map((g) => {
    const rows = g.methods
      .filter((m) => docs[m])
      .map((m) => {
        const d = docs[m];
        const ot = otName(m);
        const otCell = ot ? `<code class="ot-name">${escapeHtml(ot)}</code>` : `<span class="muted">OTr only</span>`;
        return `<tr>
          <td><a href="commands/${slug(m)}.html"><code>${escapeHtml(m)}</code></a></td>
          <td>${otCell}</td>
          <td>${escapeHtml(d.brief)}</td>
        </tr>`;
      }).join("\n");

    return `<section id="${g.id}">
      <h2>${escapeHtml(g.title)}</h2>
      <p>${escapeHtml(g.summary)}</p>
      <div class="table-wrap">
        <table>
          <thead><tr><th>OTr name</th><th>OT equivalent</th><th>Description</th></tr></thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
    </section>`;
  }).join("\n    ");

  const body = `    <article class="doc-page wide">
      <h1>Commands</h1>
      <p class="lead">The public API covers handle management, typed scalar and array access, item inspection, serialisation, and configuration. About ${publicMethods.length} methods in total.</p>
    ${sections}
    </article>`;

  fs.writeFileSync(path.join(outDir, "commands.html"), layout({ title: "Commands", crumb: ["Commands"], body }));
}

function namingPage(docs) {
  const rows = publicMethods
    .filter((m) => docs[m])
    .map((m) => {
      const d = docs[m];
      const ot = otName(m);
      const changed = changedBehaviour.has(m);
      const notes = changed ? `<span class="badge changed">Changed behaviour</span>` : !ot ? `<span class="badge new">OTr only</span>` : "";
      return `<tr>
        <td>${ot ? `<code>${escapeHtml(ot)}</code>` : `<span class="muted">—</span>`}</td>
        <td><a href="commands/${slug(m)}.html"><code>${escapeHtml(m)}</code></a></td>
        <td>${notes}</td>
        <td>${escapeHtml(d.brief)}</td>
      </tr>`;
    }).join("\n");

  const body = `    <article class="doc-page wide">
      <h1>OT&thinsp;→&thinsp;OTr naming</h1>
      <p class="lead">ObjectTools plugin methods used the prefix <code>OT&nbsp;</code> with a space and mixed case. OTr replaces that prefix with <code>OTr_</code>. Most names translate directly; a few are new to OTr, and a few serialisation methods differ in behaviour from their plugin counterparts.</p>

      <section>
        <div class="legend">
          <span class="badge new">OTr only</span> No ObjectTools 5.0 equivalent exists.
          <span class="badge changed">Changed behaviour</span> Method exists in both, but the output format differs — see the individual reference page before migrating.
        </div>
        <div class="table-wrap">
          <table>
            <thead><tr><th>OT plugin name</th><th>OTr component name</th><th></th><th>Description</th></tr></thead>
            <tbody>${rows}</tbody>
          </table>
        </div>
      </section>
    </article>`;

  fs.writeFileSync(path.join(outDir, "naming.html"), layout({ title: "OT → OTr naming", crumb: ["OT → OTr"], body }));
}

function methodPage(name, docs) {
  const d = docs[name];
  const group = methodGroups.find((g) => g.methods.includes(name));
  const ot = otName(name);
  const changed = changedBehaviour.has(name);

  const otBadge = ot
    ? `<span class="ot-badge">ObjectTools equivalent: <code>${escapeHtml(ot)}</code></span>`
    : `<span class="ot-badge ot-badge--new">No ObjectTools&nbsp;5.0 equivalent</span>`;

  const changedBanner = changed
    ? `<div class="notice warning"><strong>Changed behaviour</strong><p>The output format of this method differs from the ObjectTools plugin equivalent. Text or BLOBs produced by one are not compatible with the other. See the description below for details.</p></div>`
    : "";

  const paramRows = d.params.length === 0
    ? `<p class="muted">This method takes no parameters.</p>`
    : `<div class="table-wrap"><table>
      <thead><tr><th>Parameter</th><th>Type</th><th>Direction</th><th>Description</th></tr></thead>
      <tbody>${d.params.map((p) => `<tr><td><code>${escapeHtml(p.name)}</code></td><td>${escapeHtml(p.type)}</td><td>${escapeHtml(p.dir)}</td><td>${escapeHtml(p.desc)}</td></tr>`).join("")}</tbody>
    </table></div>`;

  const body = `    <article class="doc-page">
      <p class="eyebrow">${escapeHtml(group?.title ?? "Public API")}</p>
      <h1>${escapeHtml(name)}</h1>
      ${otBadge}
      <p class="signature">${escapeHtml(d.signature)}</p>
      ${d.attributes ? `<p class="attributes">${escapeHtml(d.attributes)}</p>` : ""}
      ${changedBanner}
      <div class="description">
        ${d.description || `<p class="muted">No description available.</p>`}
      </div>
      <section>
        <h2>Parameters</h2>
        ${paramRows}
      </section>
    </article>`;

  fs.writeFileSync(
    path.join(commandsDir, `${slug(name)}.html`),
    layout({ title: name, crumb: ["Commands", name], body, depth: "sub" }),
  );
}

// ── Utilities ─────────────────────────────────────────────────────────────────

function slug(name) {
  return name.toLowerCase().replace(/_/g, "-").replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

function cleanText(s) {
  return String(s)
    .replace(/\\_/g, "_")
    .replace(/\s+/g, " ")
    .replace(/\bbehavior\b/g, "behaviour")
    .replace(/\bBehavior\b/g, "Behaviour")
    .trim();
}

function clipText(s, max) {
  if (!s || s.length <= max) return s;
  return s.slice(0, max - 1).trim() + "…";
}

function escapeHtml(s) {
  return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

function reEscape(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

// ── Alphabetical index page ───────────────────────────────────────────────────

function alphaPage(docs) {
  // Sort by bare name (OTr_ stripped), case-insensitive
  const sorted = publicMethods
    .filter((m) => docs[m])
    .map((m) => ({ name: m, bare: m.replace(/^OTr_/i, "") }))
    .sort((a, b) => a.bare.localeCompare(b.bare, undefined, { sensitivity: "base" }));

  // Group by first letter
  const groups = {};
  for (const entry of sorted) {
    const letter = entry.bare[0].toUpperCase();
    if (!groups[letter]) groups[letter] = [];
    groups[letter].push(entry);
  }
  const letters = Object.keys(groups).sort();

  const letterIndex = letters.map((l) =>
    `<a href="#alpha-${l}" class="alpha-lnk">${l}</a>`,
  ).join("");

  const sections = letters.map((l) => {
    const rows = groups[l].map(({ name, bare }) => {
      const d = docs[name];
      const ot = otName(name);
      const otSpan = ot ? ` <span class="alpha-ot">${escapeHtml(ot)}</span>` : "";
      return `<div class="alpha-entry">
          <a href="commands/${slug(name)}.html" class="alpha-method"><code>OTr_${escapeHtml(bare)}</code></a>${otSpan}
          <span class="alpha-brief">${escapeHtml(d.brief)}</span>
        </div>`;
    }).join("\n");
    return `<section id="alpha-${l}" class="alpha-section">
      <h2 class="alpha-heading">${l}</h2>
      ${rows}
    </section>`;
  }).join("\n    ");

  const body = `    <article class="doc-page wide">
      <h1>Alphabetical index</h1>
      <p class="lead">All ${publicMethods.length} public methods, sorted by name with the <code>OTr_</code> prefix omitted.</p>
      <div class="alpha-bar">${letterIndex}</div>
      ${sections}
    </article>`;

  fs.writeFileSync(path.join(outDir, "alpha.html"), layout({ title: "A–Z", crumb: ["A–Z"], body }));
}

// ── Why OTr page ──────────────────────────────────────────────────────────────

function whyPage() {
  function pq(text, cite) {
    return `<div class="pull-quote"><p>${escapeHtml(text)}</p><cite>${escapeHtml(cite)}</cite></div>`;
  }

  const body = `    <article class="doc-page">
      <h1>Why OTr?</h1>
      <p class="lead">The story of how a macOS update, a retirement announcement, and a community's response led to OTr.</p>

      <section>
        <h2>ObjectTools and Aparajita Fishman</h2>
        <p>ObjectTools was written by Aparajita Fishman around 1990–1991 and brought object-oriented data structures to 4D when the language offered no native equivalent, targeting 4D version 3.5. It was released publicly around 2000 and remained widely used for the next 25 years.</p>
        <p>Despite Aparajita recommending since 2013 that developers avoid ObjectTools in new projects, many codebases continued to depend on it. As Kirk Brooks summarised on the 4D Forum on 15 April 2026:</p>
        ${pq("In the best examples of 'it's still working and would be too hard to replace', folks kept using it and Aparajita kept patching it, which kept it working until it's not.", "Kirk Brooks · 4D Forum · 15 April 2026")}
      </section>

      <section>
        <h2>Aparajita's retirement announcement — 19 September 2025</h2>
        <p>After 43 years of software development and 25 years maintaining his plugins, Aparajita posted his retirement announcement to the 4D Forum on 19 September 2025. Both ObjectTools and Active4D had become financially unsustainable with essentially no new sales and a handful of upgrades per year. His assessment of ObjectTools was clear:</p>
        ${pq("ObjectTools is obviously redundant because 4D has had native object support for years now.", "Aparajita Fishman · 4D Forum · 19 September 2025")}
        <p>He presented the community with three options for the code's future — open source with community maintenance, open source with paid hourly support, or closed source with paid hourly support — noting he would likely only offer paid support through 2026 or 2027. He also observed that AI could assist significantly with migration for project-mode databases.</p>
      </section>

      <section>
        <h2>The macOS Tahoe 26.4 trigger — 30 March 2026</h2>
        <p>In March 2026, the macOS Tahoe 26.4 update caused 4D applications using the ObjectTools plugin to crash on launch. Apple had tightened memory management in Tahoe 26.4, exposing latent incompatibilities in the plugin's underlying C++ code. On 30 March 2026, Doug Hall posted:</p>
        ${pq("We're using 4D v20.8 LTS (using Foundation shell). 4D crashes on login after updating to Tahoe 26.4. Verified on three machines — one of them an Intel Mac. Works perfectly on 26.3.1.", "Doug Hall · 4D Forum · 30 March 2026")}
        <p>Wayne identified ObjectTools as the cause the same evening. Aparajita confirmed on 31 March 2026:</p>
        ${pq("Sorry @Hall.Doug but converting to native objects is really the way forward. The conversion from OT to native objects is fairly mechanical. With a well written plan AI should be able to handle the majority of it.", "Aparajita Fishman · 4D Forum · 31 March 2026")}
        <p>Doug's situation illustrated the severity of the problem for many developers. On 2 April 2026 he wrote:</p>
        ${pq("I have 522 methods in my project which use ObjectTools. Granted, most of them are Get/Set wrapper methods, so some of that can be quickly changed to use objects. But the official current policy of the department where I work disallows me from using AI.", "Doug Hall · 4D Forum · 2 April 2026")}
        <p>Guy Algot also encountered the crash and contributed debugging work alongside Wayne in the days that followed.</p>
      </section>

      <section>
        <h2>Wayne's response — April 2026</h2>
        <p>Wayne works part time for 4D. This project was undertaken entirely in his own time. OTr is a community contribution — it is not an official 4D product and carries no 4D support obligation.</p>
        <p>Within hours of Doug's crash report on 30 March 2026, Wayne posted to the same thread: <em>"I'm working on this now, will share progress shortly."</em> On 4 April 2026, following the first demonstration at the 4D Happy Hour, he announced a near-complete replacement:</p>
        ${pq("I've been working on an OT replacement since the manure hit the circulating air-movement device. Today at the Happy Hour, I was able to demo an almost complete 4D native replacement. Thanks to Guy Algot for helping me debug a few issues. Thanks to Rob Laveaux, Cannon Smith, Dave Batton, and Steve Willis for assistance along the way. This will be provided free to the developer community.", "Wayne Stewart · 4D Forum · 4 April 2026")}
        <p>Wayne was candid about the architectural limits of the first release. The initial implementation used inter-process arrays — a pair of arrays (objects and booleans) — and was not designed for preemptive processes or modern multi-threaded architectures. At the Happy Hour he described it informally as a "cludge", noting that converting to idiomatic native object syntax was the correct next step. His forum post on 14 April 2026 was explicit:</p>
        ${pq("This approach is intended as a short-term bridge to help systems remain operational in light of the recent macOS-related issues affecting ObjectTools. It should be considered a temporary measure rather than a forward-looking replacement.", "Wayne Stewart · 4D Forum · 14 April 2026")}
        <p>Guy Algot demonstrated his own application of the component at the Happy Hour on 17 April 2026, showing how he had replaced OT in a customer application using Wayne's repository.</p>
      </section>

      <section>
        <h2>Aparajita's generosity — 14–18 April 2026</h2>
        <p>Despite having announced his retirement, Aparajita made two significant contributions. On 14 April 2026 he announced he would open source the ObjectTools C++ code so that AI could be used to write blob-conversion tooling:</p>
        ${pq("I will open source the OT code, then you can use AI to write 4D code to convert a serialized OT object to a 4D object.", "Aparajita Fishman · 4D Forum · 14 April 2026")}
        <p>Wayne had been attempting to reverse-engineer the OT blob format without access to the source, and responded the same morning:</p>
        ${pq("That's great news, I'm burning through tokens trying to reverse engineer your blob format.", "Wayne Stewart · 4D Forum · 14 April 2026")}
        <p>On 18 April 2026, Aparajita also released ObjectTools v5.1r2 — a bug-fix addressing the Tahoe 26.4 crash. The fix involved updating the underlying ICU framework from version 71 to version 77 and tightening memory management. Both were clear this was a bridge, not a destination. Wayne posted to the forum the same day:</p>
        ${pq("Thanks for that! A lot of people will be very happy. However, I'd still encourage everyone using the plugin to start migration away as soon as possible. Who knows what the next macOS update will break?", "Wayne Stewart · 4D Forum · 18 April 2026")}
        <p>Aparajita agreed:</p>
        ${pq("So would I — this is just to tide folks over until they can migrate to native objects.", "Aparajita Fishman · 4D Forum · 18 April 2026")}
        <p>Aparajita also provided Wayne with access to the ObjectTools source code on 18 April 2026, enabling the development of <code>OTr_ImportLegacyBlob</code> — the method that reads and converts data originally stored in the OT binary format.</p>
      </section>
    </article>`;

  fs.writeFileSync(path.join(outDir, "why.html"), layout({ title: "Why OTr?", crumb: ["Why OTr?"], body }));
}

// ── Styles ────────────────────────────────────────────────────────────────────

function writeStyles() {
  const css = `:root {
  color-scheme: light;
  --bg: #f4f6fb;
  --panel: #ffffff;
  --ink: #1b1f2e;
  --muted: #5e6573;
  --rule: #d0d5e0;
  --soft: #e8ecf4;
  --accent: #1a4fbd;
  --accent-dark: #12388a;
  --accent-light: #e8eefb;
  --link: #1a4fbd;
  --code-bg: #f9fafc;
  --code-border: #cdd3e0;
}

* { box-sizing: border-box; }

body {
  margin: 0;
  background: var(--bg);
  color: var(--ink);
  font: 16px/1.6 -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif;
}

a { color: var(--link); text-decoration: none; }
a:hover { text-decoration: underline; }

.site-header {
  position: sticky;
  top: 0;
  z-index: 10;
  border-bottom: 1px solid var(--rule);
  background: rgba(244, 246, 251, 0.96);
  backdrop-filter: blur(6px);
}

.breadcrumb,
.masthead,
.page-shell {
  max-width: 1200px;
  margin: 0 auto;
  padding-left: 24px;
  padding-right: 24px;
}

.breadcrumb {
  padding-top: 10px;
  color: var(--muted);
  font-size: 13px;
}
.breadcrumb .sep { padding: 0 6px; color: #aab0be; }

.masthead {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  min-height: 54px;
  gap: 20px;
}

.brand {
  color: var(--ink);
  font-weight: 700;
  font-size: 15px;
  letter-spacing: -0.01em;
}

.top-links {
  display: flex;
  gap: 16px;
  font-size: 14px;
}

.page-shell { padding-top: 32px; padding-bottom: 64px; }

/* ── Hero ── */
.hero {
  padding: 40px 0 48px;
  border-bottom: 1px solid var(--rule);
}
.hero h1 {
  margin: 0 0 12px;
  font-size: clamp(44px, 7vw, 80px);
  line-height: 0.97;
  letter-spacing: -0.02em;
  color: var(--ink);
}
.hero-tagline {
  max-width: 560px;
  margin: 0 0 24px;
  color: var(--muted);
  font-size: 20px;
}
.hero-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

/* ── Buttons ── */
.button {
  display: inline-flex;
  align-items: center;
  min-height: 38px;
  padding: 7px 14px;
  border: 1.5px solid var(--accent);
  border-radius: 6px;
  background: var(--accent);
  color: #fff;
  font-size: 14px;
  font-weight: 700;
}
.button.secondary {
  background: var(--panel);
  color: var(--accent-dark);
}
.button:hover { text-decoration: none; opacity: 0.88; }

/* ── Typography ── */
h1 { margin: 0 0 10px; font-size: 44px; line-height: 1.04; letter-spacing: -0.02em; }
h2 { margin: 0 0 14px; font-size: 26px; letter-spacing: -0.01em; }
h3 { margin: 0 0 8px; font-size: 17px; }
section { margin-top: 44px; }

.eyebrow {
  margin: 0 0 10px;
  color: var(--accent-dark);
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.09em;
  text-transform: uppercase;
}

.lead {
  max-width: 800px;
  margin: 0 0 24px;
  color: #3c4252;
  font-size: 19px;
  line-height: 1.5;
}

/* ── Two-col ── */
.two-col {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 1.3fr);
  gap: 28px;
  align-items: start;
}

/* ── Group grid ── */
.group-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 14px;
}
.group-card {
  padding: 16px 18px;
  border: 1px solid var(--rule);
  border-radius: 8px;
  background: var(--panel);
}
.group-card h3 { margin: 0 0 6px; font-size: 15px; }
.group-card p { margin: 0 0 4px; font-size: 14px; color: var(--muted); }
.group-count { font-size: 12px; color: #8a90a0; }

/* ── Doc pages ── */
.doc-page { max-width: 900px; }
.doc-page.wide { max-width: none; }

.ot-badge {
  display: inline-block;
  margin: 2px 0 14px;
  padding: 4px 10px;
  border-radius: 6px;
  background: var(--accent-light);
  color: var(--accent-dark);
  font-size: 13px;
}
.ot-badge--new {
  background: #f0f0f0;
  color: var(--muted);
}

.signature,
code,
.code,
.ot-name {
  font-family: "Courier Prime", "SFMono-Regular", Consolas, "Liberation Mono", monospace;
}

/* Prevent the OTr-name and OT-equivalent columns from wrapping */
.table-wrap table td:nth-child(1),
.table-wrap table td:nth-child(2),
.table-wrap table th:nth-child(1),
.table-wrap table th:nth-child(2) {
  white-space: nowrap;
}

.signature {
  display: inline-block;
  margin: 0 0 10px;
  padding: 5px 9px;
  border: 1px solid var(--rule);
  border-radius: 6px;
  background: var(--panel);
  font-size: 13px;
  color: #2a3040;
}

.attributes {
  display: inline-block;
  margin: 0 0 16px;
  padding: 3px 10px;
  border-radius: 999px;
  background: var(--soft);
  color: var(--muted);
  font-size: 12px;
  font-weight: 700;
}

/* ── Notices ── */
.notice {
  margin: 16px 0;
  padding: 13px 16px;
  border-radius: 8px;
  border-left: 4px solid;
}
.notice p { margin: 6px 0 0; }
.notice strong { display: block; font-size: 15px; }
.notice.warning {
  background: #fffbf0;
  border-color: #d08000;
  color: #5a3600;
}
.notice.warning strong { color: #a06000; }
.notice.note {
  background: #f0f6ff;
  border-color: var(--accent);
  color: #1a2a50;
}
.notice.note strong { color: var(--accent-dark); }
.notice.original {
  background: #f7f8fa;
  border-color: var(--rule);
  color: var(--muted);
}
.notice.original strong { color: var(--ink); }

/* Inline section headings from bold text */
.notice.warning-heading,
.notice.note-heading,
.notice.original-heading {
  /* rendered as bare <p> tags by the simple parser — style them as eyebrows */
  padding: 0;
  background: none;
  border: none;
  margin-top: 20px;
  margin-bottom: 4px;
  font-weight: 800;
  font-size: 12px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--muted);
}
.notice.warning-heading { color: #a06000; }
.notice.note-heading { color: var(--accent-dark); }

/* ── Tables ── */
.table-wrap {
  overflow-x: auto;
  border: 1px solid var(--rule);
  border-radius: 8px;
  background: var(--panel);
}
table { width: 100%; border-collapse: collapse; }
th, td {
  padding: 10px 12px;
  border-bottom: 1px solid var(--soft);
  text-align: left;
  vertical-align: top;
}
th { color: #5a6070; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
tr:last-child td { border-bottom: 0; }

/* ── Badges ── */
.badge {
  display: inline-block;
  padding: 2px 7px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 700;
  vertical-align: middle;
}
.badge.new { background: #f0f0f0; color: var(--muted); }
.badge.changed { background: #fff3d4; color: #7a4800; }

.legend {
  margin-bottom: 16px;
  font-size: 14px;
  color: var(--muted);
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  align-items: center;
}

/* ── Code blocks ── */
.code {
  overflow-x: auto;
  margin: 0;
  padding: 14px 16px;
  border: 1px solid var(--code-border);
  border-radius: 8px;
  background: var(--code-bg);
  font-size: 13.5px;
  line-height: 1.5;
  tab-size: 4;
}

.tok-cmd { color: #0060a8; font-weight: 700; }
a.code-cmd-link,
a.code-cmd-link:hover { color: #0060a8; text-decoration: none; }
.tok-comment { color: #6b7280; font-style: italic; }
.tok-const { color: #6500a0; }
.tok-kw { color: #005a00; font-weight: 700; }
.tok-local { color: #1d3fba; }
.tok-string { color: #185a00; }
.tok-number { color: #b03000; }
.tok-attr { color: #7d5a4a; }

.muted { color: var(--muted); }

/* ── Alphabetical index ── */
.alpha-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  padding: 14px 16px;
  border: 1px solid var(--rule);
  border-radius: 8px;
  background: var(--panel);
  margin-bottom: 32px;
}
.alpha-lnk {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  border: 1px solid var(--rule);
  border-radius: 5px;
  font-weight: 700;
  font-size: 14px;
  color: var(--accent);
}
.alpha-lnk:hover { background: var(--accent-light); text-decoration: none; }

.alpha-section { margin-top: 36px; }
.alpha-heading {
  display: inline-block;
  margin: 0 0 10px;
  padding: 0 10px 4px 0;
  border-bottom: 3px solid var(--accent);
  font-size: 30px;
  font-weight: 800;
  color: var(--accent);
}
.alpha-entry {
  display: flex;
  align-items: baseline;
  gap: 14px;
  padding: 5px 0;
  border-bottom: 1px solid var(--soft);
}
.alpha-method { flex-shrink: 0; min-width: 280px; font-size: 14px; }
.alpha-ot {
  flex-shrink: 0;
  min-width: 160px;
  font-family: "Courier Prime", "SFMono-Regular", Consolas, "Liberation Mono", monospace;
  font-size: 13px;
  color: var(--muted);
  white-space: nowrap;
}
.alpha-brief { font-size: 14px; color: var(--muted); }

/* ── Pull quotes ── */
.pull-quote {
  position: relative;
  margin: 32px 0 32px 44px;
  padding-left: 2px;
}
.pull-quote::before {
  content: "\\201C";
  position: absolute;
  left: -52px;
  top: -18px;
  font-size: 5.5rem;
  line-height: 1;
  font-family: Georgia, "Times New Roman", serif;
  color: var(--ink);
}
.pull-quote p {
  margin: 0;
  font-style: italic;
  font-family: Georgia, "Times New Roman", serif;
  font-size: 16px;
  line-height: 1.78;
  color: var(--ink);
}
.pull-quote cite {
  display: block;
  margin-top: 13px;
  font-style: normal;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.09em;
  text-transform: uppercase;
  color: var(--muted);
}
.pull-quote cite::before { content: "\\2014\\2002"; }

@media (max-width: 780px) {
  .two-col { grid-template-columns: 1fr; }
  .masthead { flex-direction: column; align-items: flex-start; padding: 10px 0 12px; }
  .hero h1 { font-size: 42px; }
  h1 { font-size: 34px; }
  .group-grid { grid-template-columns: 1fr; }
}
`;
  fs.writeFileSync(path.join(assetsDir, "styles.css"), css);
}

// ── Main ──────────────────────────────────────────────────────────────────────

// Reset output directories (leave assets alone — overwritten below)
fs.rmSync(commandsDir, { recursive: true, force: true });
fs.mkdirSync(commandsDir, { recursive: true });
fs.mkdirSync(assetsDir, { recursive: true });

const docs = Object.fromEntries(publicMethods.map((m) => [m, readDoc(m)]));

writeStyles();
indexPage(docs);
commandsPage(docs);
alphaPage(docs);
namingPage(docs);
whyPage();
publicMethods.forEach((m) => methodPage(m, docs));

const missing = publicMethods.filter((m) => !fs.existsSync(path.join(docsDir, `${m}.md`)));
if (missing.length) {
  console.warn(`Warning: no .md file for: ${missing.join(", ")}`);
}

console.log(`Generated ${publicMethods.length} command pages + index, commands, alpha, naming, why — total ${publicMethods.length + 5} files.`);
