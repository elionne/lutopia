#ifndef _DMX_SERVER_H_
#define _DMX_SERVER_H_

typedef void* dmx_handler;

typedef int (*dmx_function)(dmx_handler);
typedef int (*dmx_send_function)(dmx_handler, unsigned char*);


struct dmx_controler
{
    dmx_function dmx_open;
    dmx_function dmx_init;
    dmx_send_function dmx_send;
    dmx_function dmx_close;

    dmx_handler dh;
};

#endif
