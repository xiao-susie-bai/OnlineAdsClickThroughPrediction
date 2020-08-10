# OnlineAdsClickThroughPrediction

This project involves predicting probability of clicks for online advertisements. The training data consists of data from a website for 9 days from October 21, 2014 to October 29, 2014. There are **in excess of 30 million records** in the training data. The variables are as follows:
- id = the identifier of the ad (this may, or may not be unique to each row).
- click = 1 means the ad was clicked on. click = 0 means the ad was not clicked on.
- hour = the date and hour when the ad was displayed. Format is YYMMDDHH.
- C1 = an anonymized categorical variable.
- banner_pos = the position in the banner.
- site_id = an identifier for the web site.
- site_domain = an identifier for the site domain
- site_category = a code for the site’s category.
- app_id = an identifier for the application showing the ad.
- app_domain = an identifier for the app’s domain.
- app_category = a code for the category of the app.
- device_id = an identifier for the device used.
- device_ip = a code for the ip of the device.
- device_model = the model of the device.
- device_type = the type of the device.
- device_conn_type = the type of the device’s connection
- C14 – C21 = anonymized categorical variables

There are 24 columns in the training dataset. Note that almost all the variables are categorical variables. The variable “click” (binary - "1"/"0") is the Y-variable here.

The testing data consists of about **13 million records** that have not appeared in the training data, and all variables as in the training data except the target variable "click".

The model evaluation metric used here is log-loss (binary cross-entropy).

We followed a full machine learning project cycle from exploratory data analysis, data preparation, data transformations (including complex encoding) to model training, evaluation and selection. We drew meaningful insights and conclusions from our whole process in the end. Note that since the biggest challenge of this project is wrestling with the enormous data size (without a production-level coding environment), various tactics such as scaled up sampling of the data and divide-and-conquer have been maneuvered in the process.

The project description paper contains more detailed information about the project.
