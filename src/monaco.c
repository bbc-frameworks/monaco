
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <strings.h>

#include "monaco.h"
#include "monaco_ev.h"

void error (char* message) {
    perror(message);
    exit(1);
}

typedef struct monaco_client {
    int fd;
    ev_io read_watcher;
    ev_io write_watcher;
    struct sockaddr_in address;
    void* previous;
    void* next;
} monaco_client;

static void read_callback (EV_P_ ev_io *watcher, int revents) {
    printf("in read callback\n");
}

static void write_callback (EV_P_ ev_io *watcher, int revents) {
    printf("in write callback\n");
}

const static socklen_t client_address_length = sizeof(struct sockaddr_in);

static void accept_callback (EV_P_ ev_io *watcher, int revents) {
    monaco_client* client = malloc(sizeof(monaco_client));

    client->fd = accept(watcher->fd, (struct sockaddr *) &client->address, &client_address_length);
    if (client->fd < 0) {
        error("could not accept");
    }

    ev_io_init(&client->read_watcher, read_callback, client->fd, EV_READ);
    ev_io_start(loop, &client->read_watcher);

    ev_io_init(&client->write_watcher, write_callback, client->fd, EV_WRITE);
    ev_io_start(loop, &client->write_watcher);
}

int main (int argc, char* argv[]) {

    int socket_options = 1;
    int socket_fd;
    struct sockaddr_in server_address;
    struct ev_loop *loop;
    ev_io sock_watcher;
    int status;

    socket_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (socket_fd < 0) {
        error("could not create socket");
    }

    setsockopt(socket_fd, SOL_SOCKET, SO_REUSEADDR, (char *)&socket_options, sizeof(socket_options));

    status = fcntl(socket_fd, F_GETFL, 0);
    fcntl(socket_fd, F_SETFL, status | O_NONBLOCK);

    bzero((char *) &server_address, sizeof(server_address));
    server_address.sin_family      = AF_INET;
    server_address.sin_port        = htons(8000);
    server_address.sin_addr.s_addr = INADDR_ANY;

    if (bind(socket_fd, (struct sockaddr *) &server_address, sizeof(server_address)) < 0) {
        error("could not bind socket");
    }

    listen(socket_fd, 255);
 
    loop = ev_default_loop (0); 

    ev_io_init(&sock_watcher, accept_callback, socket_fd, EV_READ);
    ev_io_start(loop, &sock_watcher);

    ev_loop(loop, 0);
    return 0;
}
