FROM ubuntu:24.04

# Prevent tzdata questions during install
ENV DEBIAN_FRONTEND=noninteractive

# Install TeX Live and required packages
RUN apt-get update && apt-get install -y \
    texlive-full \
    latexmk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY . .

# For build
CMD ["latexmk", "-pdf", "-file-line-error", "-halt-on-error", "-interaction=nonstopmode", "resume.tex", "cv.tex"]