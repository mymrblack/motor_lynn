/*
 * motor.c
 *
 *  Created on: 2017Äê3ÔÂ27ÈÕ
 *      Author: Lin
 */
#include <stdio.h>
#include "motor.h"
#include "sleep.h"
#include "xil_printf.h"

void motor_find_origin_begin(int init_div){
    lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_INIT_DIV, init_div );
    lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_CTRL_REG, 1 << INIT_EN_BIT);
}

int motor_check_find_origin_state(void){
   return lidar_mReadReg(MOTOR_BASEADDR, MOTOR_INIT_STATE) & 0x1;
}

void motor_wait_until_find_origin(void){
    while(motor_check_find_origin_state() == 0){
        sleep(1);
        //xil_printf("pos_counter: %d\r\n", lidar_mReadReg(MOTOR_BASEADDR, 12) );
    }
}

void motor_find_origin_end(void){
    lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_CTRL_REG, 0 << INIT_EN_BIT);
   // lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_CTRL_REG, 0);
}
void motor_find_origin(Motor_Data *motor){
    motor_find_origin_begin(motor -> init_div);
    motor_wait_until_find_origin();
    motor_get_circle_info(motor);
    motor_find_origin_end();
    xil_printf("pos_a_circle: %d, raster_a_circle: %d\r\n", motor->pos_a_circle, motor->raster_a_circle);
}

void motor_get_circle_info(Motor_Data *motor){
    motor -> pos_a_circle = lidar_mReadReg(MOTOR_BASEADDR, MOTOR_POS_A_CIRCLE_REG);
    motor -> raster_a_circle = lidar_mReadReg(MOTOR_BASEADDR, MOTOR_RASTER_A_CIRCLE_REG);
}

void motor_init(Motor_Data *motor){
    motor_find_origin(motor);
    sleep(1);
    motor_to_one_side(motor);
    sleep(1);
    motor_run(motor);
}

void motor_to_one_side(Motor_Data *motor){
    int side_raster_val= 0;
    side_raster_val = (motor -> raster_a_circle)*(motor -> angle)/360;
    xil_printf("side_raster_val: %d\r\n", side_raster_val);
    lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_SIDE_RASTER_VAL, side_raster_val);
    lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_CTRL_REG, 1 << TO_ONE_SIDE_EN_BIT);

    while(!((lidar_mReadReg(MOTOR_BASEADDR, MOTOR_INIT_STATE)& 0x2)>>1)){
        //sleep(1);
    }

    lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_CTRL_REG, 0 << TO_ONE_SIDE_EN_BIT);
}

void motor_run(Motor_Data *motor){
    int move_time_p = 0;
    int move_time_n = 0;
    int dir_time_p = 0;
    int dir_time_n = 0;
    float stay_time = 0;
    int angle_pulse = 0;

    stay_time = (motor -> FIR * 0.1 + 0.25)/1000;
    angle_pulse = motor -> angle * motor -> pos_a_circle * 2 / 360;

    move_time_p = (motor -> positive_time - stay_time) * CLK_FREQUENT;
    move_time_n = (motor -> negtive_time - stay_time)* CLK_FREQUENT;
    dir_time_p = motor -> positive_time * CLK_FREQUENT;
    dir_time_n = motor -> negtive_time * CLK_FREQUENT;

    motor -> div_p = move_time_p / angle_pulse;
    motor -> div_n = move_time_n / angle_pulse;

    lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_DIV_VAL_P, motor -> div_p);
    lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_DIV_VAL_N, motor -> div_n);
    lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_DIR_TIME_P, dir_time_p);
    lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_DIR_TIME_N, dir_time_n);
    lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_MOVE_TIME_P, move_time_p);
    lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_MOVE_TIME_N, move_time_n);
    lidar_mWriteReg(MOTOR_BASEADDR, MOTOR_CTRL_REG, 1 << RUN_EN_BIT);
}
