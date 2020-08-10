# OnlineAdsClickThroughPrediction

This project involves predicting clicks for online advertisements. The training data consists of data from a website for 9 days from October 21, 2014 to October 29, 2014. There are **in excess of 30 million records** in the training data. The variables are as follows:
- id = the identifier of the ad (this may, or may not be unique to each row).
- click = 1 means the ad was clicked on. click = 0 means the ad was not clicked on.
- hour = the date and hour when the ad was displayed. Format is YYMMDDHH.
- C1 = an anonymized categorical variable.
- banner_pos = the position in the banner.
- site_id = an identifier for the web site.
- site_domain = an identifier for the site domain
 site_category = a code for the site’s category.
 app_id = an identifier for the application showing the ad.
 app_domain = an identifier for the app’s domain.
 app_category = a code for the category of the app.
 device_id = an identifier for the device used.
 device_ip = a code for the ip of the device.
 device_model = the model of the device.
 device_type = the type of the device.
 device_conn_type = the type of the device’s connection
 C14 – C21 = anonymized categorical variables
Thus, there are 24 columns in the dataset. The variable “click” is the Y-variable in the dataset. You will be attempting to predict the probability of a click.
