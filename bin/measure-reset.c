#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/time.h>
#include <poll.h>

#define GPIO_PULSE 23
#define GPIO_LEVEL 18
#define PLUNGER_START_LEVEL 0.060
#define PLUNGER_IDLE_LEVEL 0.048
#define PLUNGER_INCREMENT 0.0001
#define PLUNGER_DELAY_US 20000

static int board_is_reset(void) {
  int fd;
  char str[256];
  int gpio = GPIO_LEVEL;
  snprintf(str, sizeof(str)-1, "/sys/class/gpio/gpio%d/value", gpio);
  if ((fd = open(str, O_RDONLY)) < 0) {
     fprintf(stderr, "Failed, gpio %d not exported.\n", gpio);
     exit(1);
  }

  read(fd, str, sizeof(str));
  close(fd);
  return (str[0] == '0');
}

static void press_reset_button(void) {
	float level;
	char str[256];
	int fd;
	fd = open("/dev/pi-blaster", O_WRONLY);
	if (fd == -1) {
		perror("Unable to lower plunger");
		exit(1);
	}

	for (level = PLUNGER_START_LEVEL;
            !board_is_reset();
            level += PLUNGER_INCREMENT) {
		usleep(PLUNGER_DELAY_US);
		//fprintf(stderr, "Setting 12=%f\n", level);
		snprintf(str, sizeof(str) - 1, "12=%f\n", level);
		write(fd, str, strlen(str));
	}

	level = PLUNGER_IDLE_LEVEL;
	snprintf(str, sizeof(str) - 1, "12=%f\n", level);
	write(fd, str, strlen(str));

	exit(0);
}

/* Subtract the `struct timeval' values X and Y,
   storing the result in RESULT.
   Return 1 if the difference is negative, otherwise 0.  */

static int timeval_subtract(struct timeval *result,
                            struct timeval *x, struct timeval *y)
{
  /* Perform the carry for the later subtraction by updating y. */
  if (x->tv_usec < y->tv_usec) {
    int nsec = (y->tv_usec - x->tv_usec) / 1000000 + 1;
    y->tv_usec -= 1000000 * nsec;
    y->tv_sec += nsec;
  }
  if (x->tv_usec - y->tv_usec > 1000000) {
    int nsec = (x->tv_usec - y->tv_usec) / 1000000;
    y->tv_usec += 1000000 * nsec;
    y->tv_sec -= nsec;
  }

  /* Compute the time remaining to wait.
     tv_usec is certainly positive. */
  result->tv_sec = x->tv_sec - y->tv_sec;
  result->tv_usec = x->tv_usec - y->tv_usec;

  /* Return 1 if result is negative. */
  return x->tv_sec < y->tv_sec;
}

enum edge {
  RISING,
  FALLING,
  BOTH,
  NONE,
};

static int write_file(const char *filename, const char *string) {
  int fd = open(filename, O_WRONLY);
  if (fd == -1)
    return fd;

  write(fd, string, strlen(string));
  close(fd);
  return 0;
}

static int export_gpio(int gpio) {
  char filename[512];
  char string[128];

  snprintf(filename, sizeof(filename)-1, "/sys/class/gpio/export");
  snprintf(string, sizeof(string)-1, "%d", gpio);
  if (write_file(filename, string))
    return -1;

  snprintf(filename, sizeof(filename)-1, "/sys/class/gpio/gpio%d/direction", gpio);
  snprintf(string, sizeof(string)-1, "in");
  if (write_file(filename, string))
    return -1;

  return 0;
}

static int set_edge(int gpio, enum edge edge) {
  char filename[512];
  const char *edge_str;

  if (edge == RISING)
    edge_str = "rising";
  else if (edge == FALLING)
    edge_str = "falling";
  else if (edge == BOTH)
    edge_str = "both";
  else if (edge == NONE)
    edge_str = "none";
  else
    return -1;

  snprintf(filename, sizeof(filename)-1, "/sys/class/gpio/gpio%d/edge", gpio);
  if (write_file(filename, edge_str))
    return -1;
  return 0;
}


int main(int argc, char *argv[])
{
  char str[256];
  struct pollfd pfd;
  int fd;
  int gpio = GPIO_PULSE;
  int min_pulse = 0;
  int max_pulse = 10000;
  char buf[8];

  if (argc > 1) {
    min_pulse = atoi(argv[1]);
    if (argc > 2) {
      max_pulse = atoi(argv[2]);
      if (argc > 3) {
        gpio = atoi(argv[3]);
      }
    }
  }

  if (export_gpio(gpio)) {
    perror("Unable to export GPIO");
    return 1;
  }
  if (export_gpio(GPIO_LEVEL)) {
    perror("Unable to export GPIO_LEVEL");
    return 1;
  }

  snprintf(str, sizeof(str)-1, "/sys/class/gpio/gpio%d/value", gpio);
  if ((fd = open(str, O_RDONLY)) < 0) {
     fprintf(stderr, "Failed, gpio %d not exported.\n", gpio);
     exit(1);
  }

  printf("Press the reset button, and we'll measure the time.\n");
  printf("The time must be more than %d ms and less than %d ms\n",
      min_pulse, max_pulse);
  fflush(stdout);

  if (fork() > 0)
    press_reset_button();

  // Wait for the reset pulse to fall, indicating the board is in reset.
  set_edge(gpio, FALLING);

  pfd.fd = fd;
  pfd.events = POLLPRI;

  lseek(fd, 0, SEEK_SET);    /* consume any prior interrupt */
  read(fd, buf, sizeof buf);

  poll(&pfd, 1, -1);         /* wait for interrupt */
  
  lseek(fd, 0, SEEK_SET);    /* consume interrupt */
  read(fd, buf, sizeof buf);

  struct timeval starttime, endtime, difftime;
  gettimeofday(&starttime, NULL);
  set_edge(gpio, RISING);

  poll(&pfd, 1, -1);         /* wait for interrupt */
  
  lseek(fd, 0, SEEK_SET);    /* consume interrupt */
  read(fd, buf, sizeof buf);

  gettimeofday(&endtime, NULL);

  timeval_subtract(&difftime, &endtime, &starttime);
  printf("Reset pulse is %ld.%06ld long\n", difftime.tv_sec, difftime.tv_usec);

  if (difftime.tv_sec) {
    printf("Pulse way too long\n");
    fflush(stdout);
    return 1;
  }

  if (difftime.tv_usec < min_pulse) {
    printf("Pulse too short.\n");
    fflush(stdout);
    return 1;
  }
  
  if (difftime.tv_usec > max_pulse) {
    printf("Pulse too long.\n");
    fflush(stdout);
    return 1;
  }

  printf("Pulse is acceptable.\n");
  return 0;
}
