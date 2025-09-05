#!/bin/bash
# Document Analysis Script
# Usage: ./analyze_document.sh <file_path>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file_path>"
    echo "Analyzes a document for potentially malicious content"
    exit 1
fi

FILE="$1"
BASENAME=$(basename "$FILE")
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_DIR="$HOME/investigations/${BASENAME}_${TIMESTAMP}"

echo "=== Document Analysis Report ==="
echo "File: $FILE"
echo "Analysis started: $(date)"
echo "Report directory: $REPORT_DIR"
echo

# Create report directory
mkdir -p "$REPORT_DIR"

# Basic file information
echo "=== File Information ===" | tee "$REPORT_DIR/basic_info.txt"
file "$FILE" | tee -a "$REPORT_DIR/basic_info.txt"
ls -la "$FILE" | tee -a "$REPORT_DIR/basic_info.txt"
echo | tee -a "$REPORT_DIR/basic_info.txt"

# File hash
echo "=== File Hashes ===" | tee "$REPORT_DIR/hashes.txt"
md5sum "$FILE" | tee -a "$REPORT_DIR/hashes.txt"
sha1sum "$FILE" | tee -a "$REPORT_DIR/hashes.txt"
sha256sum "$FILE" | tee -a "$REPORT_DIR/hashes.txt"
echo | tee -a "$REPORT_DIR/hashes.txt"

# Strings analysis
echo "=== Strings Analysis ===" | tee "$REPORT_DIR/strings.txt"
strings "$FILE" 2>/dev/null | head -100 | tee -a "$REPORT_DIR/strings.txt" || \
    grep -a '[[:print:]]\{4,\}' "$FILE" 2>/dev/null | head -100 | tee -a "$REPORT_DIR/strings.txt"
echo "... (showing first 100 strings)" | tee -a "$REPORT_DIR/strings.txt"
echo | tee -a "$REPORT_DIR/strings.txt"

# Hexdump sample
echo "=== Hex Dump (first 512 bytes) ===" | tee "$REPORT_DIR/hexdump.txt"
xxd "$FILE" 2>/dev/null | head -32 | tee -a "$REPORT_DIR/hexdump.txt" || \
    hexdump -C "$FILE" 2>/dev/null | head -32 | tee -a "$REPORT_DIR/hexdump.txt"
echo | tee -a "$REPORT_DIR/hexdump.txt"

# File type specific analysis using Python
EXT="${FILE##*.}"
case "${EXT,,}" in
    pdf)
        echo "=== PDF Analysis ===" | tee "$REPORT_DIR/pdf_analysis.txt"
        python3 -c "
import sys
try:
    import pdfplumber
    with pdfplumber.open('$FILE') as pdf:
        print(f'Pages: {len(pdf.pages)}')
        print(f'Metadata: {pdf.metadata}')
        if pdf.pages:
            print('First page text preview:')
            print(pdf.pages[0].extract_text()[:500])
except Exception as e:
    print(f'PDF analysis error: {e}')
" 2>/dev/null | tee -a "$REPORT_DIR/pdf_analysis.txt"
        ;;
    doc|docx)
        echo "=== Word Document Analysis ===" | tee "$REPORT_DIR/word_analysis.txt"
        python3 -c "
try:
    from docx import Document
    doc = Document('$FILE')
    print(f'Paragraphs: {len(doc.paragraphs)}')
    print('Text preview:')
    for i, para in enumerate(doc.paragraphs[:5]):
        print(f'Para {i}: {para.text[:100]}')
except Exception as e:
    print(f'Word analysis error: {e}')
" 2>/dev/null | tee -a "$REPORT_DIR/word_analysis.txt"
        ;;
    xls|xlsx)
        echo "=== Excel Analysis ===" | tee "$REPORT_DIR/excel_analysis.txt"
        python3 -c "
try:
    import openpyxl
    wb = openpyxl.load_workbook('$FILE')
    print('Sheets:', wb.sheetnames)
    for sheet in wb.worksheets:
        print(f'Sheet: {sheet.title}, Max row: {sheet.max_row}, Max col: {sheet.max_column}')
        # Sample some cell values
        for row in range(1, min(6, sheet.max_row + 1)):
            for col in range(1, min(4, sheet.max_column + 1)):
                cell = sheet.cell(row=row, column=col)
                if cell.value:
                    print(f'  {cell.coordinate}: {str(cell.value)[:50]}')
except Exception as e:
    print(f'Excel analysis error: {e}')
" 2>/dev/null | tee -a "$REPORT_DIR/excel_analysis.txt"
        ;;
esac

echo
echo "=== Analysis Complete ==="
echo "Report saved to: $REPORT_DIR"
echo "To view the document safely, run: ./safe_view.sh \"$FILE\""