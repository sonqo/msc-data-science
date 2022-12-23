# Efstratios Karypiadis | f3352209 | MSc in Data Science | Fall 2022

library(urca)
library(MASS)
library(dplyr)
library(fGarch)

columns = c("y1", "y2", "y3", "y", "y5", "y6", "y7", "y8", "y9", 
            "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9", "x10", "x11", "x12", "x13", "x14", "x15")
data <- read.table('./data.txt', col.names = columns) # read data
data <- subset(data, select = -c(y1, y2, y3, y5, y6, y7, y8, y9)) # keep Y4
data <- ts(data, start=c(1990, 4), end=c(2005, 12), frequency=12)

# From the above dataset we discard unwanted y-values.

par(mfrow=c(1, 2))
plot(data[, 1], type='l', col='blue', main='Time Series of Y4')
hist(data[, 1], nclass=20, main="Histogram of Y4")

# From the above plots we can assume our times series is a stationary process oscillating around 0.
# The distribution of our data looks like student's-t, since we have entries at the extremes of the tails.
# Since the data is corresponding to returns and due to the above, we won't compute the difference of logs and will work 
# with the data as is.

shapiro.test(data[, 1]) # normality

# With a = 5% the we reject the null hypothesis of the Shapiro-Wilk test, meaning that our data do not correspond to a
# normal distribution.

par(mfrow=c(1,2))  
hist(data[, 1], prob=TRUE, 20, main="Histogram of Y4")        
lines(density(data[, 1])   )          
qqnorm(data[, 1],main="Normal QQplot of Y4")      
qqline(data[, 1])

# The QQ-plot confirms that Y4 is not normal.

# We then perform a Ljung-Box test to check the stationarity of Y4 :

summary(ur.df(data[, 1], type='drift'))

# we reject the null hypothesis (a > p-value and due to critical values), 
# concluding that our time series is a stationary process

########################
# TASK 1 | ARMA models #
########################

# We will first check the ACF and PACF plots of Y4 :

par(mfrow=c(1, 2))
acf(ts(data[, 1], frequency=1), 100, main='ACF of Y4')
pacf(ts(data[, 1], frequency=1), 100, main='PACF of Y4')

# As a first iteration we notice that MA(1), MA(2) and AR(1) components seem significant.

ma1fit = arima(data[, 1], order=c(0, 0, 1)) # MA(1)
ma1fit

# Log likelihood : 601.9 | AIC = -1197.8 | Coefficient/S.E. = 3.1
# For a = 5% the null hypothesis should be rejected, i.e., the coefficient of the MA(1) component is not zero.

ar1fit = arima(data[, 1], order=c(1, 0, 0)) # AR(1)
ar1fit

# Log likelihood : 603.4 | AIC = -1200.9 | Coefficient/S.E. = 3.5
# For a = 5% the null hypothesis should be rejected, i.e., the coefficient of the AR(1) component is not zero.

ma2fit = arima(data[, 1], order=c(0, 0, 2)) # MA(2)
ma2fit

# Log likelihood : 604.88 | AIC = -1201.8 | Coefficient/S.E. = 3.1
# For a = 5% the null hypothesis should be rejected, i.e., the coefficients of the MA(2) component are not zero.

par(mfrow=c(3, 2))
acf(ts(ma1fit$residuals, frequency=1), 100, main='ACF of MA(1)')
pacf(ts(ma1fit$residuals, frequency=1), 100, main='PACF of MA(1)')
acf(ts(ma2fit$residuals, frequency=1), 100, main='ACF of MA(2)')
pacf(ts(ma2fit$residuals, frequency=1), 100, main='PACF of MA(2)')
acf(ts(ar1fit$residuals, frequency=1), 100, main='ACF of AR(1)')
pacf(ts(ar1fit$residuals, frequency=1), 100, main='PACF of AR(1)')

# The MA(2) model seems to sufficiently describe our data, since there are no significant components (except lag 81)
# at the ACF and PACF plots of the residuals. It also has the highest log likelihood value.
# Hence, we will proceed with the MA(2).

##############################
# TASK 2 | Regression models #
##############################

x <- ts(subset(data, select = -c(y)), start=c(1990, 4), end=c(2005, 12), frequency=12)
y1res <- lm(data[, 1] ~., data=x)
step_y1res <- stepAIC(y1res, direction='both', trace=FALSE)
summary(step_y1res)

# For a = 5% the step wise regression returns x2, x4 and x5 variables as statistically significant. Hence we will conclude to the model:
# y = a + c1 * x2 + c2 * x4 + c3 * x5

# After checking the importance of variables x2, x4, x5 we conclude that x5 results to the best R-squared value.
# This is apparent also from testing models with a single variable, for all variables.
# We will then iteratively add more variables, by checking their importance, R-squared score and F-statistic.

y1res <- lm(data[, 1] ~ x[, 2] + x[, 4] + x[, 5])
summary(y1res)

par(mfrow=c(1, 1))
plot(y1res$residuals, type='l', col='red', main='Residuals of Y4-regression')
shapiro.test(y1res$residuals) # reject null, not normal errors
Box.test(y1res$residuals, lag=20) # reject null, auto-correlated errors at lag 20

########################
# TASK 3 | Combination #
########################

# We will follow the regression model in which we concluded to at the previous task.
# We notice that the ACF and PACF of the residuals have significant components. 
# Hence, we will consider potential ARMA models to counter this behavior.
# In addition, we will the ACF and PACF of the squared residuals to correct potential problems with ARCH models.

#==================#
# Auto-correlation #
#==================#

par(mfrow=c(1, 2))
acf(ts(y1res$residuals, frequency=1), 100, main='ACF of residuals of Y4-regression')
pacf(ts(y1res$residuals, frequency=1), 100, main='PACF of residuals of Y4-regression')

# Potential models to check : MA(1), MA(2), AR(1), AR(2), ARMA(1, 1), ARMA(2, 2)

yma1fit = arima(y1res$residuals, order=c(0, 0, 1)) # MA(1)
yma1fit
# Log likelihood : 628.1 | AIC = -1250.3

yma2fit = arima(y1res$residuals, order=c(0, 0, 2)) # MA(2)
yma2fit
# Log likelihood : 632.7 | AIC = -1257.3

yar1fit = arima(y1res$residuals, order=c(1, 0, 0)) # AR(1)
yar1fit
# Log likelihood : 629.3 | AIC = -1252.7

yar2fit = arima(y1res$residuals, order=c(2, 0, 0)) # AR(2)
yar2fit
# Log likelihood : 632.9 | AIC = -1257.8

par(mfrow=c(4, 2))
acf(ts(yma1fit$residuals, frequency=1), 100, main='ACF of residuals of MA(1) of Y4-regression')
pacf(ts(yma1fit$residuals, frequency=1), 100, main='PACF of residuals of MA(1) of Y4-regression')
acf(ts(yma2fit$residuals, frequency=1), 100, main='ACF of residuals of MA(2) of Y4-regression')
pacf(ts(yma2fit$residuals, frequency=1), 100, main='PACF of residuals of MA(2) of Y4-regression')
acf(ts(yar1fit$residuals, frequency=1), 100, main='ACF of residuals of AR(1) of Y4-regression')
pacf(ts(yar1fit$residuals, frequency=1), 100, main='PACF of residuals of AR(1) of Y4-regression')
acf(ts(yar2fit$residuals, frequency=1), 100, main='ACF of residuals of AR(2) of Y4-regression')
pacf(ts(yar2fit$residuals, frequency=1), 100, main='PACF of residuals of AR(2) of Y4-regression')

# We will also check ARMA(1, 1) and ARMA(2, 2) models

yarma1fit = arima(y1res$residuals, order=c(1, 0, 1)) # ARMA(1, 1)
yarma1fit
# Log likelihood : 632.1 | AIC = -1256.1

yarma2fit = arima(y1res$residuals, order=c(2, 0, 2)) # ARMA(2, 2)
yarma2fit
# Log likelihood : 633.1 | AIC = -1254.1

par(mfrow=c(2, 2))
acf(ts(yarma1fit$residuals, frequency=1), 100, main='ACF of residuals of ARMA(1, 1) of Y4-regression')
pacf(ts(yarma1fit$residuals, frequency=1), 100, main='PACF of residuals of ARMA(1, 1) of Y4-regression')
acf(ts(yarma2fit$residuals, frequency=1), 100, main='ACF of residuals of ARMA(2, 2) of Y4-regression')
pacf(ts(yarma2fit$residuals, frequency=1), 100, main='PACF of residuals of ARMA(2, 2) of Y4-regression')

# We will chose the AR(2) to model the residuals due to the highest likelihood and simplicity in contrast to the ARMA models.

#====================#
# Heteroscedasticity #
#====================#

par(mfrow=c(1, 2))
acf(ts(y1res$residuals^2, frequency=1), 100, main='ACF of squared residuals of Y4-regression')
pacf(ts(y1res$residuals^2, frequency=1), 100, main='PACF of squared residuals of Y4-regression')

Box.test(y1res$residuals^2, lag=10) # we reject null, squared errors at lag 10 are not independently distributed

# We will develop ARCH, GARCH models for the squared residuals. We are also using an AR(2) for the mean equation.

yarch1 = garchFit(~arma(2,0) + garch(1, 0), data=y1res$residuals) # ARCH(1) - Normal Distribution
summary(yarch1) 
# Log likelihood : 650.8 | AIC : -6.8

yarch1_t = garchFit(~arma(2,0) + garch(1, 0), data=y1res$residuals, cond.dist="std") # ARCH(1) - Student's-t Distribution
summary(yarch1_t)
# Log likelihood : 653.9 | AIC : -6.8

ygarch1 = garchFit(~arma(2,0) + garch(1, 1), data=y1res$residuals) # GARCH(1, 1) - Normal Distribution
summary(ygarch1) 
# Log likelihood : 654.1 | AIC : -6.9

ygarch1_t = garchFit(~arma(2,0) + garch(1, 1), data=y1res$residuals, cond.dist="std") # GARCH(1, 1) - Normal Student's-t Distribution
summary(ygarch1_t) 
# Log likelihood : 657.8 | AIC : -6.9

# We notice that the GARCH(1, 1) models that follows a normal distribution yields the best results. This is because the errors pass the Shapiro-Wilk 
# normality test, R's are not auto-correlated and R^2's is also not auto-correlated. That means that the residuals of the model behave as white noise
# and our model is valid.

###########
# SUMMARY #
###########

# Regression : we chose x5 and x6 out of 15 different variables to regress Y4
# Autocorrelation : we corrected the auto-correlation of the residuals for the regression with an AR(2) model
# Heteroscedasticity : we corrected the heteroscedasticity of the residuals for the regression with a GARCH(1, 1) model under the normal distribution.

# Efstratios Karypiadis | f3352209 | MSc in Data Science | Fall 2022
