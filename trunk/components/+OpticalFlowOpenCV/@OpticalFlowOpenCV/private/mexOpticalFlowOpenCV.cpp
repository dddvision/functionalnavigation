#include "mex.h"
#include "cv.h"
#include "cxcore.h"
#include "highgui.h"

const int MAX_CORNERS = 10000;

#define DATA_TYPE double
#define MAT_ELEM(v,d,i,j) (*(v+((d)*(j))+(i)))

void runOF(IplImage* imgA, IplImage* imgB,bool isDense,int windowsSize,int levels, CvPoint2D32f* &cornersA,CvPoint2D32f* &cornersB,
		   int &corner_count)
{
	CvSize img_sz = cvGetSize(imgA);

	// Get features' locations for tracking
	if (isDense){
		cornersA = new CvPoint2D32f[ img_sz.height*img_sz.width];
		cornersB = new CvPoint2D32f[  img_sz.height*img_sz.width ];
		int cnt = 0;
		for(int row=0;row<img_sz.height;row++){
			for(int col=0;col<img_sz.width;col++){
					  cornersA[cnt].x = col;
					  cornersA[cnt].y = row;
					  cnt = cnt +1;
			}
		}
		corner_count = cnt;
	}
	else{
		IplImage* eig_image = cvCreateImage( img_sz, IPL_DEPTH_32F, 1 );
		IplImage* tmp_image = cvCreateImage( img_sz, IPL_DEPTH_32F, 1 );
		cornersA = new CvPoint2D32f[ MAX_CORNERS];
		cornersB = new CvPoint2D32f[  MAX_CORNERS];
		corner_count = MAX_CORNERS;

		cvGoodFeaturesToTrack( imgA, eig_image, tmp_image, cornersA, &corner_count,
			0.05, 5.0, 0, 3, 0, 0.04 );
	}

	// Call Lucas Kanade algorithm
	char *features_found = NULL;
	float *feature_errors= NULL;
	CvSize pyr_sz = cvSize( imgA->width+8, imgB->height/3 );
	IplImage* pyrA = cvCreateImage( pyr_sz, IPL_DEPTH_32F, 1 );
	IplImage* pyrB = cvCreateImage( pyr_sz, IPL_DEPTH_32F, 1 );

	cvCalcOpticalFlowPyrLK( imgA, imgB, pyrA, pyrB, cornersA, cornersB, corner_count, 
		cvSize( windowsSize, windowsSize ), levels, features_found, feature_errors,
		 cvTermCriteria( CV_TERMCRIT_ITER | CV_TERMCRIT_EPS, 20, .3 ), 0 );

	//Note:	
	/* This termination criteria (cvTermCriteria) tells the algorithm to stop when it has either done 20 iterations or when
	*  epsilon is better than .3.  You can play with these parameters for speed vs. accuracy but these values
	*  work pretty well in many situations.
	*/
}

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
