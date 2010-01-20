#include "stdafx.h"
#include "runOpticalFlow.h"
#include "mex.h"

void mexFunction( int nlwhs,       mxArray *plhs[],
		        		  int nrhs, const mxArray *prhs[] )
{
	int m,n;
 	DATA_TYPE* Ia;
	DATA_TYPE* Ib;
	DATA_TYPE* ptr1;
	DATA_TYPE* ptr2;
	bool isDense;
	int windowsSize;
	int levels;

	// Get Parameters		
	m=mxGetM(prhs[0]);
	n=mxGetN(prhs[0]);
	Ia = (DATA_TYPE*)mxGetData(prhs[0]);
	Ib = (DATA_TYPE*)mxGetData(prhs[1]);
	isDense = (bool)mxGetScalar(prhs[2]);
	windowsSize = (int)mxGetScalar(prhs[3]);	
	levels = (int)mxGetScalar(prhs[4]);

	// Create opencv arrays for images and copy data to them
	IplImage* imgA  = cvCreateImage(cvSize(n,m),IPL_DEPTH_8U,1);
    IplImage* imgB  = cvCreateImage(cvSize(n,m),IPL_DEPTH_8U,1);
	int step = imgA->widthStep;
	int cvIndex = 0;
	for(int row=0;row<m;row++)
		{
		  for(int col=0;col<n;col++)
			{
				cvIndex = row*step + col;
				imgA->imageData[cvIndex]=MAT_ELEM(Ia,m,row,col);
				imgB->imageData[cvIndex]=MAT_ELEM(Ib,m,row,col);
			}
	}

	// Call opencv OF
	CvPoint2D32f* cornersA = NULL;
	CvPoint2D32f* cornersB = NULL;
	int corner_count = 0;
	runOF(imgA,imgB,isDense,windowsSize,levels,cornersA,cornersB,corner_count);

	//Results
	//Copy data to output parameters
	plhs[0]= mxCreateDoubleMatrix(corner_count,2,mxREAL);
	ptr1=(DATA_TYPE*)mxGetData(plhs[0]);
	plhs[1]= mxCreateDoubleMatrix(corner_count,2,mxREAL);
	ptr2=(DATA_TYPE*)mxGetData(plhs[1]);
	for(int row=0;row<corner_count;row++)
	{
		MAT_ELEM(ptr1,corner_count,row,0)=cornersA[row].x;	
		MAT_ELEM(ptr1,corner_count,row,1)=cornersA[row].y;		

		MAT_ELEM(ptr2,corner_count,row,0)=cornersB[row].x;	
		MAT_ELEM(ptr2,corner_count,row,1)=cornersB[row].y;		
	}
}

