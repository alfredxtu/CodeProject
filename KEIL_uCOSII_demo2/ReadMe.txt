uCOS-II��ֲĿ�꣺���԰弶��ϵͳ֧�֣�ʹ��ͬһ��ѧϰ��(����ʹ��FL2440)��д��ͬӦ�ó���ʱ��ֻ�踴��Demo���ɣ�Demo�в������κ�������Ϣ���������������֧���Ա���
�ļ�˵����
1.CommenFlies�����Ǻ�Ӧ�ó����޹ش��룬ÿһ���µ�Ӧ�ó�����Ժ�����ͬ��CommonFlies(FL2440+uCOSIIV2.90)
2.error:Symbol *** multiply defined(by uCOS_II.o and ***)
 ������ʽ����uCOS_II.c�ӹ������Ƴ�
3.δʹ��os_dbg_r.c����ֹDeBug��
4.��OS_core.c�����extern void OSStartHighRdy(void);��extern void OSIntCtxSw(void);
2010/8/15
����
����������԰ �ӱ���ѧ
�� ��������Ƕ��ʽ

ʹ��MDK J-Link���ԣ���Ҫ��Debug>Option>Utilities�е�Update Target before Debuggingqȡ��
��ʹ��RAM�ڲ����ԣ�˼��ο�DebugInRam.ini�еĴ洢�����ţ�
2010/8/16

uCOS-II���Դ��������У������ж���ֲ��ɣ���RAM�в���ͨ�������ص�Nor�в���ͨ����δ���ص�NAND�в��ԣ���ʱ���ٲ��ԣ����ڻ����Ǻ�������ʹ��J-Link��NAND����д���롣������Ĭ�ϴ�NAND�а���64K���뵽SRAM�У�������С����64K�����ֶ��޸���������NAND���˵ط���Ӧ������
2010//8/20


Ŀ¼���ţ�
1.CommonFlies�����FL2440ΪĿ��壬uCOS-IIΪϵͳ�Ļ������룬�û���дӦ�ó�����������޸�
2.Driver�������������룬һ��������App_cfg.h�����Enable/Disable��,��App.h����ӻ���������İ�������(��LED_test.hΪ�����ο��������)
3.App_Main�û����������,��Ź����Դ���

Ŀ¼���Ŵ��������Ⱥã����Ͽ��Ը����Լ�θ���޸�֮^_^