#include "stdafx.h"
#include <cv.h>
#include <cxcore.h>
#include <highgui.h>
const int MAX_CORNERS = 10000;
#define DATA_TYPE double
#define MAT_ELEM(v,d,i,j) (*(v+((d)*(j))+(i)))

void runOF(IplImage*, IplImage*,bool,int,int,CvPoint2D32f* &,CvPoint2D32f* &,int &);
