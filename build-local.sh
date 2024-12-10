#!/bin/bash

# Function to cleanup
cleanup() {
    rm -f personal_info.tex.bak
}

# Ensure cleanup runs even if script fails
trap cleanup EXIT

# Create output directory
mkdir -p output

# Build public version
echo "Building public version..."
docker build --platform linux/arm64 -t resume-builder .
docker run --platform linux/arm64 --rm -v "$(pwd)/output:/workspace/output" resume-builder bash -c "latexmk -pdf -file-line-error -halt-on-error -interaction=nonstopmode resume.tex cv.tex && cp *.pdf output/"

# Move files to final names
mv output/resume.pdf output/resume-public.pdf
mv output/cv.pdf output/cv-public.pdf

# Build private version
echo "Building private version..."
# Backup current personal_info.tex
cp personal_info.tex personal_info.tex.bak

# Create private info file
cat > personal_info.tex << EOL
% Private version of personal information
\\newcommand{\\personalName}{Sean O'Connor}
\\newcommand{\\personalEmail}{${PERSONAL_EMAIL:-}}
\\newcommand{\\personalPhone}{${PERSONAL_PHONE:-}}
\\newcommand{\\personalWebsite}{soconnor.dev}
\\newcommand{\\personalSchoolEmail}{${PERSONAL_SCHOOL_EMAIL:-}}
\\newcommand{\\personalHomeAddress}{${PERSONAL_HOME_ADDRESS:-}}
\\newcommand{\\personalSchoolAddress}{${PERSONAL_SCHOOL_ADDRESS:-}}
EOL

# Build private version using the same image
docker run --platform linux/arm64 --rm -v "$(pwd):/workspace" -v "$(pwd)/output:/workspace/output" resume-builder bash -c "latexmk -pdf -file-line-error -halt-on-error -interaction=nonstopmode resume.tex cv.tex && cp *.pdf output/"

# Move files to final names
mv output/resume.pdf output/resume-private.pdf
mv output/cv.pdf output/cv-private.pdf

# Restore original personal_info.tex
mv personal_info.tex.bak personal_info.tex

echo "Build complete!"
echo "Generated files in output/:"
echo "- resume-public.pdf"
echo "- cv-public.pdf"
echo "- resume-private.pdf"
echo "- cv-private.pdf" 