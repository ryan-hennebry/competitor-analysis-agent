#!/usr/bin/env python3
"""
Convert markdown briefing to PDF with proper formatting.
Usage: python3 generate_pdf.py <input.md> <output.pdf>
"""

import sys
import re
from reportlab.lib.pagesizes import letter, landscape
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.lib.enums import TA_LEFT


def create_styles():
    """Create paragraph styles for the PDF."""
    styles = getSampleStyleSheet()

    styles.add(ParagraphStyle(
        name='CustomTitle',
        parent=styles['Title'],
        fontSize=16,
        spaceAfter=16,
        textColor=colors.HexColor('#1a1a1a'),
        alignment=TA_LEFT
    ))
    styles.add(ParagraphStyle(
        name='CustomHeading1',
        parent=styles['Heading1'],
        fontSize=13,
        spaceBefore=14,
        spaceAfter=6,
        textColor=colors.HexColor('#2563eb'),
        alignment=TA_LEFT
    ))
    styles.add(ParagraphStyle(
        name='CustomHeading2',
        parent=styles['Heading2'],
        fontSize=11,
        spaceBefore=10,
        spaceAfter=5,
        textColor=colors.HexColor('#1e40af'),
        alignment=TA_LEFT
    ))
    styles.add(ParagraphStyle(
        name='CustomBody',
        parent=styles['Normal'],
        fontSize=9,
        spaceBefore=3,
        spaceAfter=3,
        leading=12,
        alignment=TA_LEFT
    ))
    styles.add(ParagraphStyle(
        name='CustomBullet',
        parent=styles['Normal'],
        fontSize=9,
        leftIndent=15,
        spaceBefore=2,
        spaceAfter=2,
        leading=12,
        alignment=TA_LEFT
    ))
    styles.add(ParagraphStyle(
        name='TableCell',
        parent=styles['Normal'],
        fontSize=8,
        leading=10,
        alignment=TA_LEFT
    ))

    return styles


def render_table(table_data, page_width, styles):
    """Render a table with smart column widths, left aligned."""
    if not table_data:
        return None

    num_cols = len(table_data[0])

    # Calculate content-aware column widths
    col_max_chars = [0] * num_cols
    for row in table_data:
        for i, cell in enumerate(row):
            clean = re.sub(r'<[^>]+>', '', cell)
            col_max_chars[i] = max(col_max_chars[i], len(clean))

    total_chars = sum(col_max_chars) or 1

    # Proportional widths with constraints
    col_widths = []
    for chars in col_max_chars:
        ratio = chars / total_chars
        width = ratio * page_width
        width = max(0.8*inch, min(3*inch, width))
        col_widths.append(width)

    # Scale to fit page
    total_width = sum(col_widths)
    if total_width > page_width:
        scale = page_width / total_width
        col_widths = [w * scale for w in col_widths]

    # Convert to Paragraphs
    wrapped_data = []
    for row in table_data:
        wrapped_row = [Paragraph(cell, styles['TableCell']) for cell in row]
        wrapped_data.append(wrapped_row)

    t = Table(wrapped_data, colWidths=col_widths, hAlign='LEFT')
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#f1f5f9')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.HexColor('#1e293b')),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 6),
        ('TOPPADDING', (0, 0), (-1, 0), 6),
        ('BOTTOMPADDING', (0, 1), (-1, -1), 4),
        ('TOPPADDING', (0, 1), (-1, -1), 4),
        ('BACKGROUND', (0, 1), (-1, -1), colors.white),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#e2e8f0')),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('LEFTPADDING', (0, 0), (-1, -1), 4),
        ('RIGHTPADDING', (0, 0), (-1, -1), 4),
    ]))
    return t


def markdown_to_pdf(input_path, output_path):
    """Convert markdown file to PDF."""

    with open(input_path, "r") as f:
        content = f.read()

    # Create PDF in landscape
    doc = SimpleDocTemplate(
        output_path,
        pagesize=landscape(letter),
        rightMargin=0.5*inch,
        leftMargin=0.5*inch,
        topMargin=0.5*inch,
        bottomMargin=0.5*inch
    )

    page_width = landscape(letter)[0] - 1*inch
    styles = create_styles()
    story = []

    lines = content.split('\n')
    i = 0
    in_table = False
    table_data = []

    while i < len(lines):
        line = lines[i].strip()

        # End table if needed
        if in_table and (not line or not line.startswith('|')):
            in_table = False
            if table_data:
                t = render_table(table_data, page_width, styles)
                if t:
                    story.append(t)
                    story.append(Spacer(1, 10))
                table_data = []
            if not line:
                i += 1
                continue

        if not line:
            i += 1
            continue

        # Title
        if line.startswith('# ') and not line.startswith('## '):
            text = re.sub(r'\*\*([^*]+)\*\*', r'<b>\1</b>', line[2:])
            story.append(Paragraph(text, styles['CustomTitle']))
            story.append(Spacer(1, 10))

        # Heading 2
        elif line.startswith('## ') and not line.startswith('### '):
            text = re.sub(r'\*\*([^*]+)\*\*', r'<b>\1</b>', line[3:])
            story.append(Paragraph(text, styles['CustomHeading1']))

        # Heading 3
        elif line.startswith('### '):
            text = re.sub(r'\*\*([^*]+)\*\*', r'<b>\1</b>', line[4:])
            story.append(Paragraph(text, styles['CustomHeading2']))

        # Horizontal rule
        elif line.startswith('---'):
            story.append(Spacer(1, 6))

        # Table row
        elif line.startswith('|'):
            if re.match(r'^\|[\s\-:|]+\|$', line):
                i += 1
                continue

            if not in_table:
                in_table = True
                table_data = []

            cells = [cell.strip() for cell in line.split('|')[1:-1]]
            cells = [re.sub(r'\*\*([^*]+)\*\*', r'<b>\1</b>', cell) for cell in cells]
            cells = [re.sub(r'\[(\d+)\]', r'[\1]', cell) for cell in cells]
            table_data.append(cells)

        # Bullet point
        elif line.startswith('- ') or line.startswith('* '):
            text = line[2:]
            text = re.sub(r'\*\*([^*]+)\*\*', r'<b>\1</b>', text)
            text = re.sub(r'\[(\d+)\]', r'<super>[\1]</super>', text)
            story.append(Paragraph(f"• {text}", styles['CustomBullet']))

        # Numbered list
        elif re.match(r'^\d+\.', line):
            text = re.sub(r'^\d+\.\s*', '', line)
            text = re.sub(r'\*\*([^*]+)\*\*', r'<b>\1</b>', text)
            num = re.match(r'^(\d+)\.', line).group(1)
            story.append(Paragraph(f"{num}. {text}", styles['CustomBullet']))

        # Regular paragraph
        else:
            text = line
            text = re.sub(r'\*\*([^*]+)\*\*', r'<b>\1</b>', text)
            text = re.sub(r'\[(\d+)\]', r'<super>[\1]</super>', text)
            text = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2" color="blue">\1</a>', text)
            story.append(Paragraph(text, styles['CustomBody']))

        i += 1

    # Handle remaining table
    if in_table and table_data:
        t = render_table(table_data, page_width, styles)
        if t:
            story.append(t)

    doc.build(story)
    print(f"PDF created: {output_path}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 generate_pdf.py <input.md> <output.pdf>")
        sys.exit(1)

    markdown_to_pdf(sys.argv[1], sys.argv[2])
