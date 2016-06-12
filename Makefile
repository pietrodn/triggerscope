TARGET = slide.pdf
OUT_FORMAT = beamer
IN_FORMAT = markdown
HEADER = header.tex
META = metadata.yaml
SOURCES = slide.md bibliography.tex

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(META) $(SOURCES) $(HEADER)
	pandoc --include-in-header=$(HEADER) \
		--from=$(IN_FORMAT) \
		--to=$(OUT_FORMAT) \
		--standalone \
		--output=$(TARGET) \
		$(META) $(SOURCES)

clean:
	-@rm -f $(TARGET)
