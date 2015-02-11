/************************
 * communication - HOST *
 ************************/

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <stdio.h>

#define BAUDRATE B9600
#define _POSIX_SOURCE 1


int main(int argc, char **argv)
{
	int fd, ret;
	char buf[255], cmd[1024];

	if (argc != 2) {
		fprintf(stderr, "Usage: ./host device\n \tdevice: serial port destination (example: /dev/pts/7)\n");
		exit(1);
	}

	const char *DEVICE = argv[1];
	
	/* give read and write permissions */
	snprintf(cmd, sizeof(cmd), "sudo chmod a+rw %s;", argv[1]);
	cmd[sizeof(cmd)-1] = '\0';
	ret = system(cmd);
	if (ret < 0) {
		perror("system");
		exit(104);
	}

	/* open the device */
	fd = open(DEVICE, O_RDWR | O_NOCTTY | O_NDELAY);
	if (fd < 0) {
		perror(DEVICE);
		exit(1);
	}

	/* set the port */
	struct termios newtio;

	newtio.c_cflag = BAUDRATE | CS8 | CLOCAL | CREAD;

	newtio.c_cc[VTIME] = 0;	/* inter-charachter timer unused */
	newtio.c_cc[VMIN] = 1;	/* blocking read until 1 charachter arrives */

	tcsetattr(fd,TCSANOW,&newtio);

	printf("Host: Enter your string! (max: 64 bytes)\n");

	/* read the string */
	int len;
	ssize_t rcnt;
	rcnt = read(STDIN_FILENO, buf, 65);
	if (rcnt == -1) {
		perror("read");
		exit(1);
	}
	len = rcnt;
	buf[len-1]='\0';
	
	if (len == 65) {
		fprintf(stderr, "Host: string is more than 64 bytes!\n");
		exit(1);
	} else	printf("Host: string is %d bytes. Valid!\n", len);

	fprintf(stderr, "Host: Writing in port...\n");

	/* write the string into the serial port */	
	ssize_t wcnt;
	int idx=0;
	do {
		wcnt = write(fd, buf + idx, 1);
		if (wcnt == -1) {
			perror("write");
			exit(1);
		}
		idx += wcnt;
	} while (idx < len);

	fprintf(stderr, "Host: Writing completed!\n");
	
	fprintf(stderr, "Host: Receiving from guest...\n");

	sleep(2);

	/* read from the port */
	rcnt = read(fd,buf,255);
	if (rcnt == -1) {
		perror("read");
		exit(1);
	}
	fprintf(stderr, "Guest: ");
		
	/* print guest's message */
	wcnt = write(STDOUT_FILENO, buf, rcnt);
		if (wcnt == -1) {
			perror("write");
			exit(1);
	}
	
	close(fd);

	return 0;
}
