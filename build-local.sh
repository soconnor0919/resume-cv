#!/bin/bash

# Check if building specific CV variant
CV_VARIANT=""
if [ "$1" = "cv-upenn" ]; then
    CV_VARIANT="cv-upenn"
    echo "Building UPenn-optimized CV..."
fi

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
    rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz *.bbl *.blg personal_info.tex
    if [ -f personal_info.tex.bak ]; then
        mv personal_info.tex.bak personal_info.tex
    fi
}

trap cleanup EXIT
mkdir -p output

# Check if required LaTeX tools are available locally
check_latex_tools() {
    command -v latexmk >/dev/null 2>&1 || return 1
    command -v pdflatex >/dev/null 2>&1 || return 1
    return 0
}

# Function to build using local tools
build_local() {
    latexmk -pdf -file-line-error -halt-on-error -interaction=nonstopmode "$1"
}

# Function to build using Docker
build_docker() {
    echo "Local LaTeX tools not found, falling back to Docker..."
    ./build-docker.sh
    exit $?
}

# Backup current personal_info.tex if it exists
if [ -f personal_info.tex ]; then
    cp personal_info.tex personal_info.tex.bak
fi

# Check if we can use local tools, otherwise fall back to Docker
if ! check_latex_tools; then
    build_docker
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

    build_local resume.tex
    build_local cv.tex

    mv resume.pdf output/resume-private.pdf 2>/dev/null || true
    mv cv.pdf output/cv-private.pdf 2>/dev/null || true
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

# Build specific CV variant if requested
if [ "$CV_VARIANT" = "cv-upenn" ]; then
    build_local cv-upenn.tex
    mv cv-upenn.pdf output/cv-upenn.pdf
    echo "UPenn CV build complete! Generated: output/cv-upenn.pdf"
else
    build_local resume.tex
    build_local cv.tex

    mv resume.pdf output/resume-public.pdf
    mv cv.pdf output/cv-public.pdf

    echo "Build complete!"
    echo "Generated files in output/:"
    ls -l output/
fi
