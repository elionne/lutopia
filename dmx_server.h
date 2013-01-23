#ifndef _DMX_SERVER_H_
#define _DMX_SERVER_H_

typedef void* dmx_handler;

typedef int (*dmx_function)(dmx_handler);
typedef dmx_handler (*dmx_open_function)(unsigned char*);
typedef int (*dmx_send_function)(dmx_handler, unsigned char*);


struct dmx_controler
{
    const char *name;
    dmx_open_function dmx_open;
    dmx_send_function dmx_send;
    dmx_function dmx_close;
};

extern struct dmx_controler *dmx_drv_list[];

#ifdef DMX_DRV_DEF
#define DMX_DRV_REGISTER(drv) int main() {\
  puts("_(dmx_drv_" #drv ")"); return 0;\
}
#else
#define DMX_DRV_REGISTER(drv) struct dmx_controler dmx_drv_ ## drv = {\
  #drv,\
  (dmx_open_function) drv ## _open,\
  (dmx_send_function) drv ## _send,\
  (dmx_function) drv ## _close\
};
#endif

#endif
typedef int (*dmx_function)(dmx_handler);
