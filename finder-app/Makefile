# Compiler prefix (e.g., aarch64-none-linux-gnu- for cross-compilation)
CC := $(CROSS_COMPILE)gcc
CFLAGS := -Wall -Werror
TARGET := writer
SRC := writer.c
OBJ := $(SRC:.c=.o)

.PHONY: all clean

# Default target: build the writer application
all: $(TARGET)

# Rule to build the binary
$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

# Clean target: remove binary and object files
clean:
	rm -f $(TARGET) $(OBJ)
