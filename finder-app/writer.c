#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>

int main(int argc, char *argv[]) {
    // Open syslog with LOG_USER facility
    openlog("writer", LOG_PID, LOG_USER);

    // Check if exactly 2 arguments are passed
    if (argc != 3) {
        syslog(LOG_ERR, "Invalid number of arguments: expected 2, got %d", argc - 1);
        fprintf(stderr, "Usage: %s <writefile> <writestr>\n", argv[0]);
        exit(1);
    }

    const char *writefile = argv[1];
    const char *writestr = argv[2];

    // Try to open the file for writing
    FILE *fp = fopen(writefile, "w");
    if (fp == NULL) {
        syslog(LOG_ERR, "Failed to open file '%s' for writing", writefile);
        perror("Error opening file");
        closelog();
        exit(1);
    }

    // Write the string to the file
    if (fprintf(fp, "%s", writestr) < 0) {
        syslog(LOG_ERR, "Failed to write to file '%s'", writefile);
        perror("Error writing to file");
        fclose(fp);
        closelog();
        exit(1);
    }

    syslog(LOG_DEBUG, "Writing %s to %s", writestr, writefile);

    // Clean up
    fclose(fp);
    closelog();

    return 0;
}
