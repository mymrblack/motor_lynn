/* * motor.h *
 *  Created on: 2017Äê3ÔÂ27ÈÕ
 *      Author: Lin
 */

#ifndef SRC_MOTOR_H_
#define SRC_MOTOR_H_
#include "lidar_sys.h"


#define MOTOR_BASEADDR              XPAR_MOTOR_0_MOTOR_AXI_BASEADDR
/******* Write Reg *********/
#define MOTOR_CTRL_REG              0  // [1]:init_en, [0]:out_en
#define MOTOR_INIT_DIV              4
#define MOTOR_SIDE_RASTER_VAL       8
#define MOTOR_DIV_VAL_P				12
#define MOTOR_DIV_VAL_N				16
#define MOTOR_DIR_TIME_P            20
#define MOTOR_DIR_TIME_N            24
#define MOTOR_MOVE_TIME_P           28
#define MOTOR_MOVE_TIME_N           32



/******* Read Reg *********/
#define MOTOR_INIT_STATE            0
#define MOTOR_POS_A_CIRCLE_REG      4
#define MOTOR_RASTER_A_CIRCLE_REG   8

/*******Ctrl reg bits *********/
#define INIT_EN_BIT      1
#define RUN_EN_BIT       0
#define TO_ONE_SIDE_EN_BIT  2

#define CLK_FREQUENT    100000000 //100MHZ
typedef struct{
    int init_div;
    int pos_a_circle;
    int raster_a_circle;
    int div_p;
    int div_n;
    int angle;
    int FIR;
    float positive_time;
    float negtive_time;
}Motor_Data;

void motor_init(Motor_Data *motor);
void motor_find_origin(Motor_Data *motor);
int motor_check_find_origin_state(void);
void motor_wait_until_find_origin(void);
void motor_find_origin_begin(int init_div);
void motor_find_origin_end(void);
void motor_get_circle_info(Motor_Data *motor);
void motor_to_one_side(Motor_Data *motor);
void motor_run(Motor_Data *motor);



#endif /* SRC_MOTOR_H_ */
