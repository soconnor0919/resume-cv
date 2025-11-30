# Resume & CV Generator

A LaTeX-based resume and CV generator with automated builds for both public and private versions. This repository serves two purposes:
1. An actively maintained resume/CV using modern CI/CD practices
2. A template that anyone can fork and customize for their own use

## Overview

This project demonstrates professional DevOps practices while providing a beautiful LaTeX resume:
- Automated builds via GitHub Actions for continuous deployment
- Secure handling of sensitive information through environment variables
- Containerized local development with Docker
- Clean separation of content and styling

## Latest PDFs

The most recent public versions are always available at:
- Resume: `https://github.com/soconnor0919/resume-cv/releases/download/latest/resume.pdf`
- CV: `https://github.com/soconnor0919/resume-cv/releases/download/latest/cv.pdf`

If mirroring to Gitea:
- Resume: `https://git.soconnor.dev/soconnor/resume-cv/releases/download/latest/resume.pdf`
- CV: `https://git.soconnor.dev/soconnor/resume-cv/releases/download/latest/cv.pdf`

Replace `USERNAME` with your GitHub username after forking.

## Project Structure

```
.
├── cv.tex              # Extended CV template
├── resume.tex          # Resume template (subset of CV)
├── shared/             # Shared components
│   ├── style/          # Common LaTeX styles
│   │   └── common.tex  # Shared style definitions
│   └── sections/       # Shared content sections
│       ├── header.tex  # Contact information
│       ├── education.tex
│       ├── skills.tex
│       ├── coursework.tex
│       └── publications.tex
├── .secrets            # Personal information (git-ignored)
├── build-local.sh      # Local build script
├── build-docker.sh     # Docker build script
├── generate-standalone-cv.sh # Generate standalone CV PDF
└── subfiles/
    └── refs.bib        # BibTeX references
```

## Using as a Template

1. Fork this repository
2. Copy `.secrets-template` to `.secrets` and fill in your personal information
3. Run `./build-local.sh` to generate both public and private versions
   - Public version omits sensitive information like phone and address
   - Private version includes all personal details from `.secrets`
   - The script automatically generates and cleans up temporary files

## Modifying Content

The project uses a modular structure to avoid duplication:
- Common sections are stored in `shared/sections/`
- Styling is defined in `shared/style/common.tex`
- The resume is a subset of the CV, reusing shared components
- Add new sections by creating files in `shared/sections/` and including them with `\input{}`

## CI/CD Pipeline

The repository showcases modern DevOps practices through GitHub Actions:
- Automated PDF generation on every push
- Public version published as GitHub release with stable URLs
- Private version securely generated for repository owner
- Environment variables managed through GitHub Secrets

You can see these practices in action by checking the [Actions tab](../../actions) and [Releases](../../releases).

## License

This template is available under the MIT License. Feel free to fork and customize it for your own needs. 