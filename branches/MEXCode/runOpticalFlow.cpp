#include "stdafx.h"
#include "runOpticalFlow.h"
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


	/* //Uncomment to make an image of the results -- only for sparse 
	IplImage* imgC = cvCreateImage(img_sz,imgA->depth,imgA->nChannels);
	for(int i=0;i<imgC->imageSize;i++){
		imgC->imageData[i]=255;
	}
	for( int i=0;i<corner_count;i++ ){
		CvPoint p0 = cvPoint( cvRound( cornersA[i].x ), cvRound( cornersA[i].y ) );
		CvPoint p1 = cvPoint( cvRound( cornersB[i].x ), cvRound( cornersB[i].y ) );
		cvLine( imgC, p0, p1, CV_RGB(255,0,0), 2 );
	}
	cvNamedWindow( "ImageA", 0 );
	cvNamedWindow( "ImageB", 0 );
	cvNamedWindow( "LKpyr_OpticalFlow", 0 );
	cvShowImage( "ImageA", imgA );
	cvShowImage( "ImageB", imgB );
	cvShowImage( "LKpyr_OpticalFlow", imgC );
	cvWaitKey(0);*/
}