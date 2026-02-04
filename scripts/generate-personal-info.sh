#!/bin/bash
# Helper script to generate personal_info.tex files
# Usage: ./generate-personal-info.sh [public|private]

VERSION=$1
BUILD_DIR=${BUILD_DIR:-build}

# Create build directory if it doesn't exist
mkdir -p "$BUILD_DIR"

# Source secrets if available
if [ -f .secrets ]; then
    source .secrets
else
    PERSONAL_NAME=$(whoami)
    PERSONAL_EMAIL=""
    PERSONAL_WEBSITE=""
    PERSONAL_SCHOOL_EMAIL=""
    PERSONAL_PHONE=""
    PERSONAL_HOME_ADDRESS_LINE1=""
    PERSONAL_HOME_ADDRESS_LINE2=""
    PERSONAL_SCHOOL_ADDRESS_LINE1=""
    PERSONAL_SCHOOL_ADDRESS_LINE2=""
    PERSONAL_SCHOOL_ADDRESS_LINE3=""
fi

if [ "$VERSION" = "public" ]; then
    cat > "$BUILD_DIR/personal_info.tex" <<EOL
% Public version of personal information
\\newcommand{\\personalName}{$PERSONAL_NAME}
\\newcommand{\\personalEmail}{$PERSONAL_EMAIL}
\\newcommand{\\personalPhone}{~}
\\newcommand{\\personalWebsite}{$PERSONAL_WEBSITE}
\\newcommand{\\personalSchoolEmail}{$PERSONAL_SCHOOL_EMAIL}
\\newcommand{\\personalHomeAddressLineOne}{~}
\\newcommand{\\personalHomeAddressLineTwo}{~}
\\newcommand{\\personalSchoolAddressLineOne}{~}
\\newcommand{\\personalSchoolAddressLineTwo}{~}
\\newcommand{\\personalSchoolAddressLineThree}{~}
EOL
else
    cat > "$BUILD_DIR/personal_info.tex" <<EOL
% Private version of personal information
\\newcommand{\\personalName}{$PERSONAL_NAME}
\\newcommand{\\personalEmail}{$PERSONAL_EMAIL}
\\newcommand{\\personalPhone}{$PERSONAL_PHONE}
\\newcommand{\\personalWebsite}{$PERSONAL_WEBSITE}
\\newcommand{\\personalSchoolEmail}{$PERSONAL_SCHOOL_EMAIL}
\\newcommand{\\personalHomeAddressLineOne}{$PERSONAL_HOME_ADDRESS_LINE1}
\\newcommand{\\personalHomeAddressLineTwo}{$PERSONAL_HOME_ADDRESS_LINE2}
\\newcommand{\\personalSchoolAddressLineOne}{$PERSONAL_SCHOOL_ADDRESS_LINE1}
\\newcommand{\\personalSchoolAddressLineTwo}{$PERSONAL_SCHOOL_ADDRESS_LINE2}
\\newcommand{\\personalSchoolAddressLineThree}{$PERSONAL_SCHOOL_ADDRESS_LINE3}
EOL
fi
