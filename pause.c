#include <unistd.h>
#include <signal.h>

static void _endme(int sig)
{
    _exit(0);
}
int
main(int argc, char **argv)
{
    signal(SIGINT, _endme);
    signal(SIGTERM, _endme);
    pause();
    _exit(0);
}
