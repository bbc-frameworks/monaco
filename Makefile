
LIBEV_VERSION=3.9
LIBEV_PATH=build/libev-$(LIBEV_VERSION)
INCPATH=-Iinclude -I$(LIBEV_PATH) -I/opt/local/include
LIBPATH=-L$(LIBEV_PATH)
CC_NO_WARN=gcc -pthread ${INCPATH} ${LIBPATH}
CC=gcc -Wall -pedantic -pthread ${INCPATH} ${LIBPATH}
OBJECT_FILES=build/monaco.o build/monaco_ev.o

monaco: ${OBJECT_FILES}
	${CC} -lm ${LIBRARIES} ${OBJECT_FILES} -o $@

build:
	mkdir build

build/monaco.o: build src/monaco.c $(LIBEV_PATH)/ev.h
	${CC} -c src/monaco.c -o build/monaco.o

build/monaco_ev.o: src/monaco_ev.c $(LIBEV_PATH)/ev.h $(LIBEV_PATH)/ev.c
	${CC_NO_WARN} -c src/monaco_ev.c -o build/monaco_ev.o

$(LIBEV_PATH)/ev.h: $(LIBEV_PATH)
$(LIBEV_PATH)/ev.c: $(LIBEV_PATH)

$(LIBEV_PATH): ext/libev-$(LIBEV_VERSION).tar.gz
	cd build && tar xozf ../ext/libev-$(LIBEV_VERSION).tar.gz

clean:
	rm -rf build monaco