#include<opencv2/core/core.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<iostream>
#include"function.h"
#include<algorithm>
#include<set>
#include<map>

using namespace std;
using namespace cv;

int main()
{
	Mat src = imread("../../pic/duck_fog.bmp");
	Mat dst;
	Mat dark_channel_mat = dark_channel(src, 3);//输出的是暗通道图像

	int A = calculate_A(src, dark_channel_mat);
	Mat tx = calculate_tx(src, A, dark_channel_mat);

	cvtColor(src, dst, COLOR_RGB2GRAY);
	Mat tx_ = guidedfilter_revise(dst, tx, 5, 0.001);//导向滤波后的tx，dst为引导图像

	Mat haze_removal_image = haze_removal_img(src, A, tx_);

	imshow("原始图", src);
	//imshow("灰度图", dst);
	//imshow("暗通道图", dark_channel_mat);
	//imshow("透射率函数", tx);
	imshow("导向滤波优化", tx_);
	imshow("去雾图", haze_removal_image);

	waitKey(0);
	return 0;
}

