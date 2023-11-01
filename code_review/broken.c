#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {
    char buf[64];

    if (argc != 2) {
        return 1;
    }

    char *input = argv[1];

    strcpy(buf, "Hello, ");
    strncpy(buf + 7, input, sizeof(buf) - 7);

    printf("%s\n", buf);

    return 0;
}
