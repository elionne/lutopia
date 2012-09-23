#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

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
    do{
        len = recv(s, dmx_data, sizeof(dmx_data), 0);

        if( len < sizeof(dmx_data) )
            printf("corrupted data receive\n");
        printf("received %i bytes\n", len);
    }while( len > 0 );
    
    close(s);
    return EXIT_SUCCESS;
}