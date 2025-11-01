CC = gcc
CFLAGS = -O2 -std=c11 -Wall -Wextra -pedantic-errors 
LIBS = -lm

TARGET = test
SRC = test.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET) $(LIBS)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET)

