FROM ubuntu:24.04

# Prevent tzdata questions during install
ENV DEBIAN_FRONTEND=noninteractive

# Install TeX Live and required packages
RUN apt-get update && apt-get install -y \
    texlive-full \
    latexmk \
    make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Default command runs make
CMD ["make", "all"]