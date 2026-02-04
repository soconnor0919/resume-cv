# Resume & CV Makefile
# Builds both public and private versions of resume and CV

# Variables
LATEX = latexmk -pdf -file-line-error -halt-on-error -interaction=nonstopmode
DOCKER_IMAGE = resume-builder
OUTPUT_DIR = output
BUILD_DIR = build
SCRIPTS_DIR = scripts

# Export BUILD_DIR for scripts
export BUILD_DIR

# Targets
.PHONY: all clean docker-build docker public private resume cv help

all: public private

help:
	@echo "Resume & CV Build System"
	@echo ""
	@echo "Targets:"
	@echo "  make all        - Build both public and private versions (default)"
	@echo "  make public     - Build public versions only"
	@echo "  make private    - Build private versions only"
	@echo "  make resume     - Build resume only (both versions)"
	@echo "  make cv         - Build CV only (both versions)"
	@echo "  make docker     - Build using Docker (if LaTeX not installed)"
	@echo "  make clean      - Remove build artifacts"
	@echo ""
	@echo "Files will be generated in $(OUTPUT_DIR)/"
	@echo "Build artifacts will be in $(BUILD_DIR)/"

# Create directories
$(OUTPUT_DIR):
	@mkdir -p $(OUTPUT_DIR)

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Build public versions
public: $(OUTPUT_DIR) $(BUILD_DIR)
	@echo "Building public versions..."
	@$(SCRIPTS_DIR)/generate-personal-info.sh public
	@TEXINPUTS=".:$(BUILD_DIR):" $(LATEX) -output-directory=$(BUILD_DIR) resume.tex
	@TEXINPUTS=".:$(BUILD_DIR):" $(LATEX) -output-directory=$(BUILD_DIR) cv.tex
	@cp $(BUILD_DIR)/resume.pdf $(OUTPUT_DIR)/resume-public.pdf
	@cp $(BUILD_DIR)/cv.pdf $(OUTPUT_DIR)/cv-public.pdf
	@echo "Public versions built successfully!"

# Build private versions
private: $(OUTPUT_DIR) $(BUILD_DIR)
	@echo "Building private versions..."
	@$(SCRIPTS_DIR)/generate-personal-info.sh private
	@TEXINPUTS=".:$(BUILD_DIR):" $(LATEX) -output-directory=$(BUILD_DIR) resume.tex
	@TEXINPUTS=".:$(BUILD_DIR):" $(LATEX) -output-directory=$(BUILD_DIR) cv.tex
	@cp $(BUILD_DIR)/resume.pdf $(OUTPUT_DIR)/resume-private.pdf
	@cp $(BUILD_DIR)/cv.pdf $(OUTPUT_DIR)/cv-private.pdf
	@echo "Private versions built successfully!"

# Build resume only
resume: $(OUTPUT_DIR) $(BUILD_DIR)
	@echo "Building resume..."
	@$(SCRIPTS_DIR)/generate-personal-info.sh public
	@TEXINPUTS=".:$(BUILD_DIR):" $(LATEX) -output-directory=$(BUILD_DIR) resume.tex
	@cp $(BUILD_DIR)/resume.pdf $(OUTPUT_DIR)/resume-public.pdf
	@$(SCRIPTS_DIR)/generate-personal-info.sh private
	@TEXINPUTS=".:$(BUILD_DIR):" $(LATEX) -output-directory=$(BUILD_DIR) resume.tex
	@cp $(BUILD_DIR)/resume.pdf $(OUTPUT_DIR)/resume-private.pdf
	@echo "Resume built successfully!"

# Build CV only
cv: $(OUTPUT_DIR) $(BUILD_DIR)
	@echo "Building CV..."
	@$(SCRIPTS_DIR)/generate-personal-info.sh public
	@TEXINPUTS=".:$(BUILD_DIR):" $(LATEX) -output-directory=$(BUILD_DIR) cv.tex
	@cp $(BUILD_DIR)/cv.pdf $(OUTPUT_DIR)/cv-public.pdf
	@$(SCRIPTS_DIR)/generate-personal-info.sh private
	@TEXINPUTS=".:$(BUILD_DIR):" $(LATEX) -output-directory=$(BUILD_DIR) cv.tex
	@cp $(BUILD_DIR)/cv.pdf $(OUTPUT_DIR)/cv-private.pdf
	@echo "CV built successfully!"

# Docker build
docker-build:
	@docker build -t $(DOCKER_IMAGE) .

docker: docker-build
	@echo "Building with Docker..."
	@docker run --rm -v "$(PWD):/workspace" $(DOCKER_IMAGE)

# Clean build artifacts
clean:
	@rm -rf $(BUILD_DIR) $(OUTPUT_DIR)
	@echo "Cleaned all build artifacts"
