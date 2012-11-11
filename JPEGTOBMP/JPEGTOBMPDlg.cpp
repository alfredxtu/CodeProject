// JPEGTOBMPDlg.cpp : implementation file
//

#include "stdafx.h"
#include "JPEGTOBMP.h"
#include "JPEGTOBMPDlg.h"
#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif
#include "stdio.h"
/////////////////////////////////////////////////////////////////////////////
#include "memory.h"
#include "string.h"
extern "C" {
#include "libjpeg/jpeglib.h"
}

#pragma comment(lib, "libjpeg/libjpeg.lib")
#define IMAGESIZE	452400
void bmptojpg24(const char *strSourceFileName, const char *strDestFileName);
void jpgtobmp(const char *strSourceFileName, const char *strDestFileName);
/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CJPEGTOBMPDlg dialog

CJPEGTOBMPDlg::CJPEGTOBMPDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CJPEGTOBMPDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CJPEGTOBMPDlg)
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CJPEGTOBMPDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CJPEGTOBMPDlg)
	DDX_Control(pDX, IDC_JpgToBmp, m_JpgToBmp);
	DDX_Control(pDX, IDC_EDIT2, m_BmpFileName);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CJPEGTOBMPDlg, CDialog)
	//{{AFX_MSG_MAP(CJPEGTOBMPDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_JpegToBmp, OnJpegToBmp)
	ON_BN_CLICKED(IDC_BmpToJpeg, OnBmpToJpeg)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CJPEGTOBMPDlg message handlers

BOOL CJPEGTOBMPDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here
	
	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CJPEGTOBMPDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CJPEGTOBMPDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CJPEGTOBMPDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

void CJPEGTOBMPDlg::OnJpegToBmp() 
{
	// TODO: Add your control notification handler code here
	CFileDialog mJpgFileDlg(TRUE, NULL,NULL,
		OFN_ALLOWMULTISELECT,
		_T("Jpg Files (*.jpg)|*.jpg|All Files (*.*)|*.*||"),
		AfxGetMainWnd());
	if(mJpgFileDlg.DoModal() == IDOK)
	{
		CString strPath = mJpgFileDlg.GetPathName();
		CString strPath1;
		strPath1=mJpgFileDlg.GetFileTitle();
		strPath1+=".bmp";
		m_JpgToBmp.SetWindowText(strPath1);
		jpgtobmp(strPath,strPath1);
	}
	return ;
}

void CJPEGTOBMPDlg::OnBmpToJpeg() 
{
	// TODO: Add your control notification handler code here
	CFileDialog mBmpFileDlg(TRUE, NULL,NULL,
		OFN_ALLOWMULTISELECT,
		_T("Bmp Files (*.bmp)|*.bmp|All Files (*.*)|*.*||"),
		AfxGetMainWnd());
	if(mBmpFileDlg.DoModal() == IDOK)
	{
		CString strPath = mBmpFileDlg.GetPathName();
		CString strPath1;
		strPath1=mBmpFileDlg.GetFileTitle();
		strPath1+=".jpg";
		m_BmpFileName.SetWindowText(strPath1);
		bmptojpg24(strPath,strPath1);
	}
	return ;
}


//////////////////////////////////////////////////////////////////////////

/**************************************************************************
ѹ��ͼ��jpeg��ʽ�����ѹ��ǰ��ͼ����24λͼ����ǿ��ת��Ϊ24λͼ��ѹ��
**************************************************************************/
void bmptojpg24(const char *strSourceFileName, const char *strDestFileName)
{
	BITMAPFILEHEADER bfh;		// bmp�ļ�ͷ
	BITMAPINFOHEADER bih;		// bmpͷ��Ϣ
	RGBQUAD rq[256];			// ��ɫ��
	int i=0;

	BYTE *data= NULL;//new BYTE[bih.biWidth*bih.biHeight];
	BYTE *pData24 = NULL;//new BYTE[bih.biWidth*bih.biHeight];
	int nComponent = 0;

	// ��ͼ���ļ�
	FILE *f = fopen(strSourceFileName,"rb");
	if (f==NULL)
	{
		printf("Open file error!\n");
		return;
	}
	// ��ȡ�ļ�ͷ
	fread(&bfh,sizeof(bfh),1,f);
	// ��ȡͼ����Ϣ
	fread(&bih,sizeof(bih),1,f);
	// Ϊ�˼򵥣��ڱ����У�ֻ��ʾ8λ����ͼ��
	switch (bih.biBitCount) 
	{
	case 8:
		if (bfh.bfOffBits-1024<54) 
		{
			fclose(f);
			return;
		}
		data= new BYTE[bih.biWidth*bih.biHeight];
		pData24 = new BYTE[bih.biWidth*bih.biHeight*3];

		// ��λ��ɫ�壬����ȡ��ɫ��
		fseek(f,bfh.bfOffBits-1024,SEEK_SET);	
		fread(rq,sizeof(RGBQUAD),256,f);
		// ��ȡλͼ
		fread(data,bih.biWidth*bih.biHeight,1,f);
		fclose(f);
		nComponent = 3;
		for (i=0;i<bih.biWidth * bih.biHeight ;i++)
		{
			pData24[i*3] = rq[data[i]].rgbRed;
			pData24[i*3+1] = rq[data[i]].rgbGreen;
			pData24[i*3+2] = rq[data[i]].rgbBlue;
		}
		break;
	case 24:
		{
		data= new BYTE[bih.biWidth*bih.biHeight*3];
		pData24 = new BYTE[bih.biWidth*bih.biHeight*3];
		fseek(f,bfh.bfOffBits,SEEK_SET);	
		fread(data,bih.biWidth*bih.biHeight*3,1,f);
		fclose(f);
		for (i = 0;i<bih.biWidth*bih.biHeight;i++)
		{
			pData24[i*3] = data[i*3+2];
			pData24[i*3+1] = data[i*3+1];
			pData24[i*3+2] = data[i*3];
		}
		nComponent = 3;
		break;
		}
	default:
		fclose(f);
		return;
	}

	// ����ͼ���ȡ���

	struct jpeg_compress_struct jcs;
	struct jpeg_error_mgr jem;
	jcs.err = jpeg_std_error(&jem);

	jpeg_create_compress(&jcs);

	f=fopen(strDestFileName,"wb");
	if (f==NULL) 
	{
		delete [] data;
		//delete [] pDataConv;
		return;
	}
	jpeg_stdio_dest(&jcs, f);
	jcs.image_width = bih.biWidth; 			// Ϊͼ�Ŀ�͸ߣ���λΪ���� 
	jcs.image_height = bih.biHeight;
	jcs.input_components = nComponent;			// 1,��ʾ�Ҷ�ͼ�� ����ǲ�ɫλͼ����Ϊ3 
	if (nComponent==1)
		jcs.in_color_space = JCS_GRAYSCALE; //JCS_GRAYSCALE��ʾ�Ҷ�ͼ��JCS_RGB��ʾ��ɫͼ�� 
	else 
		jcs.in_color_space = JCS_RGB;

	jpeg_set_defaults(&jcs);	
	jpeg_set_quality (&jcs, 60, true);

	jpeg_start_compress(&jcs, TRUE);

	JSAMPROW row_pointer[1];			// һ��λͼ
	int row_stride;						// ÿһ�е��ֽ��� 

	row_stride = jcs.image_width*nComponent;		// �����������ͼ,�˴���Ҫ����3

	// ��ÿһ�н���ѹ��
	while (jcs.next_scanline < jcs.image_height) {
	    row_pointer[0] = & pData24[(jcs.image_height-jcs.next_scanline-1) * row_stride];
	    jpeg_write_scanlines(&jcs, row_pointer, 1);
	}

	jpeg_finish_compress(&jcs);

	jpeg_destroy_compress(&jcs);

	fclose(f);
	delete [] data;
	delete [] pData24;

}


/***********************************************************************
ѹ��ͼ��jpeg��ʽ
���ѹ��ǰͼ��Ϊ�Ҷ�ͼ��24λͼ��ѹ����ͼ��ɫ��ģʽ����
���ѹ��ǰͼ��Ϊ256ɫ����λͼ��ѹ�����Ϊ�Ҷ�ͼ
************************************************************************/
void bmptojpg(const char *strSourceFileName, const char *strDestFileName)
{
	BITMAPFILEHEADER bfh;		// bmp�ļ�ͷ
	BITMAPINFOHEADER bih;		// bmpͷ��Ϣ
	RGBQUAD rq[256];			// ��ɫ��

	BYTE *data= NULL;//new BYTE[bih.biWidth*bih.biHeight];
	//BYTE *pDataConv = NULL;//new BYTE[bih.biWidth*bih.biHeight];
	int nComponent = 0;

	// ��ͼ���ļ�
	FILE *f = fopen(strSourceFileName,"rb");
	if (f==NULL)
	{
		printf("Open file error!\n");
		return;
	}
	// ��ȡ�ļ�ͷ
	fread(&bfh,sizeof(bfh),1,f);
	// ��ȡͼ����Ϣ
	fread(&bih,sizeof(bih),1,f);
	// Ϊ�˼򵥣��ڱ����У�ֻ��ʾ8λ����ͼ��
	switch (bih.biBitCount) 
	{
	case 8:
		if (bfh.bfOffBits-1024<54) 
		{
			fclose(f);
			return;
		}
		data= new BYTE[bih.biWidth*bih.biHeight];
		//pDataConv = new BYTE[bih.biWidth*bih.biHeight];

		// ��λ��ɫ�壬����ȡ��ɫ��
		fseek(f,bfh.bfOffBits-1024,SEEK_SET);	
		fread(rq,sizeof(RGBQUAD),256,f);
		// ��ȡλͼ
		fread(data,bih.biWidth*bih.biHeight,1,f);
		fclose(f);
		nComponent = 1;
		break;
	case 24:
		{
		data= new BYTE[bih.biWidth*bih.biHeight*3];
		//pDataConv = new BYTE[bih.biWidth*bih.biHeight*3];
		fseek(f,bfh.bfOffBits,SEEK_SET);	
		fread(data,bih.biWidth*bih.biHeight*3,1,f);
		fclose(f);
		for (int i = 0;i<bih.biWidth*bih.biHeight;i++)
		{
			BYTE red = data[i*3];
			data[i*3] = data[i*3+2];
			data[i*3+2] = red;
		}
		nComponent = 3;
		break;
		}
	default:
		fclose(f);
		return;
	}

	// ����ͼ���ȡ���
	/*
	// �����ͼ����б任��ֻ����ԻҶ�ͼ������ʵ��Ӧ��ʱ��Ҫ�õ�
	int x=0,y=0;
	int nWidth = 0 , nHeight = 0;
	// Y����
	for (y=0;y<bih.biHeight;y++)
	{
		memcpy(&pDataConv[y*bih.biWidth],&data[(bih.biHeight-y-1)*bih.biWidth],bih.biWidth);
	}
	memcpy(data,pDataConv,bih.biSizeImage);
	// ���������в�����ͼ����б任
	if (argc==2)
	{
		switch (argv[1][0])
		{
		case 'x':
			// X����
			for (x=0;x<bih.biWidth;x++) {
				for (y=0;y<bih.biHeight;y++)
				{
					pDataConv[y*bih.biWidth+x] = data[(y+1)*bih.biWidth-x-1];
				}
			}
			nWidth = bih.biWidth;
			nHeight = bih.biHeight;
			break;
		case 'y':
			// Y����
			for (y=0;y<bih.biHeight;y++)
			{
				memcpy(&pDataConv[y*bih.biWidth],&data[(bih.biHeight-y-1)*bih.biWidth],bih.biWidth);
			}
			nWidth = bih.biWidth;
			nHeight = bih.biHeight;
			break;
		case 'a':
			// XY����
			for (x=0;x<bih.biWidth;x++) {
				for (y=0;y<bih.biHeight;y++)
				{
					pDataConv[y*bih.biWidth+x] = data[(bih.biHeight-y)*bih.biWidth-x-1];
				}
			}
			nWidth = bih.biWidth;
			nHeight = bih.biHeight;
			break;
		case 'r':
			// �����¾���Ȼ����ת90��
			for (x=0;x<bih.biWidth;x++) {
				for (y=0;y<bih.biHeight;y++)
				{
					pDataConv[x*bih.biHeight+y] = data[(bih.biHeight -y-1)*bih.biWidth+x];
				}
			}
			nWidth = bih.biHeight;
			nHeight = bih.biWidth;
			break;
		case 'l':
			// �����¾���Ȼ����ת270��
			for (x=0;x<bih.biWidth;x++) {
				for (y=0;y<bih.biHeight;y++)
				{
					pDataConv[x*bih.biHeight+y] = data[(y+1)*bih.biWidth-x-1];
				}
			}
			nWidth = bih.biHeight;
			nHeight = bih.biWidth;
			break;
		default: 
			printf("Invalid parameter\n\tTestLibjpeg.exe [x|y|a|r|]l\n");
			break;
		}
	}
	else
	{
		memcpy(pDataConv,data,bih.biSizeImage);
		nWidth = bih.biWidth;
		nHeight = bih.biHeight;
	}
	// ͼ��任��ϣ������ͼ�����ѹ��
	*/
	struct jpeg_compress_struct jcs;
	struct jpeg_error_mgr jem;
	jcs.err = jpeg_std_error(&jem);

	jpeg_create_compress(&jcs);

	f=fopen(strDestFileName,"wb");
	if (f==NULL) 
	{
		delete [] data;
		//delete [] pDataConv;
		return;
	}
	jpeg_stdio_dest(&jcs, f);
	jcs.image_width = bih.biWidth; 			// Ϊͼ�Ŀ�͸ߣ���λΪ���� 
	jcs.image_height = bih.biHeight;
	jcs.input_components = nComponent;			// 1,��ʾ�Ҷ�ͼ�� ����ǲ�ɫλͼ����Ϊ3 
	if (nComponent==1)
		jcs.in_color_space = JCS_GRAYSCALE; //JCS_GRAYSCALE��ʾ�Ҷ�ͼ��JCS_RGB��ʾ��ɫͼ�� 
	else 
		jcs.in_color_space = JCS_RGB;

	jpeg_set_defaults(&jcs);	
	jpeg_set_quality (&jcs, 60, true);

	jpeg_start_compress(&jcs, TRUE);

	JSAMPROW row_pointer[1];			// һ��λͼ
	int row_stride;						// ÿһ�е��ֽ��� 

	row_stride = jcs.image_width*nComponent;		// �����������ͼ,�˴���Ҫ����3

	// ��ÿһ�н���ѹ��
	while (jcs.next_scanline < jcs.image_height) {
	    row_pointer[0] = & data[(jcs.image_height-jcs.next_scanline-1) * row_stride];
	    jpeg_write_scanlines(&jcs, row_pointer, 1);
	}

	jpeg_finish_compress(&jcs);

	jpeg_destroy_compress(&jcs);

	fclose(f);
	delete [] data;

}

/***********************************************
*��ѹ��jpeg��bmp��ʽ
*���ڻҶ�ͼ��24λͼ��ͼ���ѹ������
*����256ɫ����λͼ��ͼ���ѹ��Ϊ�Ҷ�ͼ
**************************************************/
void jpgtobmp(const char *strSourceFileName, const char *strDestFileName)
{
	BITMAPFILEHEADER bfh;		// bmp�ļ�ͷ
	BITMAPINFOHEADER bih;		// bmpͷ��Ϣ
	RGBQUAD rq[256];			// ��ɫ��

	BYTE *data= NULL;//new BYTE[bih.biWidth*bih.biHeight];
	//BYTE *pDataConv = NULL;//new BYTE[bih.biWidth*bih.biHeight];
	int nComponent = 0;

	// ������ѹ�����󼰴�����Ϣ������
	struct jpeg_decompress_struct cinfo;
	struct jpeg_error_mgr jerr;

	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_decompress(&cinfo);

	FILE *f = fopen(strSourceFileName,"rb");
	if (f==NULL)
	{
		printf("Open file error!\n");
		return;
	}
	// 
	jpeg_stdio_src(&cinfo, f);
	jpeg_read_header(&cinfo, TRUE);
	data = new BYTE[cinfo.image_width*cinfo.image_height*cinfo.num_components];
	jpeg_start_decompress(&cinfo);

	JSAMPROW row_pointer[1];
	while (cinfo.output_scanline < cinfo.output_height)
	{
		row_pointer[0] = &data[(cinfo.output_height - cinfo.output_scanline-1)*cinfo.image_width*cinfo.num_components];
		jpeg_read_scanlines(&cinfo,row_pointer ,
					1);
	}
	jpeg_finish_decompress(&cinfo);
	jpeg_destroy_decompress(&cinfo);

	fclose(f);

	f=fopen(strDestFileName,"wb");
	if (f==NULL) 
	{
		delete [] data;
		//delete [] pDataConv;
		return;
	}
	// д�ļ�ͷ
	memset(&bfh,0,sizeof(bfh));
	bfh.bfSize = sizeof(bfh)+sizeof(bih);
	bfh.bfOffBits = sizeof(bfh)+sizeof(bih);
	if (cinfo.num_components==1)
	{
		bfh.bfOffBits += 1024;
		bfh.bfSize += 1024;
	}

	bfh.bfSize += cinfo.image_width*cinfo.image_height*cinfo.num_components;
	bfh.bfType = 0x4d42;
	fwrite(&bfh,sizeof(bfh),1,f);
	// дͼ����Ϣ
	bih.biBitCount = cinfo.num_components*8;
	bih.biSize = sizeof(bih);
	bih.biWidth = cinfo.image_width;
	bih.biHeight = cinfo.image_height;
	bih.biPlanes = 1;
	bih.biCompression = 0;
	bih.biSizeImage = cinfo.image_width*cinfo.image_height*cinfo.num_components;
	bih.biXPelsPerMeter = 0;
	bih.biYPelsPerMeter = 0;
	bih.biClrUsed = 0;
	bih.biClrImportant = 0;
	fwrite(&bih,sizeof(bih),1,f);
	// д��ɫ��
	if (cinfo.num_components ==1)
	{
		for (int i=0;i<256;i++)
		{
			rq[i].rgbBlue =i;
			rq[i].rgbGreen = i;
			rq[i].rgbRed = i;
			rq[i].rgbReserved = 0;
		}
		fwrite(rq,1024,1,f);
	}

	if (cinfo.num_components==3)
	{
		// ����rgb˳��
		for (int i = 0;i<bih.biWidth*bih.biHeight;i++)
		{
			BYTE red = data[i*3];
			data[i*3] = data[i*3+2];
			data[i*3+2] = red;
		}
	}
	fwrite(data,cinfo.image_width*cinfo.image_height*cinfo.num_components,1,f);
	fclose(f);
	delete [] data;

}