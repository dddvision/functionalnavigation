#include <stdio.h>
#include <tchar.h>
#include "mex.h"
#include "cv.h"
#include "cxcore.h"
#include "highgui.h"

const int MAX_CORNERS = 10000;

#define DATA_TYPE double
#define MAT_ELEM(v,d,i,j) (*(v+((d)*(j))+(i)))

void runSURF(IplImage*, IplImage*,double disThreshold,CvPoint2D32f* &,CvPoint2D32f* &,int &);
double compareSURFDescriptors( const float* , const float* , double , int  );
int naiveNearestNeighbor( const float* , int ,
                          const CvSeq* ,
                          const CvSeq*,double );


void runSURF(IplImage* imgsrc, IplImage* imgdst,double disThreshold,CvPoint2D32f* &pointsA,CvPoint2D32f* &pointsB,int &count)
{

  CvSeq *srckpts, *srcdes, *dstkpts, *dstdes;
  CvMat *ptsrc, *ptdst;
  int icnt, n, nearest_neighbor;
  CvSeqReader reader, kreader;
  CvSeq *ptpairs;
  int *idx;
  const CvSURFPoint *kp;
  const float *descriptor;
  CvMemStorage* __mmstg;
  __mmstg  = cvCreateMemStorage(0);

  CvSURFParams params = cvSURFParams(500, 1);
  cvExtractSURF(imgsrc, 0, &srckpts, &srcdes, __mmstg , params);
  cvExtractSURF(imgdst, 0, &dstkpts, &dstdes, __mmstg , params);

  cvStartReadSeq(srckpts, &kreader, 0);
  cvStartReadSeq(srcdes, &reader, 0);

  ptpairs = cvCreateSeq (CV_32SC1, sizeof(CvSeq), sizeof(int), __mmstg );

  for( icnt = 0; icnt < srcdes->total; icnt++ )  {
    kp = (const CvSURFPoint*)kreader.ptr;
    descriptor = (const float*)reader.ptr;
    CV_NEXT_SEQ_ELEM ( kreader.seq->elem_size, kreader );
    CV_NEXT_SEQ_ELEM ( reader.seq->elem_size, reader );

    nearest_neighbor = naiveNearestNeighbor (descriptor, kp->laplacian, dstkpts, dstdes,disThreshold);
    if( nearest_neighbor >= 0 ){
      cvSeqPush(ptpairs, &icnt);
      cvSeqPush(ptpairs, &nearest_neighbor);
    }
  }

  n = (int)ptpairs->total/2;

  pointsA = new CvPoint2D32f[srcdes->total];
  pointsB = new CvPoint2D32f[srcdes->total];
  count = n;

  for(icnt = 0; icnt < n; icnt++ ) {
    idx = (int *)CV_GET_SEQ_ELEM(int, ptpairs, icnt*2);
	pointsA[icnt].x = (double)((CvSURFPoint*)cvGetSeqElem(srckpts,*idx))->pt.x;
	pointsA[icnt].y = (double)((CvSURFPoint*)cvGetSeqElem(srckpts,*idx))->pt.y;

    idx = (int *)CV_GET_SEQ_ELEM(int, ptpairs, icnt*2+1);
	pointsB[icnt].x = (double)((CvSURFPoint*)cvGetSeqElem(dstkpts,*idx))->pt.x;
	pointsB[icnt].y = (double)((CvSURFPoint*)cvGetSeqElem(dstkpts,*idx))->pt.y;
  }

    cvReleaseMemStorage(&__mmstg );
}
double compareSURFDescriptors( const float* d1, const float* d2, double best, int length ){
  double total_cost = 0;
  double t0, t1, t2, t3;
  int i;
  
  assert( length % 4 == 0 );
  for(i = 0; i < length; i += 4 )
  {
    t0 = d1[i] - d2[i];
    t1 = d1[i+1] - d2[i+1];
    t2 = d1[i+2] - d2[i+2];
    t3 = d1[i+3] - d2[i+3];
    total_cost += t0*t0 + t1*t1 + t2*t2 + t3*t3;
    if( total_cost > best )
      break;
  }
  return total_cost;
}


int naiveNearestNeighbor( const float* vec, int laplacian,
                          const CvSeq* model_keypoints,
                          const CvSeq* model_descriptors,double disThreshold) {
  int length = (int)(model_descriptors->elem_size/sizeof(float));
  int i, neighbor = -1;
  double d, dist1 = 1e6, dist2 = 1e6;
  CvSeqReader reader, kreader;
  const CvSURFPoint* kp;
  const float* mvec;
  
  cvStartReadSeq( model_keypoints, &kreader, 0);
  cvStartReadSeq( model_descriptors, &reader, 0);

  for( i = 0; i < model_descriptors->total; i++ ) {
    kp = (const CvSURFPoint*)kreader.ptr;
    mvec = (const float*)reader.ptr;
    CV_NEXT_SEQ_ELEM( kreader.seq->elem_size, kreader );
    CV_NEXT_SEQ_ELEM( reader.seq->elem_size, reader );
    if( laplacian != kp->laplacian )
      continue;
    d = compareSURFDescriptors( vec, mvec, dist2, length );
    if( d < dist1 )
    {
      dist2 = dist1;
      dist1 = d;
      neighbor = i;
    }
    else if ( d < dist2 )
      dist2 = d;
  }
  if ( dist1 < disThreshold*dist2 )
    return neighbor;
  return -1;
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
	double disThreshold;

	// Get Parameters		
	m=mxGetM(prhs[0]);
	n=mxGetN(prhs[0]);
	Ia = (DATA_TYPE*)mxGetData(prhs[0]);
	Ib = (DATA_TYPE*)mxGetData(prhs[1]);
	disThreshold = (double)mxGetScalar(prhs[2]);	
	
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

	CvPoint2D32f* pointsA = NULL;
	CvPoint2D32f* pointsB = NULL;
	int count = 0;

	runSURF(imgA,imgB,disThreshold,pointsA,pointsB,count);
	

	//Results
	//Copy data to output parameters
	plhs[0]= mxCreateDoubleMatrix(count,2,mxREAL);
	ptr1=(DATA_TYPE*)mxGetData(plhs[0]);
	plhs[1]= mxCreateDoubleMatrix(count,2,mxREAL);
	ptr2=(DATA_TYPE*)mxGetData(plhs[1]);
	for(int row=0;row<count;row++)
	{
		MAT_ELEM(ptr1,count,row,0)=pointsA[row].x;	
		MAT_ELEM(ptr1,count,row,1)=pointsA[row].y;		

		MAT_ELEM(ptr2,count,row,0)=pointsB[row].x;	
		MAT_ELEM(ptr2,count,row,1)=pointsB[row].y;		
	}

	cvReleaseImage(&imgA);
	cvReleaseImage(&imgB);

}

