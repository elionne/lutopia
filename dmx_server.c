#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <poll.h>
#include <malloc.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "dmx_server.h"
#include "opendmx.h"

/* this functions provides an easy way to use dmx protocol */
int dmx_open(struct dmx_controler* dmx)
{return dmx->dmx_open(dmx->dh);}

int dmx_send(struct dmx_controler *dmx, unsigned char *data)
{return dmx->dmx_send(dmx->dh, data);}

int dmx_close(struct dmx_controler *dmx)
{return dmx->dmx_close(dmx->dh);}

int main(int argc, char* argv[])
{

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

    unsigned char dmx_data[513];
    int len = 0;

    dmx_open(dmx_drv[0]);
    do{

/* send data at full speed rate or wait until data incoming to send to dmx */
#if 1
        struct pollfd flush;
        flush.fd = s;
        flush.events = POLLIN;
        if( poll(&flush, 1, 0) > 0 )
#endif
        {
            int count = 0;
            /* flush the buffer, returns only the last packet sent */
            do{
                len = recv(s, dmx_data, sizeof(dmx_data), 0);
                count++;
            }while( poll(&flush, 1, 0) );

            if( len < sizeof(dmx_data) )
                printf("corrupted data receive\n");
#if 0
            if( count > 1 )
                printf("multiple data received %i\n", count);
#endif
        }
        dmx_data[0] = 0;

        len = dmx_send(dmx_drv[0], dmx_data);
        if( len != 513)
            printf("send %i bytes to dmx\r", len);


    }while( 1 );

    dmx_close(dmx_drv[0]);

    close(s);
    return EXIT_SUCCESS;
}
