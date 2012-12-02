;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;�ļ����ƣ�2440_init.s
;;����˵����2440��������
;;��д�������� ADaiPlaying������ �ӱ���ѧ
;;��дʱ�䣺2010/6/12
;;�޸ļ�¼��2010/6/29,���2440.inc��Option.inc�ļ������PLL������ش���
;;			2010/7/24,����ж�ӳ���Ͷ�ջ��ʼ��
;;			2010/8/15,�������ļ��Ƶ�KEIL MDK�ϣ��޸����£�
;;					  1.PRESERVE8
;;			2010/8/18,��IRQ�ж�ע���uCOS-II����
;;�汾˵����V1.2
;;����˵����2010/7/20��ʼ���ڱ�������TE-II����ѧϰ
;;			��Ȩ���У�������ע������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	GET 2440.inc
	GET option.inc
	GET memcfg.inc
	
	
	
	
	;Ԥ���幤��ģʽ����
USERMODE    EQU 	0x10	;�û�ģʽ
FIQMODE     EQU 	0x11	;�����ж�ģʽ
IRQMODE     EQU 	0x12	;�ж�ģʽ
SVCMODE     EQU 	0x13	;����ģʽ
ABORTMODE   EQU 	0x17	;��ֹģʽ
UNDEFMODE   EQU 	0x1b	;δ����ģʽ
MODEMASK    EQU 	0x1f	
NOINT       EQU 	0xc0	



	;�����ջ����
UserStack	EQU	(_STACK_BASEADDRESS-0x3800)	;0x33ff4800 ~
SVCStack	EQU	(_STACK_BASEADDRESS-0x2800)	;0x33ff5800 ~
UndefStack	EQU	(_STACK_BASEADDRESS-0x2400)	;0x33ff5c00 ~
AbortStack	EQU	(_STACK_BASEADDRESS-0x2000)	;0x33ff6000 ~
IRQStack	EQU	(_STACK_BASEADDRESS-0x1000)	;0x33ff7000 ~
FIQStack	EQU	(_STACK_BASEADDRESS-0x0)	;0x33ff8000 ~

     
	MACRO
$HandlerLabel HANDLER $HandleLabel

$HandlerLabel
    SUB	    SP,SP,#4			;decrement sp(to store jump address)
    STMFD   SP!,{R0}			;PUSH the work register to stack(lr does't push because it return to original address)
    LDR	    R0,=$HandleLabel	;load the address of HandleXXX to r0
    LDR	    R0,[R0]				;load the contents(service routine start address) of HandleXXX
    STR	    R0,[SP,#4]			;store the contents(ISR) of HandleXXX to stack
    LDMFD   SP!,{R0,PC}			;POP the work register and pc(jump to ISR)
    MEND



	IMPORT  |Image$$RO$$Base|	;ֻ�������(��ʼ)��ַ
	IMPORT  |Image$$RO$$Limit|  ;ֻ�����������ַ
	IMPORT  |Image$$RW$$Base|   ;RW����ʼ��ַ,��ų�ʼ���ı���
	IMPORT  |Image$$ZI$$Base|   ;Zero����ʼ��ַ
	IMPORT  |Image$$ZI$$Limit|  ;Zero�ν�����ַ

	IMPORT	OS_CPU_IRQ_ISR		;����uCOS-II IRQ�ж����

  	EXPORT	HandleEINT0			;ΪOs_cpu_a.s������


	PRESERVE8
  AREA    RESET,CODE,READONLY 
    ENTRY
    EXPORT	__ENTRY		;ӳ����ڱ�ţ��ṩ��ARM Linker�ĵ�ַ
__ENTRY
ResetEntry
	;�쳣�ж�������
    B ResetHandler				;�����ã���λ�쳣		�����ڹ���ģʽ	 	
    B HandlerUndef				;δ�����ָ��UND�쳣	��������ֹģʽ
    B HandlerSWI				;����ж�SWI�쳣		�����ڹ���ģʽ
    B HandlerPabort				;ָ��Ԥȡ��ֹPABT�쳣	��������ֹģʽ
    B HandlerDabort				;���ݷ�����ֹDABT�쳣	��������ֹģʽ
    B .							;handlerReserved
    B HandlerIRQ				;�ж�����IRQ�쳣		�������ж�ģʽ
    B HandlerFIQ				;�ⲿ�ж�����FIQ�쳣	�����ڿ����ж�ģʽ



 	LTORG	;�������ݻ����αָ��	

HandlerFIQ		HANDLER	HandleFIQ
HandlerIRQ		HANDLER HandleIRQ
HandlerUndef	HANDLER HandleUndef
HandlerSWI		HANDLER HandleSWI
HandlerDabort	HANDLER HandleDabort
HandlerPabort	HANDLER HandlePabort



	
	
	LTORG

;��λ��ڵ�ַ

ResetHandler
	;****************************************************
	;�رտ��Ź�        								
	;****************************************************
	LDR	R0,=WTCON       ;�رտ��Ź�
	LDR	R1,=0x0
	STR	R1,[R0]
	
	;****************************************************
	;���������ж�        								
	;****************************************************
	LDR R0, =INTMSK		
	LDR R1,=0xffffffff		;���������ж�
	STR R1,[R0]
	
	LDR R0,=SUBINTMSK
	LDR R1,=0xffff			;������жϿ�����
	STR R1,[R0]
	

	
	;****************************************************
	;��ʼ��ʱ��        								
	;****************************************************
   	LDR	R0,=LOCKTIME
    LDR	R1,=0xffffff	    ;���ø������໷ʱ������ʱ��		
    STR	R1,[R0]
    
    
	;****************************************************
	;����PLL���        								
	;****************************************************
    [ PLL_ON_START
	;���� Fclk:Hclk:Pclk �ķ�Ƶ��ֵ
	LDR	R0,=CLKDIVN
	LDR	R1,=CLKDIV_VAL		; 0=1:1:1, 1=1:1:2, 2=1:2:2, 3=1:2:4, 4=1:4:4, 5=1:4:8, 6=1:3:3, 7=1:3:6.
	STR	R1,[R0]
	
	[ CLKDIV_VAL>1 			;��ʾFclk:Hclk �ı�ֵ���� 1:1.
	MRC p15,0,R0,c1,c0,0
	ORR R0,R0,#0xc0000000	;R1_nF:OR:R1_iA
	MCR p15,0,R0,c1,c0,0
	|
	MRC p15,0,R0,c1,c0,0
	BIC R0,R0,#0xc0000000	;R1_iA:OR:R1_nF
	MCR p15,0,R0,c1,c0,0
	]

	;����UPLL
	LDR	R0,=UPLLCON
	LDR	R1,=((U_MDIV<<12)+(U_PDIV<<4)+U_SDIV)  ;Fin = 12MHz,UCLK = 96MHz
	STR	R1,[r0]
	NOP	; Caution: After UPLL setting, at least 7-clocks delay must be inserted for setting hardware be completed.
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	;���� MPLL
	LDR	R0,=MPLLCON			;PLLƵ�ʿ��ƼĴ���
	LDR	R1,=((M_MDIV<<12)+(M_PDIV<<4)+M_SDIV)  	;Fin=12MHz,MCLK = 400MHz
	STR	R1,[R0]									;ǰ������Fclk:Hclk:Pclk = 1:4:8,��Hclk = 100MHz
    ]											;								  Pclk = 50MHz
    
    BL	InitStacks			;��ʼ����ջָ��
    						;�ڱ������У���ʼ����ջ���̽�ʹ��IRQ��FIQ�жϱ�־


	;****************************************************
	;���ô洢�����ƼĴ���      
	;****************************************************
 	ADRL	R0,SMRDATA	
	LDR	R1,=BWSCON	;װ��BWSCON��ַ��R1
	ADD	R2,R0,#52	;SMRDATA������ַ(Memory���ƼĴ����ܹ�13����13*4=52�ֽ�)

0
	LDR	R3,[R0],#4	;װ��R0ָ��ĵ�ַһ�ֵ����ݵ�R3������R0�Զ���4(R0ָ��SMRDATA)
	STR	R3,[R1],#4	;��R3�е����ݴ洢��R1ָ��ĵ�ַ(R1ָ��Memory Control�Ĵ���)
	CMP	R2,R0		;�Ƚ��Ƿ��Ѿ��������
	BNE	%B0
	
	
	MOV	R0,#&1000	;��ʱ����
1
	SUBS	R0,R0,#1
	BNE	%B1

    
    
	;****************************************************
	;��OS_CPU_IRQ_ISR��ַװ��HandleIRQ��,IRQ�жϽ���uCOS-II
	;����      
	;****************************************************
    LDR	    R0,=HandleIRQ				;This routine is needed
    LDR	    R1,=OS_CPU_IRQ_ISR			;if there isn't 'subs pc,lr,#4' at 0x18, 0x1c
    STR	    R1,[r0]
    
    
    
	;****************************************************
	;�ж��Ǵ�Nor�������Ǵ�Nand����
	;�ж����ݣ�1.�ⲿ����OM[1:0]״̬
	;				OM[1:0]=00->��Nand����
	;				OM[1:0]=01->��Nor������16λģʽ
	;				OM[1:0]=10->��Nor������32λģʽ
	;				OM[1:0]=11->����
	;****************************************************
	LDR		R0, =BWSCON
	LDR		R0, [R0]
	ANDS	R0,R0,#6		;OM[1:0] != 0,��NOR FLash����
	BNE		NORRoCopy		;���Ϊ����ֵ����תִ�д�Nor���ƴ����ӳ���
	ADR		R0,ResetEntry	;OM[1:0] == 0, ��NAND FLash������ADRαָ������:SUB R0,PC,#0xXXX;
	CMP		R0,#0			;���Ͼ���ϣ��ж��Ƿ�ʹ�õ��Թ���ֱ�����ش��뵽RAM�������踴�ƴ���
							;����ģʽ�£�������ƴ�����ܳ�����Ϊ����д�ĳ���δ��д��Flash�У�Flash�е������ǲ�ȷ����
	BNE		InitRamZero		;���R0Ϊ����ֵ��ִ����ת���������¶�ȡNand����
    
     
	;****************************************************
	;�������nandflash������sdram
	;NandFlash:K9F2G08,2048�飬ÿ��64ҳ��ÿҳ2048�ֽ�
	;		   ��256M�ֽ�
	;****************************************************
Nand_boot_beg
	MOV	R5,#NFCONF
	;set timing value
	LDR	R0,=(7<<12) :or: (7<<8) :or: (7<<4)
	STR	R0,[R5]
	;enable control
	LDR	R0,=(0<<13) :or: (0<<12) :or: (0<<10) :or: (0<<9) :or: (0<<8) :or: (1<<6) :or: (1<<5) :or: (1<<4) :or: (1<<1) :or: (1<<0)
	STR	R0,[R5,#4]
	
	BL	ReadNandID
	MOV	R6,#0
	LDR	R0,=0xECF1	;K9F1G08U0A ID�ţ�(EC���̱�ţ�F1-Device���)
	CMP	R5,R0		;R5��ΪReadNandID���ص�FlashID
	BEQ	%F1
	LDR	R0,=0xEC76	;K9F1208U0 ID�ţ�(EC���̱�ţ�76-Device���)
	CMP	R5,R0
	BEQ	%F1
	MOV	R6,#1		;���Nandaddr(Ѱַ���� 0:4  1:5)
				;����Ĭ�ϲ�����������Flash����K9F2G08ʱ�����
1	
	BL	ReadNandStatus	;���ص�״̬�����R1��
	
	MOV	R8,#0			;R8Ϊҳ��ַ������
	LDR	R9,=ResetEntry
	MOV R10,#32			;+081010 feiling--�ܹ�����32ҳ,64KByte
2	
	ANDS	R0,R8,#0x3F	;����ǵ�һҳ�����⻵��(���R8��6λȫΪ����R0Ϊ0,����һҳ)
	BNE		%F3			;���R0ȫΪ0,��Z=1(EQ),����ת,˳��ִ��
	MOV		R0,R8		;����ǰNandFlash��ַָ�봫��R0
	BL		CheckBadBlk
	CMP		R0,#0		;���CheckBadBlk���ص�R0=0,��˵�����ǻ���
	ADDNE	R8,R8,#64	;ÿ���ҳ��
	ADDNE	R10,R10,#64 ;+081010 feiling
	BNE		%F4
3	
	MOV	R0,R8
	MOV	R1,R9			;R9�д��ResetEntry��ַ�����ݸ�ReadNandPage
	BL	ReadNandPage
	ADD	R9,R9,#2048		;ÿҳ���ֽ���
	ADD	R8,R8,#1		;ҳ����1
4	
	CMP	R8,R10  		;Ҫ������ҳ�� 081010 pht:#32->R10 
	BCC	%B2
	
	MOV	R5,#NFCONF		;DsNandFlash
	LDR	R0,[R5,#4]
	BIC R0,R0,#1
	STR	R0,[R5,#4]
	LDR	PC,=InitRamZero	;�˴���ת���ڴ�ռ� LDR װ�����ݣ�Ѱַ�� �����ı�PSR
						;Ҫװ��һ�����洢�ġ�״̬������ȷ�Ļָ��� ��������д��ldr r0, [base] ����  moves pc, r0


;=============================================================================================
;���Ǵ�Nand����,�򿽱�������nand_boot_beg�����,����ֱ����ת��main
;���Ǵ�Nor�鶯,��RO��RW���ֿ�����RAM,Ȼ����ת��RAMִ��
;ע��δ����ֱ����Nor�����з�ʽ
;=============================================================================================
NORRoCopy	
	;bl	ClearSdram

	ADR	R0,ResetEntry		;�жϵ�ǰ�����Ƿ���RAM������,����RAM�����У�R0=PC-0xXXX=BaseOfROM=ARM Linker��ָ���ĵ�ַ
							;����ROM�����У�R0=PC-0xXXX=0,(�˾�Ϊαָ��)
	LDR	R2,BaseOfROM		;���������ת��RwCopy,���򽫳��򿽱���RAM�� 
	CMP	R0,R2
	BEQ	NORRwCopy			;���˵����������Ѿ���RAM�У�ֻ���ʼ����������������򼴿�	
	LDR R3,TopOfROM			;����ȵĻ���˵��������0x0000_0000��ַ����ִ�У��������뵽RAM��
0							
	LDMIA	R0!,{R4-R7}
	STMIA	R2!,{R4-R7}
	CMP		R2, R3
	BCC		%B0
	
		
NORRwCopy	
	LDR	R0,TopOfROM
	LDR R1,BaseOfROM
	SUB R0,R0,R1			;TopOfROM-BaseOfROM�õ���0��ʼRW��ƫ�Ƶ�ַ(RW����ROM�е���ʼ��ַ)
	LDR	R2,BaseOfBSS		;��RW���ֵ����ݴ�ROM������RAM
	LDR	R3,BaseOfZero	
0
	CMP		R2,R3
	LDRCC	R1,[R0],#4
	STRCC	R1,[R2],#4
	BCC		%B0	
	
	B	InitRamZero	


    IMPORT  App_Main


CEntry
	B		App_Main


	;****************************************************
	;��ʼ�����ֹ���ģʽ�µĶ�ջָ��     
	;Don t use DRAM,such as stmfd,ldmfd......
	;SVCstack is initialized before
	;Under toolkit ver 2.5, 'msr cpsr,r1' can be used instead of 'msr cpsr_cxsf,r1'
	;****************************************************
InitStacks
	MRS	R0,CPSR
	BIC	R0,R0,#MODEMASK
	ORR	R1,R0,#UNDEFMODE :or: NOINT
	MSR	cpsr_cxsf,R1		;δ����ģʽ��UndefMode
	LDR	SP,=UndefStack		;UndefStack=0x33FF_5C00

	ORR	R1,R0,#ABORTMODE :or: NOINT
	MSR	cpsr_cxsf,R1		;��ֹģʽ��AbortMode
	LDR	SP,=AbortStack		;AbortStack=0x33FF_6000

	ORR	R1,R0,#IRQMODE :or: NOINT
	MSR	cpsr_cxsf,R1		;�ж�ģʽ��IRQMode
	LDR	SP,=IRQStack		;IRQStack=0x33FF_7000

	ORR	R1,R0,#FIQMODE :or: NOINT
	MSR	cpsr_cxsf,R1		;�����ж�ģʽ��FIQMode
	LDR	SP,=FIQStack		;FIQStack=0x33FF_8000

	BIC	R0,R0,#MODEMASK :or: NOINT
	ORR	R1,R0,#SVCMODE
	MSR	cpsr_cxsf,R1		;����ģʽ��SVCMode
	LDR	SP,=SVCStack		;SVCStack=0x33FF_5800

	;�û�ģʽ��ջָ�뻹û�б���ʼ��

	BX	LR
	;The LR register won t be valid if the current mode is not SVC mode.
	
	;****************************************************
	;��ȡnand flash ID
	;****************************************************
ReadNandID
	MOV      R7,#NFCONF
	LDR      R0,[R7,#4]		;NFChipEn();
	BIC      R0,R0,#2
	STR      R0,[R7,#4]
	MOV      R0,#0x90		;WrNFCmd(RdIDCMD);
	STRB     R0,[R7,#8]
	MOV      R4,#0			;WrNFAddr(0);
	STRB     R4,[R7,#0xC]
1							;while(NFIsBusy());
	LDR      R0,[R7,#0x20]
	TST      R0,#1
	BEQ      %B1
	LDRB     R0,[R7,#0x10]	;id  = RdNFDat()<<8;
	MOV      R0,R0,LSL #8
	LDRB     R1,[R7,#0x10]	;id |= RdNFDat();
	ORR      R5,R1,R0		;16λFlashID�����R5��
	LDR      R0,[R7,#4]		;NFChipDs();
	ORR      R0,R0,#2
	STR      R0,[R7,#4]
	BX		 LR	
	

	;****************************************************
	;��ȡnandflash״̬
	;****************************************************
ReadNandStatus
	MOV		 R7,#NFCONF
	LDR      R0,[R7,#4]		;NFChipEn();
	BIC      R0,R0,#2
	STR      R0,[R7,#4]
	MOV      R0,#0x70		;WrNFCmd(QUERYCMD);
	STRB     R0,[R7,#8]	
	LDRB     R1,[R7,#0x10]	;R1 = RdNFDat(); R1�д��NF״̬
	LDR      R0,[R7,#4]		;NFChipDs();
	ORR      R0,R0,#2
	STR      R0,[R7,#4]
	BX		 LR

	;****************************************************
	;�鿴nandflash�Ƿ�����æ״̬
	;70H,NandFalsh��״̬����
	;****************************************************
WaitNandBusy
	MOV      R0,#0x70		;WrNFCmd(QUERYCMD);
	MOV      R1,#NFCONF
	STRB     R0,[R1,#8]		;NFCMMD = 70H;���Ͷ����2440����Ĵ���
1							;while(!(RdNFDat()&0x40));	
	LDRB     R0,[R1,#0x10]
	TST      R0,#0x40
	BEQ		 %B1
	MOV      R0,#0			;WrNFCmd(READCMD0);
	STRB     R0,[R1,#8]
	BX       LR

	;****************************************************
	;���nandflash����
	;���ڲ�����R0��R0Ϊ�����ǻ��飬�����ǻ���
	;****************************************************
CheckBadBlk
	MOV		R7,LR
	MOV		R5,#NFCONF
	
	BIC     R0,R0,#0x3F		;addr &= ~0x3f;
	LDR     R1,[R5,#4]		;NFChipEn()
	BIC     R1,R1,#2
	STR     R1,[R5,#4]		;NFCONT &= ~(1<<2);��Reg_nCE=0(ʹ��NandFlash); 

	MOV     R1,#0x00		;WrNFCmd(READCMD)
	STRB    R1,[R5,#8]
	MOV     R1,#0			;2048&0xff
	STRB    R1,[R5,#0xC]	;WrNFAddr(2048&0xff);
	MOV     R1, #8			;(2048>>8)&0xf
	STRB    R1,[R5,#0xC]
	
	STRB    R0,[R5,#0xC]	;WrNFAddr(addr)
	MOV     R1,R0,LSR #8	;WrNFAddr(addr>>8)
	STRB    R1,[R5,#0xC]

	;=============================================
	;Ϊ2G08-NandFlash��ӣ�2010/8/5
	CMP      R6,#0			;if(NandAddr)
	MOVNE    R1,R0,LSR #16	;WrNFAddr(addr>>16)
	STRNEB     R1,[R5,#0xC]
	;=============================================
	MOV     R1,#0x30		;WrNFCmd(0x30)
	STRB    R1,[R5,#8]
		
;	CMP     R6,#0			;if(NandAddr)		
;	MOVNE   R0,R0,LSR #16	;WrNFAddr(addr>>16)
;	STRNEB  R0,[R5,#0xC]
	
;	BL		WaitNandBusy	;WaitNFBusy()
	;don t use WaitNandBusy, after WaitNandBusy will read part A!
	
	MOV	R0, #100			;��ʱһ��ʱ��
1
	SUBS	R0,R0,#1
	BNE	%B1
2
	LDR	R0,[R5,#0x20]		;NandFlash״̬�Ĵ���
	TST	R0, #1				;NFSTAT�����λRnB=1��NandFlash׼����,����æ״̬
	BEQ	%B2	

	LDRB	R0,[R5,#0x10]	;RdNFDat()
	SUB		R0,R0,#0xFF		;����ȡ�����ݼ�0xFF,�����������
		
	LDR     R1,[R5,#4]		;NFChipDs()
	ORR     R1,R1,#2
	STR     R1,[R5,#4]		;NFCONT |= (1<<2);��Reg_nCE=1(��ֹNandFlash);
	
	BX		R7


	;****************************************************
	;��ȡnandflashһҳ����
	;��ڲ���:R0:��Ҫ��ȡ���ݵ�ҳ��ַָ��
	;		  R1:��ȡ���ݴ�ŵ�SRAM��Ŀ���ַָ��
	;****************************************************	
ReadNandPage
	MOV		 R7,LR
	MOV      R4,R1
	MOV      R5,#NFCONF

	LDR      R1,[R5,#4]		;NFChipEn()
	BIC      R1,R1,#2
	STR      R1,[R5,#4]	

	MOV      R1,#0			;WrNFCmd(READCMD0)
	STRB     R1,[R5,#8]	
	STRB     R1,[R5,#0xC]	;WrNFAddr(0),����ҳ��ָ���8λ
	STRB     R1,[R5,#0xC]	;WrNFAddr(0),����ҳ��ָ���8λ	
	STRB     R0,[R5,#0xC]	;WrNFAddr(addr),����ҳָ���8λ
	MOV      R1,R0,LSR #8	;WrNFAddr(addr>>8),����ҳָ���8λ
	STRB     R1,[R5,#0xC]	
	
	;=============================================
	;Ϊ2G08���-2010/8/5
	CMP      R6,#0			;if(NandAddr)
	MOVNE    R1,R0,LSR #16	;WrNFAddr(addr>>16)
	STRNEB     R1,[R5,#0xC]	
	;=============================================	

	MOV      R1,#0x30		;WrNFCmd(0x30)
	STRB     R1,[R5,#8]		;���Ͷ����NFCMMD
		
;	CMP      R6,#0			;if(NandAddr)		
;	MOVNE    R0,R0,LSR #16	;WrNFAddr(addr>>16)
;	STRNEB   R0,[R5,#0xC]
	
	LDR      R0,[R5,#4]		;InitEcc()
	ORR      R0,R0,#0x10
	STR      R0,[R5,#4]		;NFCONT |= 1<<4;��InitECC=1;��ʼ��ECC
	
	BL       WaitNandBusy	;WaitNFBusy()
	
	MOV     R0,#0			;for(i=0; i<2048; i++)
1
	LDRB     R1,[R5,#0x10]	;buf[i] = RdNFDat()
	STRB     R1,[R4,R0]
	ADD      R0,R0,#1
	BIC      R0,R0,#0x10000	;?--------�Ǹ�����-------------------------------------------------
	CMP      R0,#0x800
	BCC      %B1			;(CC�޷���С��,C=0)
	 
	LDR      R0,[R5,#4]		;NFChipDs()
	ORR      R0,R0,#2
	STR      R0,[R5,#4]
		
	BX		 R7



	;****************************************************
	;��ʼ��SDRAM�����ݶ�
	;****************************************************	
InitRamZero
	MOV	R0,#0
	LDR R2,BaseOfZero
	LDR	R3,EndOfBSS
1	
	CMP		R2,R3			;��ʼ��Zero���� ���ܴ������������ⲿ�ֶ���Ҫִ��
	STRCC	R0,[R2],#4
	BCC		%B1
	
	LDR	PC,=CEntry			;goto compiler address
	
	
SMRDATA DATA
	;�ڴ�����ӦΪ��ѵ������Ż�
	;����Ĳ���δ�Ż���
	;�洢���������ڲ���ս��
	; 1���ڴ����ð�ȫ��������ʹ��HCLK = 100MHz�ġ�
	; 2��SDRAM��ˢ������ΪHCLK <= 100MHz��.

	DCD (0+(B1_BWSCON<<4)+(B2_BWSCON<<8)+(B3_BWSCON<<12)+(B4_BWSCON<<16)+(B5_BWSCON<<20)+(B6_BWSCON<<24)+(B7_BWSCON<<28))
	DCD ((B0_Tacs<<13)+(B0_Tcos<<11)+(B0_Tacc<<8)+(B0_Tcoh<<6)+(B0_Tah<<4)+(B0_Tacp<<2)+(B0_PMC))   ;GCS0
	DCD ((B1_Tacs<<13)+(B1_Tcos<<11)+(B1_Tacc<<8)+(B1_Tcoh<<6)+(B1_Tah<<4)+(B1_Tacp<<2)+(B1_PMC))   ;GCS1
	DCD ((B2_Tacs<<13)+(B2_Tcos<<11)+(B2_Tacc<<8)+(B2_Tcoh<<6)+(B2_Tah<<4)+(B2_Tacp<<2)+(B2_PMC))   ;GCS2
	DCD ((B3_Tacs<<13)+(B3_Tcos<<11)+(B3_Tacc<<8)+(B3_Tcoh<<6)+(B3_Tah<<4)+(B3_Tacp<<2)+(B3_PMC))   ;GCS3
	DCD ((B4_Tacs<<13)+(B4_Tcos<<11)+(B4_Tacc<<8)+(B4_Tcoh<<6)+(B4_Tah<<4)+(B4_Tacp<<2)+(B4_PMC))   ;GCS4
	DCD ((B5_Tacs<<13)+(B5_Tcos<<11)+(B5_Tacc<<8)+(B5_Tcoh<<6)+(B5_Tah<<4)+(B5_Tacp<<2)+(B5_PMC))   ;GCS5
	DCD ((B6_MT<<15)+(B6_Trcd<<2)+(B6_SCAN))    ;GCS6
	DCD ((B7_MT<<15)+(B7_Trcd<<2)+(B7_SCAN))    ;GCS7
	DCD ((REFEN<<23)+(TREFMD<<22)+(Trp<<20)+(Tsrc<<18)+(Tchr<<16)+REFCNT)

	DCD 0x32	    ;SCLK power saving mode, BANKSIZE 128M/128M,FL2440ʵ��SRAM��С������64M����Ϊ��ƬSRAM�ҽ���ͬһBANK�ϣ��������ֱ������Ϊ128M,ֻҪʹ��ʱע�ⲻҪ����ʵ�ʵ�ַ����
	;DCD 0x02	    ;SCLK power saving disable, BANKSIZE 128M/128M

	DCD 0x20	    ;MRSR6 CL=2clk
	DCD 0x20	    ;MRSR7 CL=2clk
	
	
BaseOfROM	DCD	|Image$$RO$$Base|
TopOfROM	DCD	|Image$$RO$$Limit|
BaseOfBSS	DCD	|Image$$RW$$Base|
BaseOfZero	DCD	|Image$$ZI$$Base|
EndOfBSS	DCD	|Image$$ZI$$Limit|

		
	
	;****************************************************
	;����RAM�е��ж�������
	;****************************************************
	AREA RamData, DATA, READWRITE
	
	
	^ _ISR_STARTADDRESS		;_ISR_STARTADDRESS=0x33FF_FF00
HandleReset 	#   4
HandleUndef 	#   4
HandleSWI		#   4
HandlePabort    #   4
HandleDabort    #   4
HandleReserved  #   4
HandleIRQ		#   4
HandleFIQ		#   4

;Don t use the label 'IntVectorTable',
;The value of IntVectorTable is different with the address you think it may be.
;IntVectorTable
;@0x33FF_FF20
HandleEINT0		#   4
HandleEINT1		#   4
HandleEINT2		#   4
HandleEINT3		#   4
HandleEINT4_7	#   4
HandleEINT8_23	#   4
HandleCAM		#   4		; Added for 2440.
HandleBATFLT	#   4
HandleTICK		#   4
HandleWDT		#   4
HandleTIMER0 	#   4
HandleTIMER1 	#   4
HandleTIMER2 	#   4
HandleTIMER3 	#   4
HandleTIMER4 	#   4
HandleUART2  	#   4
;@0x33FF_FF60
HandleLCD 		#   4
HandleDMA0		#   4
HandleDMA1		#   4
HandleDMA2		#   4
HandleDMA3		#   4
HandleMMC		#   4
HandleSPI0		#   4
HandleUART1		#   4
HandleNFCON		#   4		; Added for 2440.
HandleUSBD		#   4
HandleUSBH		#   4
HandleIIC		#   4
HandleUART0 	#   4
HandleSPI1 		#   4
HandleRTC 		#   4
HandleADC 		#   4
;@0x33FF_FFA0

    END