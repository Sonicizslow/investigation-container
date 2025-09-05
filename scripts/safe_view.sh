#!/bin/bash
# Safe Document Viewer
# Usage: ./safe_view.sh <file_path>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file_path>"
    echo "Opens a document in a safe viewing mode"
    exit 1
fi

FILE="$1"
EXT="${FILE##*.}"

echo "Opening $FILE safely..."

case "${EXT,,}" in
    pdf)
        echo "Opening PDF with Firefox (built-in PDF viewer)..."
        firefox "file://$FILE" 2>/dev/null &
        ;;
    doc|docx|odt|txt|log)
        echo "Opening document with gedit..."
        gedit "$FILE" 2>/dev/null &
        ;;
    xls|xlsx|ods)
        echo "Note: Excel files should be analyzed with the analysis script first."
        echo "Opening as text with gedit for basic viewing..."
        gedit "$FILE" 2>/dev/null &
        ;;
    *)
        echo "Opening file with gedit (text editor)..."
        gedit "$FILE" 2>/dev/null &
        ;;
esac

echo "File opened in safe mode. Close the application when done reviewing."