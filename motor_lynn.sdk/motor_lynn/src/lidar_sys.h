/*
 * lidar_sys.h
 *
 *  Created on: 2017��1��5��
 *      Author: Lin
 */

#ifndef SRC_LIDAR_SYS_H_
#define SRC_LIDAR_SYS_H_
//#include "ff.h"
#include "xil_io.h"

//#define IMODE 1
#define FIFO_SIZE           8192
#ifdef IMODE
#define DATA_WORDS	11
#else
#define DATA_WORDS	9
#endif

#ifdef IMODE
typedef	struct{
	int ch1;
	int ch2;
	int ch3;
	int ch4;
	int ch5;
	int ch6;
	int ch7;
	int ch8;
	unsigned int gps1;
	unsigned int gps2;
	unsigned int triTimes;
}Lidar_Data;
#else
typedef	struct{
	int ch1;
	int ch2;
	unsigned int gps1;
	unsigned int gps2;
	unsigned int triTimes;
    int delay1;
    int delay2;
    int delay3;
    int delay4;
} Lidar_Data;
#endif

#define lidar_mWriteReg(BaseAddress, RegOffset, Data) \
   	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a PPS register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the PPS device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	Xuint32 PPS_mReadReg(Xuint32 BaseAddress, unsigned RegOffset)
 *
 */
#define lidar_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))


//void LidarSystemInitial(TCHAR *dirPath);


#endif /* SRC_LIDAR_SYS_H_ */
