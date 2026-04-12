#!/usr/bin/env python3
"""
Generate OTr Native Object Tools PDF documentation.
Produces A4 and US Letter versions with:
- Facing pages (inner 2cm, outer/top/bottom 1cm)
- Chapters starting on recto (right-hand) pages
- Clickable Table of Contents
- PDF bookmarks (two-level: chapter > method)
- Running headers (chapter name) and page numbers
- Horizontal rule separators between methods
"""

import os
import re
import sys
from collections import OrderedDict

from reportlab.lib.pagesizes import A4, letter
from reportlab.lib.units import cm, mm
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_RIGHT, TA_JUSTIFY
from reportlab.lib.colors import HexColor, black, grey, white
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, PageBreak,
    Table, TableStyle, KeepTogether, Flowable, NextPageTemplate,
    ActionFlowable
)
from reportlab.platypus.tableofcontents import TableOfContents

# ─── Configuration ────────────────────────────────────────────────────────────

METHODS_DIR = "/sessions/trusting-affectionate-lovelace/mnt/nativeObjectTools/Documentation/Methods"
OUTPUT_DIR  = "/sessions/trusting-affectionate-lovelace/mnt/nativeObjectTools/Documentation/PDFs"

INNER_MARGIN = 2 * cm
OUTER_MARGIN = 1 * cm
TOP_MARGIN   = 1 * cm
BOTTOM_MARGIN = 1 * cm

HEADER_HEIGHT = 0.8 * cm
FOOTER_HEIGHT = 0.8 * cm

# ─── Chapter definitions ──────────────────────────────────────────────────────
#
# Each entry is (chapter_name, list_of_filename_prefixes).
# A file is assigned to the FIRST chapter whose prefix list contains a matching
# prefix.  Matching: fname.startswith(prefix + "_") or fname == prefix + ".md".
#
# The order here determines chapter order in the document.

CHAPTERS = OrderedDict([
    ("Object Management", [
        "OTr_New", "OTr_Clear", "OTr_ClearAll", "OTr_Copy",
        "OTr_CopyItem", "OTr_DeleteItem", "OTr_RenameItem",
        "OTr_ItemType", "OTr_ItemCount", "OTr_ItemExists",
        "OTr_ObjectSize", "OTr_Info", "OTr_IsEmbedded", "OTr_IsObject",
        "OTr_ArrayType", "OTr_CompareItems",
        "OTr_GetActiveHandleCount", "OTr_GetHandleList",
        "OTr_GetOptions", "OTr_SetOptions",
        "OTr_IncludeShadowKey", "OTr_GetVersion",
        "OTr_Register", "OTr_CompiledApplication",
        "OTr_LogLevel", "OTr_SetErrorHandler", "OTr_SetDateMode",
        "OTr_onStartup", "OTr_onExit",
    ]),
    ("Get Values", [
        "OTr_GetBoolean", "OTr_GetDate", "OTr_GetLong",
        "OTr_GetPicture", "OTr_GetPointer", "OTr_GetReal",
        "OTr_GetString", "OTr_GetText", "OTr_GetTime",
        "OTr_GetBLOB", "OTr_GetNewBLOB", "OTr_GetObject",
        "OTr_GetRecord", "OTr_GetRecordTable",
        "OTr_GetVariable",
    ]),
    ("Put Values", [
        "OTr_PutBoolean", "OTr_PutDate", "OTr_PutLong",
        "OTr_PutPicture", "OTr_PutPointer", "OTr_PutReal",
        "OTr_PutString", "OTr_PutText", "OTr_PutTime",
        "OTr_PutBLOB", "OTr_PutObject",
        "OTr_PutRecord", "OTr_PutVariable",
    ]),
    ("Array Operations", [
        "OTr_GetArray", "OTr_PutArray",
        "OTr_GetArrayBoolean", "OTr_PutArrayBoolean",
        "OTr_GetArrayDate",   "OTr_PutArrayDate",
        "OTr_GetArrayLong",   "OTr_PutArrayLong",
        "OTr_GetArrayReal",   "OTr_PutArrayReal",
        "OTr_GetArrayString", "OTr_PutArrayString",
        "OTr_GetArrayText",   "OTr_PutArrayText",
        "OTr_GetArrayTime",   "OTr_PutArrayTime",
        "OTr_GetArrayBLOB",   "OTr_PutArrayBLOB",
        "OTr_GetArrayPicture","OTr_PutArrayPicture",
        "OTr_GetArrayPointer","OTr_PutArrayPointer",
        "OTr_SizeOfArray", "OTr_ResizeArray",
        "OTr_FindInArray",
        "OTr_SortArrays",
        "OTr_DeleteElement", "OTr_InsertElement",
    ]),
    ("Serialisation", [
        "OTr_BLOBToObject", "OTr_ObjectToBLOB", "OTr_ObjectToNewBLOB",
        "OTr_LoadFromBlob",  "OTr_SaveToBlob",
        "OTr_LoadFromClipboard", "OTr_SaveToClipboard",
        "OTr_LoadFromFile",  "OTr_SaveToFile",
        "OTr_LoadFromGZIP",  "OTr_SaveToGZIP",
        "OTr_LoadFromText",  "OTr_SaveToText",
        "OTr_LoadFromXML",   "OTr_SaveToXML",
        "OTr_LoadFromXMLFile","OTr_SaveToXMLFile","OTr_SaveToXMLFileSAX",
        "OTr_SaveToXMLSAX",
    ]),
    ("Property Introspection", [
        "OTr_GetAllNamedProperties", "OTr_GetAllProperties",
        "OTr_GetItemProperties", "OTr_GetNamedProperties",
    ]),
    ("Utility Methods", [
        "OTr_u",   # matches all OTr_u* files
    ]),
    ("Internal Methods", [
        "OTr_z",   # matches all OTr_z* files
        "OTr_z_",  # matches OTr_z_* files (already covered, kept for clarity)
    ]),
])

# ─── Colours ──────────────────────────────────────────────────────────────────

DARK_BLUE       = HexColor("#1a3a5c")
MID_BLUE        = HexColor("#2c5f8a")
LIGHT_GREY      = HexColor("#e8e8e8")
RULE_GREY       = HexColor("#999999")
TABLE_HEADER_BG = HexColor("#2c5f8a")
TABLE_ALT_ROW   = HexColor("#f0f4f8")


# ─── XML/HTML escaping for ReportLab Paragraphs ──────────────────────────────

def xml_escape(text):
    """Escape text for safe use in ReportLab Paragraph XML."""
    if not text:
        return text
    text = text.replace('&', '&amp;')
    text = text.replace('<', '&lt;')
    text = text.replace('>', '&gt;')
    return text


# ─── File Discovery and Grouping ─────────────────────────────────────────────

# Files to exclude entirely from the PDF
EXCLUDED_PREFIXES = (
    "Compiler_", "Constants_", "Fnd_", "LOG ", "Log ", "_DEL_",
    "____Test_", "___template", "________",
    "Is a method", "TimetoDie", "__WriteDocumentation",
)

def _is_excluded(fname):
    for pfx in EXCLUDED_PREFIXES:
        if fname.startswith(pfx):
            return True
    # Exclude filenames that have spaces (non-OTr methods)
    if " " in fname and not fname.startswith("OTr_"):
        return True
    return False


def discover_files():
    """Discover and group all OTr_ .md files into chapters."""
    all_files = sorted([
        f for f in os.listdir(METHODS_DIR)
        if f.endswith('.md') and not _is_excluded(f)
    ])

    # Build a mapping: filename -> chapter_name
    assignment = {}     # fname -> chapter_name
    chapter_files = OrderedDict((name, []) for name in CHAPTERS)
    orphans = []

    for fname in all_files:
        matched = False
        for chapter_name, prefixes in CHAPTERS.items():
            for prefix in prefixes:
                # Exact match: "OTr_New.md"
                if fname == prefix + ".md":
                    chapter_files[chapter_name].append(fname)
                    matched = True
                    break
                # Prefix match: "OTr_New_Something.md"
                if fname.startswith(prefix + "_"):
                    chapter_files[chapter_name].append(fname)
                    matched = True
                    break
                # Short-prefix match (e.g. "OTr_u" matches "OTr_uBlobToText.md")
                # Only for prefixes that don't end with "_"
                if not prefix.endswith("_") and fname.startswith(prefix) and len(prefix) < len(fname.replace(".md", "")):
                    # Make sure next char after prefix is uppercase (camelCase boundary)
                    next_char = fname[len(prefix)] if len(fname) > len(prefix) else ""
                    if next_char.isupper() or next_char == ".":
                        chapter_files[chapter_name].append(fname)
                        matched = True
                        break
            if matched:
                break

        if not matched:
            orphans.append(fname)

    # Sort files within each chapter
    ordered_chapters = OrderedDict()
    for chapter_name, files in chapter_files.items():
        if files:
            ordered_chapters[chapter_name] = sorted(files)

    return ordered_chapters, sorted(orphans)


# ─── Markdown Parsing ─────────────────────────────────────────────────────────

def parse_md_file(filepath):
    """Parse a .md file and return structured content.

    Named parameters use the pattern $word+ (e.g. $inObject_i, $result_b)
    rather than positional $0, $1, so the regex is updated accordingly.
    """
    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        raw = f.read()

    result = {
        'method_name': '',
        'signature': '',
        'description': [],       # List of paragraph strings
        'attributes': '',
        'parameters': [],
        'has_params': True,
    }

    # Get the method name from the filename (most reliable)
    basename = os.path.splitext(os.path.basename(filepath))[0]
    result['method_name'] = basename

    # Extract parameter table rows FIRST (from raw, before any processing).
    # Named params: $inObject_i, $inTag_t, $result_b, etc.
    # Also matches positional $0 / $1 for robustness.
    param_rows = re.findall(r'\|(\$[\w]+)\|([^|]+)\|([^|]+)\|([^|]+)\|', raw)
    for row in param_rows:
        result['parameters'].append({
            'name':      row[0],
            'type':      row[1].strip(),
            'direction': row[2].strip().replace('➡️', '\u2192').replace('⬅️', '\u2190'),
            'description': row[3].strip().replace('\\_', '_'),
        })

    # Check for "Does not require any parameters"
    if 'Does not require any parameters' in raw:
        result['has_params'] = False

    # Strip HTML comments
    content = re.sub(r'<!--.*?-->', '', raw, flags=re.DOTALL).strip()

    # Normalise line endings: \r\n -> \n, then lone \r -> \n
    content = content.replace('\r\n', '\n').replace('\r', '\n')

    # Split into paragraphs on double newlines
    paragraphs = [p.strip() for p in re.split(r'\n{2,}', content) if p.strip()]

    # Normalise escaped underscores in all paragraphs
    paragraphs = [p.replace('\\_', '_') for p in paragraphs]

    # Process paragraphs into structured fields
    sig_text = ''
    desc_paragraphs = []
    found_signature = False

    for para in paragraphs:
        # Skip the ## heading paragraph
        if para.startswith('## ') or para.startswith('##'):
            continue

        # Skip table rows (lines starting with |)
        if para.startswith('|'):
            continue

        # Skip "Does not require any parameters" standalone paragraphs
        if re.match(r'^Does not require any parameters\.?$', para.strip()):
            continue

        # Skip "Parameters" or "---" table headers that got split
        if re.match(r'^\|?\s*Parameters\s*\|?$', para) or re.match(r'^\|?\s*---\s*\|?$', para):
            continue

        # Check for attributes line
        attr_match = re.match(r'^Attributes:\s*(.+)$', para)
        if attr_match:
            result['attributes'] = attr_match.group(1).strip()
            continue

        # Check for signature (method name + optional params/return)
        if not found_signature:
            sig_pattern = re.compile(
                r'^' + re.escape(basename) +
                r'(\s*[\({].*?[\)}]\s*(?:-->|->)\s*\S+' +   # (params) --> Type
                r'|\s*[\({].*?[\)}]' +                        # (params) only
                r'|\s*(?:-->|->)\s*\S+' +                     # --> Type only
                r')?$'
            )
            sig_match = sig_pattern.match(para)
            if sig_match:
                found_signature = True
                after_name = sig_match.group(1)
                if after_name and after_name.strip():
                    result['signature'] = sig_match.group(0).strip()
                continue  # Don't add method name as description

        # This is a description paragraph.
        # Clean up any remaining table fragments within the paragraph
        cleaned = re.sub(r'\|[^|]*\|[^|]*\|.*', '', para).strip()
        if not cleaned:
            continue

        # Clean up leading arrow fragments
        cleaned = re.sub(r'^(?:-->|->)\s*\S+\s*', '', cleaned).strip()

        # Capitalise if starts lowercase (from sentence fragmentation)
        if cleaned and cleaned[0].islower():
            cleaned = cleaned[0].upper() + cleaned[1:]

        if cleaned:
            desc_paragraphs.append(cleaned)

    result['description'] = desc_paragraphs

    return result


# ─── Custom Flowables ─────────────────────────────────────────────────────────

class HorizontalRule(Flowable):
    """A horizontal rule with spacing above and below."""
    def __init__(self, width, thickness=0.5, color=RULE_GREY, space_before=6, space_after=6):
        Flowable.__init__(self)
        self.width = width
        self.thickness = thickness
        self.color = color
        self.space_before = space_before
        self.space_after = space_after

    def wrap(self, availWidth, availHeight):
        self.width = availWidth
        return (availWidth, self.space_before + self.thickness + self.space_after)

    def draw(self):
        self.canv.setStrokeColor(self.color)
        self.canv.setLineWidth(self.thickness)
        y = self.space_after
        self.canv.line(0, y, self.width, y)


class ChapterStart(Flowable):
    """Invisible flowable that notifies the doc template of a chapter change."""
    def __init__(self, chapter_name):
        Flowable.__init__(self)
        self.chapter_name = chapter_name

    def wrap(self, availWidth, availHeight):
        return (0, 0)

    def draw(self):
        pass


class ClearChapter(Flowable):
    """Invisible flowable that clears the current chapter (for ToC/title pages)."""
    def wrap(self, availWidth, availHeight):
        return (0, 0)

    def draw(self):
        pass


# ─── Document Template ────────────────────────────────────────────────────────

class FacingPagesDocTemplate(BaseDocTemplate):
    """Document template with facing pages, headers, and footers."""

    def __init__(self, filename, pagesize, **kwargs):
        self.page_width, self.page_height = pagesize
        self._current_chapter = ""
        BaseDocTemplate.__init__(self, filename, pagesize=pagesize, **kwargs)
        self._setup_page_templates()

    def _setup_page_templates(self):
        """Create recto (right/odd) and verso (left/even) page templates."""

        # Recto (odd/right) pages: inner margin on LEFT
        recto_frame = Frame(
            INNER_MARGIN,
            BOTTOM_MARGIN + FOOTER_HEIGHT,
            self.page_width - INNER_MARGIN - OUTER_MARGIN,
            self.page_height - TOP_MARGIN - BOTTOM_MARGIN - HEADER_HEIGHT - FOOTER_HEIGHT,
            id='recto_frame',
            leftPadding=0, rightPadding=0, topPadding=0, bottomPadding=0
        )

        # Verso (even/left) pages: inner margin on RIGHT
        verso_frame = Frame(
            OUTER_MARGIN,
            BOTTOM_MARGIN + FOOTER_HEIGHT,
            self.page_width - INNER_MARGIN - OUTER_MARGIN,
            self.page_height - TOP_MARGIN - BOTTOM_MARGIN - HEADER_HEIGHT - FOOTER_HEIGHT,
            id='verso_frame',
            leftPadding=0, rightPadding=0, topPadding=0, bottomPadding=0
        )

        # Blank page template (for inserted blanks before recto chapter starts)
        blank_frame = Frame(
            OUTER_MARGIN,
            BOTTOM_MARGIN,
            self.page_width - INNER_MARGIN - OUTER_MARGIN,
            self.page_height - TOP_MARGIN - BOTTOM_MARGIN,
            id='blank_frame'
        )

        self.addPageTemplates([
            PageTemplate(id='title',  frames=[recto_frame], onPage=self._title_page),
            PageTemplate(id='recto',  frames=[recto_frame], onPage=self._recto_page),
            PageTemplate(id='verso',  frames=[verso_frame], onPage=self._verso_page),
            PageTemplate(id='blank',  frames=[blank_frame], onPage=self._blank_page),
        ])

    def _title_page(self, canvas, doc):
        """Draw the title page — no headers/footers."""
        pass

    def _recto_page(self, canvas, doc):
        """Draw recto (right/odd) page with header and footer."""
        self._draw_header(canvas, doc, is_recto=True)
        self._draw_page_number(canvas, doc, is_recto=True)

    def _verso_page(self, canvas, doc):
        """Draw verso (left/even) page with header and footer."""
        self._draw_header(canvas, doc, is_recto=False)
        self._draw_page_number(canvas, doc, is_recto=False)

    def _blank_page(self, canvas, doc):
        """Intentionally blank page — no content."""
        pass

    def _draw_header(self, canvas, doc, is_recto):
        """Draw chapter name in header."""
        if not self._current_chapter:
            return
        canvas.saveState()
        canvas.setFont("Helvetica", 8)
        canvas.setFillColor(RULE_GREY)
        y = self.page_height - TOP_MARGIN + 2 * mm
        if is_recto:
            x = self.page_width - OUTER_MARGIN
            canvas.drawRightString(x, y, self._current_chapter)
        else:
            x = OUTER_MARGIN
            canvas.drawString(x, y, self._current_chapter)

        # Draw a thin rule under the header
        canvas.setStrokeColor(LIGHT_GREY)
        canvas.setLineWidth(0.3)
        rule_y = y - 2 * mm
        if is_recto:
            canvas.line(INNER_MARGIN, rule_y, self.page_width - OUTER_MARGIN, rule_y)
        else:
            canvas.line(OUTER_MARGIN, rule_y, self.page_width - INNER_MARGIN, rule_y)
        canvas.restoreState()

    def _draw_page_number(self, canvas, doc, is_recto):
        """Draw page number in footer."""
        canvas.saveState()
        canvas.setFont("Helvetica", 8)
        canvas.setFillColor(grey)
        y = BOTTOM_MARGIN - 2 * mm
        page_num = str(canvas.getPageNumber())
        if is_recto:
            x = self.page_width - OUTER_MARGIN
            canvas.drawRightString(x, y, page_num)
        else:
            x = OUTER_MARGIN
            canvas.drawString(x, y, page_num)
        canvas.restoreState()

    def afterFlowable(self, flowable):
        """Track TOC entries and chapter changes."""
        if isinstance(flowable, ClearChapter):
            self._current_chapter = ""
        elif isinstance(flowable, ChapterStart):
            self._current_chapter = flowable.chapter_name

        # Register TOC entries based on paragraph style
        if isinstance(flowable, Paragraph):
            text = flowable.getPlainText()
            style = flowable.style.name
            if style == 'ChapterHeading':
                key = f"ch_{text}"
                self.canv.bookmarkPage(key)
                self.canv.addOutlineEntry(text, key, level=0, closed=True)
                self.notify('TOCEntry', (0, text, self.page, key))
            elif style == 'MethodHeading':
                key = f"m_{text}"
                self.canv.bookmarkPage(key)
                self.canv.addOutlineEntry(text, key, level=1, closed=True)
                self.notify('TOCEntry', (1, text, self.page, key))

    def handle_pageEnd(self):
        """Override to automatically alternate recto/verso based on page number."""
        BaseDocTemplate.handle_pageEnd(self)
        page_just_done = self.canv.getPageNumber()
        next_page = page_just_done + 1
        if next_page % 2 == 1:
            self._nextPageTemplateIndex = self._getPageTemplateIndex('recto')
        else:
            self._nextPageTemplateIndex = self._getPageTemplateIndex('verso')

    def _getPageTemplateIndex(self, template_id):
        """Get the index of a page template by its id."""
        for i, pt in enumerate(self.pageTemplates):
            if pt.id == template_id:
                return i
        return 0


# ─── Styles ───────────────────────────────────────────────────────────────────

def create_styles():
    """Create all paragraph styles."""
    styles = getSampleStyleSheet()

    styles.add(ParagraphStyle(
        'BookTitle',
        parent=styles['Title'],
        fontSize=28,
        leading=34,
        textColor=DARK_BLUE,
        spaceAfter=20,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold',
    ))

    styles.add(ParagraphStyle(
        'BookSubtitle',
        parent=styles['Normal'],
        fontSize=14,
        leading=18,
        textColor=MID_BLUE,
        spaceAfter=40,
        alignment=TA_CENTER,
        fontName='Helvetica',
    ))

    styles.add(ParagraphStyle(
        'ChapterHeading',
        parent=styles['Heading1'],
        fontSize=22,
        leading=28,
        textColor=DARK_BLUE,
        spaceBefore=0,
        spaceAfter=16,
        fontName='Helvetica-Bold',
        keepWithNext=True,
    ))

    styles.add(ParagraphStyle(
        'MethodHeading',
        parent=styles['Heading2'],
        fontSize=12,
        leading=16,
        textColor=DARK_BLUE,
        spaceBefore=4,
        spaceAfter=6,
        fontName='Helvetica-Bold',
        keepWithNext=True,
    ))

    styles.add(ParagraphStyle(
        'MethodSignature',
        parent=styles['Normal'],
        fontSize=9,
        leading=12,
        textColor=HexColor("#444444"),
        spaceAfter=4,
        fontName='Courier',
        keepWithNext=True,
    ))

    styles.add(ParagraphStyle(
        'MethodDescription',
        parent=styles['Normal'],
        fontSize=9,
        leading=13,
        textColor=black,
        spaceAfter=4,
        fontName='Helvetica',
        alignment=TA_JUSTIFY,
    ))

    styles.add(ParagraphStyle(
        'MethodAttributes',
        parent=styles['Normal'],
        fontSize=8,
        leading=11,
        textColor=HexColor("#666666"),
        spaceAfter=6,
        fontName='Helvetica-Oblique',
    ))

    styles.add(ParagraphStyle(
        'TOCHeading',
        parent=styles['Heading1'],
        fontSize=22,
        leading=28,
        textColor=DARK_BLUE,
        spaceBefore=0,
        spaceAfter=20,
        fontName='Helvetica-Bold',
    ))

    styles.add(ParagraphStyle(
        'TOCChapter',
        parent=styles['Normal'],
        fontSize=11,
        leading=18,
        fontName='Helvetica-Bold',
        textColor=DARK_BLUE,
        leftIndent=0,
    ))

    styles.add(ParagraphStyle(
        'TOCMethod',
        parent=styles['Normal'],
        fontSize=8,
        leading=12,
        fontName='Helvetica',
        textColor=HexColor("#444444"),
        leftIndent=12,
    ))

    return styles


# ─── Build method flowables ──────────────────────────────────────────────────

def build_method_flowables(filepath, styles, frame_width):
    """Build flowables for a single method from its .md file."""
    parsed = parse_md_file(filepath)
    elements = []

    # Method name heading — use filename-derived name (underscores intact)
    method_name = parsed['method_name']
    elements.append(Paragraph(xml_escape(method_name), styles['MethodHeading']))

    # Signature
    if parsed['signature']:
        elements.append(Paragraph(xml_escape(parsed['signature']), styles['MethodSignature']))

    # Description paragraphs
    for para in parsed['description']:
        elements.append(Paragraph(xml_escape(para), styles['MethodDescription']))

    # Attributes
    if parsed['attributes']:
        elements.append(Paragraph(
            "Attributes: " + xml_escape(parsed['attributes']),
            styles['MethodAttributes']
        ))

    # Parameter table
    if parsed['parameters']:
        table_data = [['Parameter', 'Type', '', 'Description']]
        for p in parsed['parameters']:
            table_data.append([
                p['name'],
                p['type'],
                p['direction'],
                p['description'],
            ])

        col_widths = [
            frame_width * 0.16,   # parameter name — wider for named params
            frame_width * 0.10,
            frame_width * 0.05,
            frame_width * 0.69,
        ]

        tbl = Table(table_data, colWidths=col_widths, repeatRows=1)
        tbl_style = TableStyle([
            # Header row
            ('BACKGROUND', (0, 0), (-1, 0), TABLE_HEADER_BG),
            ('TEXTCOLOR',  (0, 0), (-1, 0), white),
            ('FONTNAME',   (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE',   (0, 0), (-1, 0), 8),
            # Body rows
            ('FONTNAME',   (0, 1), (-1, -1), 'Helvetica'),
            ('FONTSIZE',   (0, 1), (-1, -1), 8),
            ('LEADING',    (0, 0), (-1, -1), 11),
            # Alternating row colours
            *[('BACKGROUND', (0, i), (-1, i), TABLE_ALT_ROW)
              for i in range(1, len(table_data), 2)],
            # Grid
            ('LINEBELOW',  (0, 0), (-1, 0),  0.5, white),
            ('LINEBELOW',  (0, 1), (-1, -2), 0.25, LIGHT_GREY),
            ('LINEBELOW',  (0, -1), (-1, -1), 0.5, MID_BLUE),
            # Padding
            ('TOPPADDING',    (0, 0), (-1, -1), 2),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 2),
            ('LEFTPADDING',   (0, 0), (-1, -1), 4),
            ('RIGHTPADDING',  (0, 0), (-1, -1), 4),
            # Alignment
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ])
        tbl.setStyle(tbl_style)
        elements.append(Spacer(1, 2))
        elements.append(tbl)
    elif not parsed['has_params']:
        elements.append(Paragraph(
            "Does not require any parameters.",
            styles['MethodAttributes']
        ))

    # Wrap in KeepTogether so heading + first content aren't orphaned
    return KeepTogether(elements)


# ─── Build the complete document ──────────────────────────────────────────────

def build_document(pagesize, output_filename):
    """Build the complete PDF document."""
    page_width, page_height = pagesize
    size_label = "A4" if pagesize == A4 else "US Letter"
    print(f"\n{'='*60}")
    print(f"Building {size_label} version: {output_filename}")
    print(f"{'='*60}")

    styles = create_styles()

    doc = FacingPagesDocTemplate(
        output_filename,
        pagesize=pagesize,
        title="OTr Native Object Tools \u2014 Method Reference",
        author="Wayne Stewart",
        subject="OTr Native Object Tools Documentation",
    )

    frame_width = page_width - INNER_MARGIN - OUTER_MARGIN
    story = []

    # ── Title Page (page 1, recto) ────────────────────────────────────────
    story.append(NextPageTemplate('title'))
    story.append(ClearChapter())  # Ensure no header on title/ToC pages
    story.append(Spacer(1, page_height * 0.25))
    story.append(Paragraph(
        "OTr Native Object Tools",
        styles['BookTitle']
    ))
    story.append(Paragraph(
        "Method Reference",
        styles['BookSubtitle']
    ))
    story.append(Spacer(1, 30))
    story.append(Paragraph(
        "Complete documentation of all OTr methods",
        ParagraphStyle('TitleDesc', parent=styles['Normal'],
                       fontSize=11, leading=15, alignment=TA_CENTER,
                       textColor=HexColor("#666666"))
    ))

    # ── Table of Contents (starts page 2) ─────────────────────────────────
    story.append(NextPageTemplate('verso'))
    story.append(PageBreak())

    story.append(Paragraph("Table of Contents", styles['TOCHeading']))
    toc = TableOfContents()
    toc.levelStyles = [
        styles['TOCChapter'],
        styles['TOCMethod'],
    ]
    story.append(toc)

    # ── Chapters ──────────────────────────────────────────────────────────
    chapters, orphans = discover_files()

    print(f"\nFound {len(chapters)} chapters:")
    total_methods = 0
    for chapter_name, files in chapters.items():
        print(f"  {chapter_name}: {len(files)} methods")
        total_methods += len(files)

    if orphans:
        print(f"  Other Methods: {len(orphans)} methods")
        total_methods += len(orphans)
    print(f"\nTotal methods: {total_methods}")

    def add_chapter(chapter_name, files):
        """Add a chapter to the story, ensuring it starts on a recto page."""
        print(f"  Processing: {chapter_name}...")

        story.append(NextPageTemplate('recto'))
        story.append(PageBreak())

        story.append(ChapterStart(chapter_name))
        story.append(Paragraph(chapter_name, styles['ChapterHeading']))

        for i, fname in enumerate(files):
            if i > 0:
                story.append(HorizontalRule(frame_width))

            filepath = os.path.join(METHODS_DIR, fname)
            method_block = build_method_flowables(filepath, styles, frame_width)
            story.append(method_block)

    for chapter_name, files in chapters.items():
        add_chapter(chapter_name, files)

    # ── Other Methods (orphans) ───────────────────────────────────────────
    if orphans:
        add_chapter("Other Methods", orphans)

    # ── Build (multi-pass for TOC) ────────────────────────────────────────
    print(f"\nRendering PDF...")
    doc.multiBuild(story)
    print(f"Done! Output: {output_filename}")


# ─── Main ─────────────────────────────────────────────────────────────────────

def main():
    try:
        import reportlab
        print(f"Using ReportLab version: {reportlab.Version}")
    except ImportError:
        print("ERROR: reportlab not found. Install with: pip install reportlab")
        sys.exit(1)

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    a4_output     = os.path.join(OUTPUT_DIR, "OTr_Methods_A4.pdf")
    letter_output = os.path.join(OUTPUT_DIR, "OTr_Methods_Letter.pdf")

    build_document(A4, a4_output)
    build_document(letter, letter_output)

    print(f"\n{'='*60}")
    print("Complete!")
    print(f"  A4:        {a4_output}")
    print(f"  US Letter: {letter_output}")
    print(f"{'='*60}")


if __name__ == '__main__':
    main()
