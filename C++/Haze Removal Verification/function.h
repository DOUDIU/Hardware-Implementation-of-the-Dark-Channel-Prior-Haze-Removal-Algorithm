#ifndef FUNCTION_H
#define FUNCTION_H   

#include<opencv2/core/core.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<iostream>
#include<map>


using namespace std;
using namespace cv;


Mat guidedfilter_revise(Mat& GuideImage, Mat& srcImage, int r, double eps) {
	//转换源图像信息
	GuideImage.convertTo(GuideImage, CV_32FC1, 1 / 255.0);
	srcImage.convertTo(srcImage, CV_32FC1);
	
	//生成导向均值mean_G
	Mat mean_G;
	boxFilter(GuideImage, mean_G, CV_32FC1, Size(r, r));
	//生成原始均值mean_I
	Mat mean_I;
	boxFilter(srcImage, mean_I, CV_32FC1, Size(r, r));
	//生成互相关均值mean_GI
	Mat mean_GI;
	boxFilter(GuideImage.mul(srcImage), mean_GI,
		CV_32FC1, Size(r, r));
	//生成自相关均值mean_GG
	Mat mean_GG;
	boxFilter(GuideImage.mul(GuideImage), mean_GG,
		CV_32FC1, Size(r, r));

	//计算方差、协方差
	Mat cov_GI = mean_GI - mean_G.mul(mean_I);
	Mat var_G  = mean_GG - mean_G.mul(mean_G);
	//计算参数系数a,b
	Mat a = cov_GI / (var_G + eps);
	Mat b = mean_I - a.mul(mean_G);
	//计算系数a、b的均值
	Mat mean_a;
	boxFilter(a, mean_a, CV_32FC1, Size(r, r));
	Mat mean_b;
	boxFilter(b, mean_b, CV_32FC1, Size(r, r));
	//生成输出矩阵
	Mat resultMat = mean_a.mul(GuideImage) + mean_b;
	return resultMat;
}


//计算暗通道图像矩阵，针对三通道彩色图像
Mat dark_channel(Mat src, int border)
{
	std::vector<cv::Mat> rgbChannels(3);
	Mat min_mat(src.size(), CV_8UC1, Scalar(0)), min_mat_expansion;
	Mat dark_channel_mat(src.size(), CV_8UC1, Scalar(0));
	split(src, rgbChannels);
	for (int i = 0; i < src.rows; i++)
	{
		for (int j = 0; j < src.cols; j++)
		{
			int min_val = 0;
			int val_1, val_2, val_3;
			val_1 = rgbChannels[0].at<uchar>(i, j);
			val_2 = rgbChannels[1].at<uchar>(i, j);
			val_3 = rgbChannels[2].at<uchar>(i, j);

			min_val = std::min(val_1, val_2);
			min_val = std::min(min_val, val_3);
			min_mat.at<uchar>(i, j) = min_val;

		}
	}
	copyMakeBorder(min_mat, min_mat_expansion, border, border, border, border, BORDER_REPLICATE);

	for (int m = border; m < min_mat_expansion.rows - border; m++)
	{
		for (int n = border; n < min_mat_expansion.cols - border; n++)
		{
			Mat imageROI;
			int min_num = 256;
			imageROI = min_mat_expansion(Rect(n - border, m - border, 2 * border + 1, 2 * border + 1));
			for (int i = 0; i < imageROI.rows; i++)
			{
				for (int j = 0; j < imageROI.cols; j++)
				{
					int val_roi = imageROI.at<uchar>(i, j);
					min_num = std::min(min_num, val_roi);
				}
			}
			dark_channel_mat.at<uchar>(m - border, n - border) = min_num;
		}
	}
	return dark_channel_mat;
}


int calculate_A(Mat src, Mat dark_channel_mat)
{
	std::vector<cv::Mat> rgbChannels(3);
	split(src, rgbChannels);
	map<int, Point> pair_data;
	map<int, Point>::iterator iter;
	vector<Point> cord;
	int max_val = 0;
	for (int i = 0; i < dark_channel_mat.rows; i++)
	{
		for (int j = 0; j < dark_channel_mat.cols; j++)
		{
			int val = dark_channel_mat.at<uchar>(i, j);
			Point pt;
			pt.x = j;
			pt.y = i;
			pair_data.insert(make_pair(val, pt));
		}
	}

	for (iter = pair_data.begin(); iter != pair_data.end(); iter++)
	{
		cord.push_back(iter->second);
	}
	for (int m = 0; m < cord.size(); m++)
	{
		Point tmp = cord[m];
		int val_1, val_2, val_3;
		val_1 = rgbChannels[0].at<uchar>(tmp.y, tmp.x);
		val_2 = rgbChannels[1].at<uchar>(tmp.y, tmp.x);
		val_3 = rgbChannels[2].at<uchar>(tmp.y, tmp.x);
		max_val = std::max(max_val, val_1);
		max_val = std::max(max_val, val_2);
		max_val = std::max(max_val, val_3);
	}
	return max_val;
}


Mat calculate_tx(Mat& src, int A, Mat& dark_channel_mat)
{
	Mat dst;//是用来计算t(x)
	Mat tx;
	float dark_channel_num;

	dark_channel_num = A;
	dark_channel_mat.convertTo(dst, CV_32FC3, 1);//用来计算t(x)

	dst = dst / dark_channel_num;
	tx = 1 - 0.95 * dst;//最终的tx图

	return tx;
}


Mat haze_removal_img(Mat& src, int A, Mat& tx)
{
	Mat result_img(src.rows, src.cols, CV_8UC3);
	vector<Mat> srcChannels(3), resChannels(3);
	split(src, srcChannels);
	split(result_img, resChannels);

	for (int i = 0; i < src.rows; i++)
	{
		for (int j = 0; j < src.cols; j++)
		{
			for (int m = 0; m < 3; m++)
			{
				int value_num = srcChannels[m].at<uchar>(i, j);
				float max_t = tx.at<float>(i, j);
				if (max_t < 0.1)
				{
					max_t = 0.1;
				}
				resChannels[m].at<uchar>(i, j) = (value_num - A) / max_t + A;
			}
		}
	}
	merge(resChannels, result_img);

	return result_img;
}
#endif
