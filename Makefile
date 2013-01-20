all: lutopia dmx_server

lutopia: vt_lua.o
	gcc -o lutopia vt_lua.o -llua #-lusb-1.0

vt_lua.o: vt_lua.c
	gcc -g -Wall -c -o vt_lua.o vt_lua.c

dmx_server: dmx_server.o opendmx.o
	gcc -o dmx_server dmx_server.o opendmx.o -lftdi
dmx_server.o:
	gcc -g -Wall -c -o dmx_server.o dmx_server.c

cuecable.o: cuecable.c cuecable.h
	gcc -g -Wall -c -o cuecable.o cuecable.c
opendmx.o: opendmx.c opendmx.h
	gcc -g -Wall -c -o opendmx.o opendmx.c

clean:
	rm *.o
	rm lutopia dmx_server