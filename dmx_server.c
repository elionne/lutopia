#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <malloc.h>

#include <sys/socket.h>
#include <sys/time.h>
#include <sys/types.h>

#include <netinet/in.h>
#include <arpa/inet.h>

#include "dmx_server.h"

/* this functions provides an easy way to use dmx protocol */
dmx_handler dmx_open(struct dmx_controler* dmx, unsigned char* name)
{return dmx->dmx_open(name);}

int dmx_send(struct dmx_controler *dmx, dmx_handler handler, unsigned char *data)
{return dmx->dmx_send(handler, data);}

int dmx_close(struct dmx_controler *dmx, dmx_handler handler)
{return dmx->dmx_close(handler);}

int main(int argc, char* argv[])
{
    dmx_handler h;
    int s = socket(AF_INET, SOCK_DGRAM, 0);
    if(s <= 0 ){
        printf("Error while opening socket, abort. %s\n", strerror(errno));
        return EXIT_FAILURE;
    }

    struct sockaddr_in in;

    in.sin_addr.s_addr = INADDR_ANY;
    in.sin_port = htons(21812);
    in.sin_family = AF_INET;

    if( bind(s, (struct sockaddr*)&in, sizeof(in)) < 0 ){
        printf("Could not bind the socket. %s\n", strerror(errno));
        return EXIT_FAILURE;
    }


    h = dmx_open(dmx_drv_list[0], 0);
    if(!h)
      return EXIT_FAILURE;

    do{
        exec(s, h);
    }while(1);

    dmx_close(dmx_drv_list[0], h);
    close(s);
    return EXIT_SUCCESS;
}

int exec(int s, dmx_handler h)
{
    unsigned char dmx_data[513];
    int len = 0;
/* send data at full speed rate or wait until data incoming to send to dmx */
    fd_set fd;
    FD_ZERO(&fd);
    FD_SET(s, &fd);

    struct timeval timeout = { 0, 24e3 };
    if( select(s+1, &fd, 0, 0, &timeout) > 0 )
    {
        /* flush the buffer, returns only the last packet sent */
        int count = 0;
        struct timeval flush = { 0, 0};
        FD_ZERO(&fd);
        FD_SET(s, &fd);
        do{
            len = recv(s, dmx_data, sizeof(dmx_data), 0);
            count++;
        }while( select(s+1, &fd, 0, 0, &flush ) > 0 );

        if( len < sizeof(dmx_data) )
            printf("corrupted data receive\n");
#if 1
        if( count > 1 )
            printf("multiple data received %i\n", count);
#endif
    }
    dmx_data[0] = 0;

    len = dmx_send(dmx_drv_list[0], h, dmx_data);
    if( len != 513)
        printf("send %i bytes to dmx\r", len);

    return 0;
}
