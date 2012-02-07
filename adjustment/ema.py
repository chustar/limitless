#public float CalculateEMA(float todaysPrice, float numberOfDays, float EMAYesterday){
#				float k = 2 / (numberOfDays + 1);
#				return todaysPrice * k + EMAYesterday * (1 – k);
#				}
#
#We want to calculate for 12 and 26 day windows
