/******************** (C) COPYRIGHT 2012 WildFire Team **************************
 * �ļ���  ��main.c
 * ����    ����3.5.0�汾���Ĺ���ģ�塣         
 * ʵ��ƽ̨��Ұ��STM32������
 * ��汾  ��ST3.5.0
 *
 * ����    ��wildfire team 
 * ��̳    ��www.ourdev.cn/bbs/bbs_list.jsp?bbs_id=1008
 * �Ա�    ��http://firestm32.taobao.com
**********************************************************************************/
#include "stm32f10x.h"
#include "uart.h"

char *str = "Hello world\n"; 
/* 
 * ��������main
 * ����  : ������
 * ����  ����
 * ���  : ��
 */
int main(void)
{
	  USART_Configuration();
  	  while(1)
	  {
		 USART2_Puts(str);
		// Delay();
	  };
	  // add your code here ^_^��
}
/******************* (C) COPYRIGHT 2012 WildFire Team *****END OF FILE************/


