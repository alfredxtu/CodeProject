 /*******************************************************************
 �ļ����ƣ�App_cfg.h
 ����˵����Ӧ�ó�������ͷ�ļ�
 		   ������һ���뷨���ǽ�Ӧ�ó���д�ɿ������Եģ���Ӧ��ģ�����
		   ������Ȼ��ͨ���꿪����رգ�����д����ʱ���õĴ������ֱ��
		   ͨ����رգ�����һ��һ��ȥɾ������������ҪŪ�ɿ����õģ���
		   ��֮��
 ��д�������� ����������԰ �ӱ���ѧ
 	   �ڱ�������Ƕ��ʽ
 ʱ�䣺2010/8/15
 ����˵����We now assume the presence of a file called APP_CFG.H 
 		   which is declared in your application. The purpose of this
		   file is to assign task priorities, stack sizes and other 
		   configuration information for your application.(�ٷ�˵��)
 *******************************************************************/

#ifndef __APP_CFG_H__
#define __APP_CFG_H__

#define LED_TEST_EN		1u		//ʹ��LED_TEST_EN���������������ļ�


#define TASK_STK_SIZE		256

#define OS_TASK_TMR_PRIO	OS_LOWEST_PRIO - 10u

#endif
