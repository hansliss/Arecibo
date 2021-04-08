.SUFFIXES = .ihex .asm

AS = a18
FLAGS = 
DISTFILES = 

TARGET=Arecibo.ihex

all: $(TARGET)

install: all
	echo "No, you install!"
	cat $(TARGET)

%.ihex : %.asm
	$(AS) $(FLAGS) $< -o $@

clean:
	/bin/rm -f $(TARGET) *.lst
