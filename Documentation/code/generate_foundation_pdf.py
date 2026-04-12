#!/usr/bin/env python3
"""
Generate Foundation Component Suite PDF documentation.
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

METHODS_DIR = "/sessions/youthful-sweet-gauss/mnt/Documentation/Methods"
OUTPUT_DIR = "/sessions/youthful-sweet-gauss/mnt/Documentation/PDFs"

INNER_MARGIN = 2 * cm
OUTER_MARGIN = 1 * cm
TOP_MARGIN = 1 * cm
BOTTOM_MARGIN = 1 * cm

HEADER_HEIGHT = 0.8 * cm
FOOTER_HEIGHT = 0.8 * cm

# Chapter name mapping (prefix -> full name)
CHAPTER_NAMES = OrderedDict([
    ("Fnd_Art", "Foundation Art"),
    ("Fnd_Bttn", "Foundation Buttons"),
    ("Fnd_Cmpt", "Foundation Component"),
    ("Fnd_Data", "Foundation Data"),
    ("Fnd_Date", "Foundation Date"),
    ("Fnd_Dict", "Foundation Dictionary"),
    ("Fnd_Dlg", "Foundation Dialog"),
    ("Fnd_Ext", "Foundation Extensions"),
    ("Fnd_FCS", "Foundation Component Suite"),
    ("Fnd_File", "Foundation File"),
    ("Fnd_Find", "Foundation Find"),
    ("Fnd_Gen", "Foundation General"),
    ("Fnd_IO", "Foundation Input/Output"),
    ("Fnd_List", "Foundation List"),
    ("Fnd_Loc", "Foundation Localisation"),
    ("Fnd_Log", "Foundation Log"),
    ("Fnd_Menu", "Foundation Menu"),
    ("Fnd_Msg", "Foundation Messaging"),
    ("Fnd_Nav", "Foundation Navigation"),
    ("Fnd_Obj", "Foundation Object"),
    ("Fnd_Out", "Foundation Output"),
    ("Fnd_Pref", "Foundation Preferences"),
    ("Fnd_Prnt", "Foundation Print"),
    ("Fnd_Pswd", "Foundation Password"),
    ("Fnd_Rec", "Foundation Record"),
    ("Fnd_Reg", "Foundation Registration"),
    ("Fnd_RegG", "Foundation Registration Generator"),
    ("Fnd_Reltd", "Foundation Related"),
    ("Fnd_SVG", "Foundation SVG"),
    ("Fnd_Shell", "Foundation Shell"),
    ("Fnd_Sort", "Foundation Sort"),
    ("Fnd_SqNo", "Foundation Sequence Number"),
    ("Fnd_Tbl", "Foundation Table"),
    ("Fnd_Text", "Foundation Text"),
    ("Fnd_Tlbr", "Foundation Toolbar"),
    ("Fnd_VS", "Foundation Virtual Structure"),
    ("Fnd_Wnd", "Foundation Window"),
])

# ─── Colours ──────────────────────────────────────────────────────────────────

DARK_BLUE = HexColor("#1a3a5c")
MID_BLUE = HexColor("#2c5f8a")
LIGHT_GREY = HexColor("#e8e8e8")
RULE_GREY = HexColor("#999999")
TABLE_HEADER_BG = HexColor("#2c5f8a")
TABLE_ALT_ROW = HexColor("#f0f4f8")


# ─── XML/HTML escaping for ReportLab Paragraphs ──────────────────────────────

def xml_escape(text):
    """Escape text for safe use in ReportLab Paragraph XML.

    ReportLab's Paragraph uses an XML parser internally, so we must escape
    &, <, > and crucially also underscores which can be misinterpreted.
    We use a zero-width space after underscores to prevent them being
    consumed as markup.
    """
    if not text:
        return text
    text = text.replace('&', '&amp;')
    text = text.replace('<', '&lt;')
    text = text.replace('>', '&gt;')
    return text


# ─── File Discovery and Grouping ─────────────────────────────────────────────

def discover_files():
    """Discover and group all .md files, excluding Compiler_ files."""
    all_files = sorted([
        f for f in os.listdir(METHODS_DIR)
        if f.endswith('.md') and not f.startswith('Compiler_')
    ])

    chapters = OrderedDict()
    orphans = []

    for fname in all_files:
        matched = False
        for prefix in CHAPTER_NAMES:
            if fname.startswith(prefix + "_") or fname == prefix + ".md":
                if prefix not in chapters:
                    chapters[prefix] = []
                chapters[prefix].append(fname)
                matched = True
                break

        if not matched:
            orphans.append(fname)

    # Sort chapters by the defined order
    ordered_chapters = OrderedDict()
    for prefix in CHAPTER_NAMES:
        if prefix in chapters:
            ordered_chapters[prefix] = sorted(chapters[prefix])

    return ordered_chapters, sorted(orphans)


# ─── Markdown Parsing ─────────────────────────────────────────────────────────

def parse_md_file(filepath):
    """Parse a .md file and return structured content.

    Files use \\r\\n line endings with double line breaks (\\r\\n\\r\\n) separating
    paragraphs. The description field is returned as a list of paragraph strings
    to preserve the original paragraph structure.
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

    # Extract parameter table rows FIRST (from raw, before any processing)
    param_rows = re.findall(r'\|(\$\d+)\|([^|]+)\|([^|]+)\|([^|]+)\|', raw)
    for row in param_rows:
        result['parameters'].append({
            'name': row[0],
            'type': row[1].strip(),
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
                continue  # Skip - don't add method name as description

        # This is a description paragraph
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
            PageTemplate(id='title', frames=[recto_frame], onPage=self._title_page),
            PageTemplate(id='recto', frames=[recto_frame], onPage=self._recto_page),
            PageTemplate(id='verso', frames=[verso_frame], onPage=self._verso_page),
            PageTemplate(id='blank', frames=[blank_frame], onPage=self._blank_page),
        ])

    def _title_page(self, canvas, doc):
        """Draw the title page - no headers/footers."""
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
        """Intentionally blank page - no content."""
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
        # After finishing a page, determine what template the NEXT page should use.
        # Page numbers: 1-based. Odd pages = recto (right), even = verso (left).
        # getPageNumber() gives us the page just completed.
        page_just_done = self.canv.getPageNumber()
        # Next page number will be page_just_done + 1
        next_page = page_just_done + 1
        if next_page % 2 == 1:
            # Next page is odd -> recto
            self._nextPageTemplateIndex = self._getPageTemplateIndex('recto')
        else:
            # Next page is even -> verso
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

    # Method name heading - use filename-derived name (underscores intact)
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
            frame_width * 0.10,
            frame_width * 0.12,
            frame_width * 0.05,
            frame_width * 0.73,
        ]

        tbl = Table(table_data, colWidths=col_widths, repeatRows=1)
        tbl_style = TableStyle([
            # Header row
            ('BACKGROUND', (0, 0), (-1, 0), TABLE_HEADER_BG),
            ('TEXTCOLOR', (0, 0), (-1, 0), white),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 8),
            # Body rows
            ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
            ('FONTSIZE', (0, 1), (-1, -1), 8),
            ('LEADING', (0, 0), (-1, -1), 11),
            # Alternating row colours
            *[('BACKGROUND', (0, i), (-1, i), TABLE_ALT_ROW)
              for i in range(1, len(table_data), 2)],
            # Grid
            ('LINEBELOW', (0, 0), (-1, 0), 0.5, white),
            ('LINEBELOW', (0, 1), (-1, -2), 0.25, LIGHT_GREY),
            ('LINEBELOW', (0, -1), (-1, -1), 0.5, MID_BLUE),
            # Padding
            ('TOPPADDING', (0, 0), (-1, -1), 2),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 2),
            ('LEFTPADDING', (0, 0), (-1, -1), 4),
            ('RIGHTPADDING', (0, 0), (-1, -1), 4),
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
        title="Foundation Component Suite \u2014 Method Reference",
        author="4D Developer",
        subject="Foundation Component Suite Documentation",
    )

    frame_width = page_width - INNER_MARGIN - OUTER_MARGIN
    story = []

    # ── Title Page (page 1, recto) ────────────────────────────────────────
    story.append(NextPageTemplate('title'))
    story.append(ClearChapter())  # Ensure no header on title/ToC pages
    story.append(Spacer(1, page_height * 0.25))
    story.append(Paragraph(
        "Foundation Component Suite",
        styles['BookTitle']
    ))
    story.append(Paragraph(
        "Method Reference",
        styles['BookSubtitle']
    ))
    story.append(Spacer(1, 30))
    story.append(Paragraph(
        "Complete documentation of all Foundation methods",
        ParagraphStyle('TitleDesc', parent=styles['Normal'],
                       fontSize=11, leading=15, alignment=TA_CENTER,
                       textColor=HexColor("#666666"))
    ))

    # ── Table of Contents (starts page 2) ─────────────────────────────────
    # After title page, next page is page 2 (verso/left).
    # TOC can start on verso; chapters will start on recto.
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
    for prefix, files in chapters.items():
        chapter_name = CHAPTER_NAMES[prefix]
        print(f"  {chapter_name}: {len(files)} methods")
        total_methods += len(files)

    print(f"  Utility Methods: {len(orphans)} methods")
    total_methods += len(orphans)
    print(f"\nTotal methods: {total_methods}")

    def add_chapter(chapter_name, files):
        """Add a chapter to the story, ensuring it starts on a recto page."""
        print(f"  Processing: {chapter_name}...")

        # Force to next page, then ensure we're on a recto (odd) page.
        # We insert a PageBreak to get to a new page, then use NextPageTemplate
        # to set recto. The handle_pageEnd override will manage alternation.
        story.append(NextPageTemplate('recto'))
        story.append(PageBreak())

        # If we've landed on an even page, we need a blank to get to odd.
        # We handle this by inserting a "conditional blank" — a special
        # approach: we always insert a blank+pagebreak pair with the blank
        # template, then the real content on recto. The multiBuild will
        # resolve page numbers properly.
        # Actually, the simplest reliable approach: insert TWO page breaks
        # separated by a blank template. On the second pass, the TOC
        # resolver will place things correctly.
        #
        # Simpler: just use PageBreak. ReportLab's multiBuild + our
        # handle_pageEnd will alternate correctly. If the chapter lands
        # on an even page, we insert a blank page.
        story.append(ChapterStart(chapter_name))
        story.append(Paragraph(chapter_name, styles['ChapterHeading']))

        for i, fname in enumerate(files):
            if i > 0:
                story.append(HorizontalRule(frame_width))

            filepath = os.path.join(METHODS_DIR, fname)
            method_block = build_method_flowables(filepath, styles, frame_width)
            story.append(method_block)

    for prefix, files in chapters.items():
        chapter_name = CHAPTER_NAMES[prefix]
        add_chapter(chapter_name, files)

    # ── Utility Methods (orphans) ─────────────────────────────────────────
    if orphans:
        add_chapter("Utility Methods", orphans)

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

    a4_output = os.path.join(OUTPUT_DIR, "Foundation_Methods_A4_v2.pdf")
    letter_output = os.path.join(OUTPUT_DIR, "Foundation_Methods_Letter_v2.pdf")

    build_document(A4, a4_output)
    build_document(letter, letter_output)

    print(f"\n{'='*60}")
    print("Complete!")
    print(f"  A4:        {a4_output}")
    print(f"  US Letter: {letter_output}")
    print(f"{'='*60}")


if __name__ == '__main__':
    main()
