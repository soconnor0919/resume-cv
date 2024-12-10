#!/bin/bash

# Source secrets if the file exists
if [ -f .secrets ]; then
    source .secrets
else
    echo "Warning: .secrets file not found. Building public version only."
    PERSONAL_PHONE=""
    PERSONAL_HOME_ADDRESS_LINE1=""
    PERSONAL_HOME_ADDRESS_LINE2=""
    PERSONAL_SCHOOL_ADDRESS_LINE1=""
    PERSONAL_SCHOOL_ADDRESS_LINE2=""
    PERSONAL_SCHOOL_ADDRESS_LINE3=""
fi

# Function to cleanup
cleanup() {
    # Clean up LaTeX artifacts
    rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz *.bbl *.blg *.pdf
    # Only restore backup if it exists
    if [ -f personal_info.tex.bak ]; then
        mv personal_info.tex.bak personal_info.tex
    fi
}

# Ensure cleanup runs even if script fails
trap cleanup EXIT

# Create output directory
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
\\newcommand{\\personalName}{Sean O'Connor}
\\newcommand{\\personalEmail}{sean@soconnor.dev}
\\newcommand{\\personalPhone}{${PERSONAL_PHONE}}
\\newcommand{\\personalWebsite}{soconnor.dev}
\\newcommand{\\personalSchoolEmail}{sso005@bucknell.edu}
\\newcommand{\\personalHomeAddressLineOne}{${PERSONAL_HOME_ADDRESS_LINE1}}
\\newcommand{\\personalHomeAddressLineTwo}{${PERSONAL_HOME_ADDRESS_LINE2}}
\\newcommand{\\personalSchoolAddressLineOne}{${PERSONAL_SCHOOL_ADDRESS_LINE1}}
\\newcommand{\\personalSchoolAddressLineTwo}{${PERSONAL_SCHOOL_ADDRESS_LINE2}}
\\newcommand{\\personalSchoolAddressLineThree}{${PERSONAL_SCHOOL_ADDRESS_LINE3}}
EOL

    docker build --platform linux/arm64 -t resume-builder .
    docker run --platform linux/arm64 --rm \
        -v "$(pwd):/workspace" \
        -v "$(pwd)/output:/workspace/output" \
        resume-builder bash -c "latexmk -pdf -file-line-error -halt-on-error -interaction=nonstopmode resume.tex cv.tex && mv *.pdf output/"

    # Move files to final names
    mv output/resume.pdf output/resume-private.pdf 2>/dev/null || true
    mv output/cv.pdf output/cv-private.pdf 2>/dev/null || true
fi

# Build public version
echo "Building public version..."
cat > personal_info.tex << EOL
% Public version of personal information
\\newcommand{\\personalName}{Sean O'Connor}
\\newcommand{\\personalEmail}{sean@soconnor.dev}
\\newcommand{\\personalPhone}{}
\\newcommand{\\personalWebsite}{soconnor.dev}
\\newcommand{\\personalSchoolEmail}{sso005@bucknell.edu}
\\newcommand{\\personalHomeAddressLineOne}{}
\\newcommand{\\personalHomeAddressLineTwo}{}
\\newcommand{\\personalSchoolAddressLineOne}{}
\\newcommand{\\personalSchoolAddressLineTwo}{}
\\newcommand{\\personalSchoolAddressLineThree}{}
EOL

docker run --platform linux/arm64 --rm \
    -v "$(pwd):/workspace" \
    -v "$(pwd)/output:/workspace/output" \
    resume-builder bash -c "latexmk -pdf -file-line-error -halt-on-error -interaction=nonstopmode resume.tex cv.tex && mv *.pdf output/"

# Move files to final names
mv output/resume.pdf output/resume-public.pdf 2>/dev/null || true
mv output/cv.pdf output/cv-public.pdf 2>/dev/null || true

echo "Build complete!"
echo "Generated files in output/:"
ls -l output/ 