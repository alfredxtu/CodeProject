 /*******************************************************************
 �ļ����ƣ�App.h
 ����˵����Ӧ�ó�������ͷ�ļ�
 ��д�������� ����������԰ �ӱ���ѧ
 	   �ڱ�������Ƕ��ʽ
 ʱ�䣺2010/8/16
 ����˵�������������û������ͷ�ļ����������Խ������ļ�д�ɿ������͵�
 		   ����֮
 *******************************************************************/

#ifndef APP_H
#define APP_H

#if	LED_TEST_EN >0u	 			//���Ӧ�ó�������LED�����������������ش��뵽����
	#include "LED_test.h"
//	#include "lcd.h"
#endif


OS_STK	TaskStartStk[TASK_STK_SIZE];		//������ʼ�����ջ
OS_STK	TaskTestLedStk[4][TASK_STK_SIZE];	//����LED���������ջ

INT8U	LedNo[4];							//LED�������飬������ʼ����LED��Ŵ��ݸ�������

void AppInit(void);							//�û�Ӧ�ó����ʼ��

void TaskStart(void *pdata);				//��ʼ����

void TaskTestLed(void *pdata);				//����LED����

#endif

