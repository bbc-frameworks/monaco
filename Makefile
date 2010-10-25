
LIBEV_VERSION=3.9
LIBEV_PATH=build/libev-$(LIBEV_VERSION)
INCPATH=-Iinclude -I$(LIBEV_PATH) -Iext/http-parser -I/opt/local/include
LIBPATH=-L$(LIBEV_PATH) -Lext/http-parser
CC_NO_WARN=gcc -pthread ${INCPATH} ${LIBPATH}
CC=gcc -Wall -pedantic -pthread ${INCPATH} ${LIBPATH}
OBJECT_FILES=build/monaco.o build/monaco_ev.o build/http_parser.o

monaco: ${OBJECT_FILES}
	${CC} -lm ${LIBRARIES} ${OBJECT_FILES} -o $@

ext/libev-$(LIBEV_VERSION).tar.gz:
	cd ext && curl http://dist.schmorp.de/libev/libev-$(LIBEV_VERSION).tar.gz > libev-$(LIBEV_VERSION).tar.gz

build:
	mkdir build

build/http_parser.o: ext/http-parser/http_parser.c ext/http-parser/http_parser.h
	${CC_NO_WARN} -c ext/http-parser/http_parser.c -o build/http_parser.o

build/monaco.o: build src/monaco.c $(LIBEV_PATH)/ev.h
	${CC} -c src/monaco.c -o build/monaco.o

build/monaco_ev.o: src/monaco_ev.c $(LIBEV_PATH)/ev.h $(LIBEV_PATH)/ev.c
	${CC_NO_WARN} -c src/monaco_ev.c -o build/monaco_ev.o

$(LIBEV_PATH)/ev.h: $(LIBEV_PATH)
$(LIBEV_PATH)/ev.c: $(LIBEV_PATH)

$(LIBEV_PATH): ext/libev-$(LIBEV_VERSION).tar.gz
	cd build && tar xozf ../ext/libev-$(LIBEV_VERSION).tar.gz

clean:
	rm -rf build monaco ext/libev-*.tar.gz
