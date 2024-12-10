# LaTeX Resume and CV Template

This repository contains a LaTeX template for creating both a resume and an extended CV. The template is designed to handle both public and private versions of your documents, making it perfect for sharing on GitHub while keeping sensitive information private.

## Features

- Clean, professional LaTeX template for both resume and CV
- Handles sensitive information securely using GitHub Secrets
- Automated PDF generation using GitHub Actions
- BibTeX integration for publications
- Public and private versions of documents

## Setup

1. Fork this repository
2. For public use:
   - The default `personal_info.tex` will be used with placeholder information
   - Customize by editing `personal_info.tex` with your public information
3. For private use:
   - Copy `personal_info_template.tex` to `personal_info_private.tex`
   - Fill in your private information in `personal_info_private.tex`
   - Add your sensitive information as GitHub Secrets (see below)

## GitHub Secrets

To handle sensitive information in GitHub Actions, add these secrets to your repository:
- `PERSONAL_EMAIL`: Your primary email address
- `PERSONAL_PHONE`: Your phone number
- `PERSONAL_SCHOOL_EMAIL`: Your school email address
- `PERSONAL_HOME_ADDRESS`: Your home address (multi-line)
- `PERSONAL_SCHOOL_ADDRESS`: Your school address (multi-line)

## Local Development

1. Clone the repository
2. For public version:
   - Use the existing `personal_info.tex`
3. For private version:
   - Create `personal_info_private.tex` from the template
   - Add your private information
4. Compile using:
   ```bash
   # For initial compilation
   pdflatex document.tex
   
   # If you have bibliography
   bibtex document
   
   # Run twice more for references
   pdflatex document.tex
   pdflatex document.tex
   ```
   Replace `document.tex` with either `cv.tex` or `resume.tex`

## GitHub Actions

The workflow automatically:
- Builds public versions of both resume and CV on every push
- Creates private versions if you're the repository owner
- Uploads both versions as artifacts

## Directory Structure

```
.
├── cv.tex              # Extended CV template
├── resume.tex          # Resume template
├── personal_info.tex   # Public information (committed)
├── personal_info_template.tex  # Template for private info
├── personal_info_private.tex   # Private information (git-ignored)
└── subfiles/
    └── refs.bib       # BibTeX references
```

## License

This template is available under the MIT License. Feel free to use and modify it for your own needs. 