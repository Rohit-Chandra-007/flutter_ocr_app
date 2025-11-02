# Document Scanner Crash Debugging Guide

## Changes Made

I've added comprehensive logging throughout the document scanner flow using the `logger` package. This will help us identify exactly where the crash is occurring.

## Logging Added To:

1. **OCRService** (`lib/core/services/ocr_service.dart`)
   - Text extraction start/completion
   - Image processing for each page
   - Error handling with stack traces

2. **DocumentProcessor** (`lib/features/document_scanner/viewmodels/document_processor_provider.dart`)
   - Image path validation
   - OCR processing start/completion
   - Document creation and database saving
   - PDF processing with detailed steps
   - All error points with stack traces

3. **CameraScannerScreen** (`lib/features/document_scanner/views/screens/camera_scanner_screen.dart`)
   - Camera initialization
   - Photo capture
   - Document processing flow
   - Dialog management

4. **PDFService** (`lib/core/services/pdf_service.dart`)
   - PDF opening and page count
   - Each page rendering
   - Image writing to temp files
   - OCR processing per page

5. **ScanOptionsGrid** (`lib/features/document_scanner/views/widgets/scan_options_grid.dart`)
   - Scan option selection
   - Processing dialog management
   - Success/error handling

6. **ScanHistory Provider** (`lib/features/home/viewmodels/scan_history_provider.dart`)
   - Document addition to history
   - Provider invalidation

7. **DatabaseService** (`lib/core/services/database_service.dart`)
   - Isar database operations
   - Write transactions
   - Document saving with IDs

## How to Debug

### Step 1: Run the App with Logging
```bash
flutter run
```

### Step 2: Try to Scan a Document
1. Open the app
2. Click on "Scan Document"
3. Choose any scan method (Camera, Gallery, PDF, etc.)
4. Try to scan/process a document

### Step 3: Watch the Logs
The logs will show exactly where the process breaks. Look for:
- **Last successful log** - This shows what worked
- **Error logs** - These will have `[E]` prefix and show stack traces
- **Missing logs** - If a step doesn't log, that's where it crashed

### Log Prefixes:
- `[I]` - Info: Normal flow
- `[D]` - Debug: Detailed steps
- `[W]` - Warning: Potential issues
- `[E]` - Error: Crashes with stack traces

### Example Log Flow (Camera Scan):
```
[I] ScanOptions: Scan option selected: camera
[I] ScanOptions: Navigating to camera screen
[I] CameraScreen: Initializing camera scanner
[I] CameraScreen: Capture button pressed
[D] CameraScreen: Capturing photo
[I] CameraScreen: Photo captured: /path/to/image.jpg
[D] CameraScreen: Showing processing dialog
[D] CameraScreen: Starting document processing
[I] DocProcessor: Processing camera image: /path/to/image.jpg
[I] DocProcessor: _processImages called with 1 paths
[D] DocProcessor: Starting OCR processing
[I] OCR: Processing 1 images
[D] OCR: Creating page 1 for path: /path/to/image.jpg
[D] OCR: Page 1 created successfully
[D] OCR: Starting text extraction for page 1
[I] OCR: Starting text extraction for: /path/to/image.jpg
[D] OCR: InputImage created successfully
[I] OCR: Text extraction completed. Length: 123
[D] OCR: Text extracted for page 1, length: 123
[D] OCR: Page 1 updated with OCR text
[I] OCR: Page 1 processed successfully
[I] OCR: Completed processing all images. Total pages: 1
[I] DocProcessor: OCR processing completed. Pages created: 1
[D] DocProcessor: Generating document title
[D] DocProcessor: Document title: Sample Text...
[D] DocProcessor: Creating ScanDocument
[I] DocProcessor: ScanDocument created with ID: 1
[D] DocProcessor: Saving document to database
[I] DocProcessor: Document saved successfully
[I] DocProcessor: Camera image processed successfully: true
[I] CameraScreen: Document processing result: true
[D] CameraScreen: Closing processing dialog
[I] CameraScreen: Document scanned successfully
```

## What to Look For

### If crash happens during OCR:
Look for logs like:
```
[I] OCR: Starting text extraction for: /path/to/image.jpg
[E] OCR: Error extracting text from image
```
This means the ML Kit text recognizer is failing.

### If crash happens during database save:
Look for logs like:
```
[D] DocProcessor: Saving document to database
[E] DocProcessor: Error processing images
```
This means the Isar database operation is failing.

### If crash happens during image capture:
Look for logs like:
```
[D] CameraScreen: Capturing photo
[E] CameraScreen: Failed to capture photo - null or empty path
```
This means the camera controller is not working properly.

## Next Steps

1. **Run the app** and try to scan a document
2. **Copy the complete log output** from the console
3. **Share the logs** - Look for the last successful log and the first error
4. **Identify the crash point** - The logs will show exactly which line is failing

The logs will tell us:
- Is it an OCR issue?
- Is it a database issue?
- Is it a camera issue?
- Is it a file system issue?
- Is it a memory issue?

Once we see the logs, we can fix the exact problem!
