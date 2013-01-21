CFLAGS = -g -Wall
LUTOPIA_OBJS = vt_lua.o
LUTOPIA_LIBS =  -llua #-lusb-1.0
DMX_SERVER_OBJS = dmx_server.o opendmx.o
DMX_SERVER_LIBS = -lftdi

all: lutopia dmx_server

lutopia: $(LUTOPIA_OBJS)
	$(CC) -o $@ $^ $(LUTOPIA_LIBS)

dmx_server: $(DMX_SERVER_OBJS)
	$(CC) -o $@ $^ $(DMX_SERVER_LIBS)

clean:
	rm -f $(LUTOPIA_OBJS) $(DMX_SERVER_OBJS) lutopia dmx_server

.PHONY: clean
