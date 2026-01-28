# PDF Form Filling Guide

## Two Paths for Form Filling

### Path 1: Fillable Form Fields

If the PDF contains interactive form fields:

1. **Check for fields**: Use `check_fillable_fields` to verify
2. **Extract field info**: Run `extract_form_field_info.py`
3. **Visual analysis**: Convert to PNG images, analyze to understand each field's purpose
4. **Create mapping**: Build `field_values.json` with field names and values
5. **Fill form**: Run `fill_fillable_fields.py` to generate completed PDF

### Path 2: Non-Fillable Fields (Annotations)

For static PDFs without interactive fields, follow these **mandatory steps**:

#### Step 1: Visual Analysis

Convert PDF to PNG images and identify all form fields, labels, and data entry areas. Determine bounding boxes for both label text and entry zones, ensuring they don't overlap.

```python
import pypdfium2 as pdfium

pdf = pdfium.PdfDocument("form.pdf")
for i, page in enumerate(pdf):
    bitmap = page.render(scale=2.0)
    img = bitmap.to_pil()
    img.save(f"page_{i+1}.png")
```

#### Step 2: Create fields.json

Document each field with:
- Page number
- Description
- Label bounding box
- Entry bounding box
- Text to insert

```json
{
  "fields": [
    {
      "page": 1,
      "description": "Full Name",
      "label_bbox": [50, 100, 150, 120],
      "entry_bbox": [160, 100, 400, 120],
      "value": "John Doe"
    }
  ]
}
```

Generate validation images using `create_validation_image.py`:
- Red rectangles for input areas
- Blue rectangles for labels

#### Step 3: Validate Bounding Boxes

1. Run `check_bounding_boxes.py` to verify boxes don't intersect
2. Visually inspect validation images:
   - Red rectangles should cover only input areas
   - Blue rectangles should contain label text
3. **Iterate until accurate** - this step is critical

#### Step 4: Add Annotations

Execute `fill_pdf_form_with_annotations.py` using your validated fields.json to create the final completed PDF with text annotations.

## Important Notes

- Complete steps sequentially
- Thoroughly validate bounding boxes before adding annotations
- Label and entry boxes must NOT overlap
- Test with actual PDF dimensions (1 point = 1/72 inch)

## Using pypdf for Basic Form Filling

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("form.pdf")
writer = PdfWriter()

# Clone pages
for page in reader.pages:
    writer.add_page(page)

# Fill form fields
writer.update_page_form_field_values(
    writer.pages[0],
    {
        "field_name": "value",
        "another_field": "another value"
    }
)

with open("filled.pdf", "wb") as output:
    writer.write(output)
```

## Using pdf-lib (JavaScript)

```javascript
import { PDFDocument } from 'pdf-lib';
import fs from 'fs';

async function fillForm() {
    const existingPdfBytes = fs.readFileSync('form.pdf');
    const pdfDoc = await PDFDocument.load(existingPdfBytes);

    const form = pdfDoc.getForm();

    // Get and fill text fields
    const nameField = form.getTextField('name');
    nameField.setText('John Doe');

    // Get and check checkboxes
    const checkbox = form.getCheckBox('agree');
    checkbox.check();

    // Get and select radio buttons
    const radio = form.getRadioGroup('gender');
    radio.select('male');

    // Get and select dropdown
    const dropdown = form.getDropdown('country');
    dropdown.select('USA');

    const pdfBytes = await pdfDoc.save();
    fs.writeFileSync('filled.pdf', pdfBytes);
}
```
