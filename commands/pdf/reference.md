# PDF Processing Advanced Reference

Advanced PDF processing features, detailed examples, and additional libraries.

## pypdfium2 Library (Apache/BSD License)

Python binding for PDFium (Chromium's PDF library). Excellent for fast PDF rendering and image generation.

### Render PDF to Images
```python
import pypdfium2 as pdfium

pdf = pdfium.PdfDocument("document.pdf")

# Render page to image
page = pdf[0]
bitmap = page.render(scale=2.0, rotation=0)
img = bitmap.to_pil()
img.save("page_1.png", "PNG")

# Process multiple pages
for i, page in enumerate(pdf):
    bitmap = page.render(scale=1.5)
    img = bitmap.to_pil()
    img.save(f"page_{i+1}.jpg", "JPEG", quality=90)
```

### Extract Text
```python
import pypdfium2 as pdfium

pdf = pdfium.PdfDocument("document.pdf")
for i, page in enumerate(pdf):
    text = page.get_text()
    print(f"Page {i+1} text length: {len(text)} chars")
```

## JavaScript Libraries

### pdf-lib (MIT License)

Create and modify PDF documents in any JavaScript environment.

#### Load and Manipulate Existing PDF
```javascript
import { PDFDocument } from 'pdf-lib';
import fs from 'fs';

async function manipulatePDF() {
    const existingPdfBytes = fs.readFileSync('input.pdf');
    const pdfDoc = await PDFDocument.load(existingPdfBytes);

    const pageCount = pdfDoc.getPageCount();
    console.log(`Document has ${pageCount} pages`);

    // Add new page
    const newPage = pdfDoc.addPage([600, 400]);
    newPage.drawText('Added by pdf-lib', { x: 100, y: 300, size: 16 });

    const pdfBytes = await pdfDoc.save();
    fs.writeFileSync('modified.pdf', pdfBytes);
}
```

#### Create Complex PDFs
```javascript
import { PDFDocument, rgb, StandardFonts } from 'pdf-lib';

async function createPDF() {
    const pdfDoc = await PDFDocument.create();

    const helveticaFont = await pdfDoc.embedFont(StandardFonts.Helvetica);
    const helveticaBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);

    const page = pdfDoc.addPage([595, 842]); // A4
    const { width, height } = page.getSize();

    page.drawText('Invoice #12345', {
        x: 50, y: height - 50,
        size: 18, font: helveticaBold,
        color: rgb(0.2, 0.2, 0.8)
    });

    page.drawRectangle({
        x: 40, y: height - 100,
        width: width - 80, height: 30,
        color: rgb(0.9, 0.9, 0.9)
    });

    const pdfBytes = await pdfDoc.save();
    fs.writeFileSync('created.pdf', pdfBytes);
}
```

#### Advanced Merge
```javascript
async function mergePDFs() {
    const mergedPdf = await PDFDocument.create();

    const pdf1 = await PDFDocument.load(fs.readFileSync('doc1.pdf'));
    const pdf2 = await PDFDocument.load(fs.readFileSync('doc2.pdf'));

    const pdf1Pages = await mergedPdf.copyPages(pdf1, pdf1.getPageIndices());
    pdf1Pages.forEach(page => mergedPdf.addPage(page));

    // Copy specific pages from second PDF
    const pdf2Pages = await mergedPdf.copyPages(pdf2, [0, 2, 4]);
    pdf2Pages.forEach(page => mergedPdf.addPage(page));

    fs.writeFileSync('merged.pdf', await mergedPdf.save());
}
```

### pdfjs-dist (Apache License)

Mozilla's JavaScript library for rendering PDFs in the browser.

```javascript
import * as pdfjsLib from 'pdfjs-dist';

pdfjsLib.GlobalWorkerOptions.workerSrc = './pdf.worker.js';

async function renderPDF() {
    const loadingTask = pdfjsLib.getDocument('document.pdf');
    const pdf = await loadingTask.promise;

    const page = await pdf.getPage(1);
    const viewport = page.getViewport({ scale: 1.5 });

    const canvas = document.createElement('canvas');
    const context = canvas.getContext('2d');
    canvas.height = viewport.height;
    canvas.width = viewport.width;

    await page.render({ canvasContext: context, viewport }).promise;
}
```

## Advanced Command-Line Operations

### poppler-utils

```bash
# Extract text with bounding box coordinates
pdftotext -bbox-layout document.pdf output.xml

# Convert to PNG with specific resolution
pdftoppm -png -r 300 document.pdf output_prefix

# Convert specific page range
pdftoppm -png -r 600 -f 1 -l 3 document.pdf high_res

# Extract embedded images
pdfimages -j -p document.pdf page_images
pdfimages -list document.pdf  # List without extracting
```

### qpdf Advanced

```bash
# Split into groups
qpdf --split-pages=3 input.pdf output_%02d.pdf

# Extract complex page ranges
qpdf input.pdf --pages input.pdf 1,3-5,8,10-end -- extracted.pdf

# Merge from multiple sources
qpdf --empty --pages doc1.pdf 1-3 doc2.pdf 5-7 doc3.pdf 2,4 -- combined.pdf

# Optimize for web
qpdf --linearize input.pdf optimized.pdf

# Repair corrupted PDF
qpdf --check input.pdf
qpdf --fix-qdf damaged.pdf repaired.pdf

# Advanced encryption
qpdf --encrypt user_pass owner_pass 256 --print=none --modify=none -- input.pdf encrypted.pdf
```

## Advanced Python

### pdfplumber Advanced
```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    page = pdf.pages[0]

    # Extract text with coordinates
    chars = page.chars
    for char in chars[:10]:
        print(f"'{char['text']}' at x:{char['x0']:.1f} y:{char['y0']:.1f}")

    # Extract by bounding box
    bbox_text = page.within_bbox((100, 100, 400, 200)).extract_text()

    # Custom table settings
    table_settings = {
        "vertical_strategy": "lines",
        "horizontal_strategy": "lines",
        "snap_tolerance": 3
    }
    tables = page.extract_tables(table_settings)
```

### reportlab Tables
```python
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle
from reportlab.lib import colors

data = [
    ['Product', 'Q1', 'Q2', 'Q3', 'Q4'],
    ['Widgets', '120', '135', '142', '158'],
    ['Gadgets', '85', '92', '98', '105']
]

doc = SimpleDocTemplate("report.pdf")
table = Table(data)
table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
    ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
    ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
    ('GRID', (0, 0), (-1, -1), 1, colors.black)
]))

doc.build([table])
```

## Performance Tips

1. **Large PDFs**: Use streaming, process pages individually
2. **Text extraction**: `pdftotext` is fastest for plain text
3. **Image extraction**: `pdfimages` faster than page rendering
4. **Memory**: Process in chunks for very large documents

```python
def process_large_pdf(pdf_path, chunk_size=10):
    reader = PdfReader(pdf_path)
    total_pages = len(reader.pages)

    for start_idx in range(0, total_pages, chunk_size):
        end_idx = min(start_idx + chunk_size, total_pages)
        writer = PdfWriter()

        for i in range(start_idx, end_idx):
            writer.add_page(reader.pages[i])

        with open(f"chunk_{start_idx//chunk_size}.pdf", "wb") as output:
            writer.write(output)
```

## Troubleshooting

### Encrypted PDFs
```python
from pypdf import PdfReader

reader = PdfReader("encrypted.pdf")
if reader.is_encrypted:
    reader.decrypt("password")
```

### Corrupted PDFs
```bash
qpdf --check corrupted.pdf
qpdf --replace-input corrupted.pdf
```

### OCR Fallback
```python
import pytesseract
from pdf2image import convert_from_path

def extract_text_with_ocr(pdf_path):
    images = convert_from_path(pdf_path)
    return "".join(pytesseract.image_to_string(img) for img in images)
```

## License Summary

| Library | License |
|---------|---------|
| pypdf | BSD |
| pdfplumber | MIT |
| pypdfium2 | Apache/BSD |
| reportlab | BSD |
| poppler-utils | GPL-2 |
| qpdf | Apache |
| pdf-lib | MIT |
| pdfjs-dist | Apache |
