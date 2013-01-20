/* Instance for the Open DMX standard cable */
void opendmx_new(struct dmx_controler *controler){
    controler->dmx_init  = (dmx_function)opendmx_init;
    controler->dmx_open  = (dmx_function)opendmx_open;
    controler->dmx_send  = (dmx_send_function)opendmx_send;
    controler->dmx_close = (dmx_function)opendmx_close;

    controler->dh = (struct ftdi_context*)malloc(sizeof(struct ftdi_context));
}

void opendmx_delete(struct dmx_controler *dmx)
{
    free(dmx->dh);
}


