#!/bin/bash

# Source secrets if the file exists
if [ -f .secrets ]; then
    source .secrets
else
    echo "Warning: .secrets file not found. Building public version only."
fi

# Set defaults for missing variables
PERSONAL_NAME=${PERSONAL_NAME:-$(whoami)}
PERSONAL_EMAIL=${PERSONAL_EMAIL:-""}
PERSONAL_WEBSITE=${PERSONAL_WEBSITE:-""}
PERSONAL_SCHOOL_EMAIL=${PERSONAL_SCHOOL_EMAIL:-""}
PERSONAL_PHONE=${PERSONAL_PHONE:-""}
PERSONAL_HOME_ADDRESS_LINE1=${PERSONAL_HOME_ADDRESS_LINE1:-""}
PERSONAL_HOME_ADDRESS_LINE2=${PERSONAL_HOME_ADDRESS_LINE2:-""}
PERSONAL_SCHOOL_ADDRESS_LINE1=${PERSONAL_SCHOOL_ADDRESS_LINE1:-""}
PERSONAL_SCHOOL_ADDRESS_LINE2=${PERSONAL_SCHOOL_ADDRESS_LINE2:-""}
PERSONAL_SCHOOL_ADDRESS_LINE3=${PERSONAL_SCHOOL_ADDRESS_LINE3:-""}

# Function to cleanup
cleanup() {
    rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz *.bbl *.blg
    if [ -f personal_info.tex.bak ]; then
        mv personal_info.tex.bak personal_info.tex
    fi
}

trap cleanup EXIT
mkdir -p output

# Backup current personal_info.tex if it exists
if [ -f personal_info.tex ]; then
    cp personal_info.tex personal_info.tex.bak
fi

# Build private version (if secrets are available)
if [ -n "$PERSONAL_PHONE" ] || [ -n "$PERSONAL_HOME_ADDRESS_LINE1" ] || [ -n "$PERSONAL_SCHOOL_ADDRESS_LINE1" ]; then
    echo "Building private version..."
    cat > personal_info.tex << EOL
% Private version of personal information
\newcommand{\personalName}{$PERSONAL_NAME}
\newcommand{\personalEmail}{$PERSONAL_EMAIL}
\newcommand{\personalPhone}{$PERSONAL_PHONE}
\newcommand{\personalWebsite}{$PERSONAL_WEBSITE}
\newcommand{\personalSchoolEmail}{$PERSONAL_SCHOOL_EMAIL}
\newcommand{\personalHomeAddressLineOne}{$PERSONAL_HOME_ADDRESS_LINE1}
\newcommand{\personalHomeAddressLineTwo}{$PERSONAL_HOME_ADDRESS_LINE2}
\newcommand{\personalSchoolAddressLineOne}{$PERSONAL_SCHOOL_ADDRESS_LINE1}
\newcommand{\personalSchoolAddressLineTwo}{$PERSONAL_SCHOOL_ADDRESS_LINE2}
\newcommand{\personalSchoolAddressLineThree}{$PERSONAL_SCHOOL_ADDRESS_LINE3}
EOL

    docker build --platform linux/arm64 -t resume-builder .
    docker run --platform linux/arm64 --rm \
        -v "$(pwd):/workspace" \
        -v "$(pwd)/output:/workspace/output" \
        resume-builder bash -c "latexmk -pdf -file-line-error -halt-on-error -interaction=nonstopmode resume.tex cv.tex && mv *.pdf output/"

    mv output/resume.pdf output/resume-private.pdf 2>/dev/null || true
    mv output/cv.pdf output/cv-private.pdf 2>/dev/null || true
fi

# Build public version
echo "Building public version..."
cat > personal_info.tex << EOL
% Public version of personal information
\newcommand{\personalName}{$PERSONAL_NAME}
\newcommand{\personalEmail}{$PERSONAL_EMAIL}
\newcommand{\personalPhone}{~}
\newcommand{\personalWebsite}{$PERSONAL_WEBSITE}
\newcommand{\personalSchoolEmail}{$PERSONAL_SCHOOL_EMAIL}
\newcommand{\personalHomeAddressLineOne}{~}
\newcommand{\personalHomeAddressLineTwo}{~}
\newcommand{\personalSchoolAddressLineOne}{~}
\newcommand{\personalSchoolAddressLineTwo}{~}
\newcommand{\personalSchoolAddressLineThree}{~}
EOL

docker run --platform linux/arm64 --rm \
    -v "$(pwd):/workspace" \
    -v "$(pwd)/output:/workspace/output" \
    resume-builder bash -c "latexmk -pdf -file-line-error -halt-on-error -interaction=nonstopmode resume.tex cv.tex && mv resume.pdf output/resume-public.pdf && mv cv.pdf output/cv-public.pdf"

echo "Build complete!"
echo "Generated files in output/:"
ls -l output/ 