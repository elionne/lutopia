CFLAGS = -g -Wall
LUTOPIA_OBJS = vt_lua.o
LUTOPIA_LIBS =  -llua #-lusb-1.0
DMX_DRV_SRCS = $(wildcard dmx_drv_*.c)
DMX_DRV_DEF = $(DMX_DRV_SRCS:.c=)
DMX_DRV_OBJS = $(DMX_DRV_SRCS:.c=.o)
DMX_SERVER_OBJS = dmx_server.o dmx_drv.o $(DMX_DRV_OBJS)
DMX_SERVER_LIBS = -lftdi

SRCS = $(wildcard $(SRC_DIR)/*/*.c)
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(BIN_DIR)/%.o)

all: lutopia dmx_server

dmx_drv_%: dmx_drv_%.c
	$(CC) -o $@ $(CFLAGS) -DDMX_DRV_DEF $(DMX_SERVER_LIBS) $<

lutopia: $(LUTOPIA_OBJS)
	$(CC) -o $@ $^ $(LUTOPIA_LIBS)

dmx_drv_list.h: $(DMX_DRV_DEF)
	for e in $^; do ./$$e; done > $@

dmx_drv.o: dmx_drv.c dmx_drv_list.h

dmx_server: $(DMX_SERVER_OBJS)
	$(CC) -o $@ $^ $(DMX_SERVER_LIBS)

clean:
	rm -f $(LUTOPIA_OBJS) $(DMX_SERVER_OBJS) $(DMX_DRV_DEF) dmx_drv_list.h lutopia dmx_server

.PHONY: clean
