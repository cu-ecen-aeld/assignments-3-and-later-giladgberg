#include <stdio.h>
#include <stdbool.h>
#include <stdarg.h>
#include <sys/types.h>  // for pid_t
#include <unistd.h>     // for fork(), execv()
#include <sys/wait.h>   // for wait()
#include <stdlib.h>
#include <fcntl.h>




bool do_system(const char *command);

bool do_exec(int count, ...);

bool do_exec_redirect(const char *outputfile, int count, ...);
