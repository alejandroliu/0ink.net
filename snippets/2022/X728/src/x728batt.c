#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <linux/i2c-dev.h>
#include <linux/i2c.h>
#include <sys/ioctl.h>
#include <stdio.h>

#include "smbus.h"

const unsigned I2C_ADDRESS = 0x36;

// Open a connection to the bmp085
// Returns a file id
int begin()
{
	int fd = 0;
	char *fileName = "/dev/i2c-1";
	
	// Open port for reading and writing
	if ((fd = open(fileName, O_RDWR)) < 0)
	{
		exit(1);
	}
	
	// Set the port options and set the address of the device
	if (ioctl(fd, I2C_SLAVE, I2C_ADDRESS) < 0) 
	{					
		close(fd);
		exit(1);
	}

	return fd;
}

// Read two words from the BMP085 and supply it as a 16 bit integer
__s32 i2cReadInt(int fd, __u8 address)
{
	__s32 res = i2c_smbus_read_word_data(fd, address);
	if (0 > res) 
	{
		close(fd);
		exit(1);
	}

	// Convert result to 16 bits and swap bytes
	res = ((res<<8) & 0xFF00) | ((res>>8) & 0xFF);

	return res;
}

int main() {
  int fd = begin();
  __s32 data;
  double num;

  data = i2cReadInt(fd, 2);
  num = ((double)data) * 1.25 / 1000 / 16;
  printf("Voltage %.4f V\n", num);

  data = i2cReadInt(fd, 4);
  num = ((double)data) / 256;
  printf("Battery %.4f %%\n", num);
  
  return 0;
}
