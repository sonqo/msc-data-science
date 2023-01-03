# Efstratios Karypiadis | f3352209 | MSc in Data Science | Fall 2022

library(vcd)
library(MASS)
library(Rmisc)
library(PropCIs)

##############
# Exercise 1 #
##############

ch_data <- read.csv('./cholesterol.txt', header=TRUE, sep=' ')

# A: 99% confidence interval for cholesterol values
CI(ch_data$Cholesterol, 0.99)

# B: 95% confidence interval for cholesterol values per drug
CI(ch_data[ch_data$Drug == 'A', "Cholesterol"], 0.95)
CI(ch_data[ch_data$Drug == 'B', "Cholesterol"], 0.95)

# C: 90% confidence interval for mean difference of cholesterol between drugs
t.test(Cholesterol~Drug, data=ch_data, conf.level=0.90)

# D: hypothesis testing for means of cholesterol values
t.test(Cholesterol~Drug, data=ch_data, alternative='less')

# E: hypothesis testing for equality of variances of cholesterol
var.test(Glucose~Drug, data=ch_data)

# F: hypothesis testing for glucose side effects between drugs
t.test(Glucose~Drug, data=ch_data)

# G: 95% confidence interval for proportion of myalgia symptoms
true <- nrow(ch_data[ch_data$Myalgia == 'Yes', ])
total <- nrow(ch_data)
prop.test(true, total, p=true/total, conf.level=0.95)

# H: hypothesis testing for proportion of myalgia symptoms being greater than 5%
prop.test(true, total, p=0.05, alternative='greater')

# I: test of independence for drug and myalgia symptoms
chisq.test(ch_data$Drug, ch_data$Myalgia)

# J: 95% confidence interval for mean difference of glucose for myalgia groups
t.test(Glucose~Myalgia, data=ch_data, conf.level=0.95)

##############
# Exercise 2 #
##############

data <- read.csv('./data.txt', header=TRUE, sep=' ')

# A
par(mfrow=c(2, 3))
boxplot(X1~factor(W), data=data, main='X1 continuous wrt to W', xlab=' ', ylab=' ')
boxplot(X2~factor(W), data=data, main='X2 continuous wrt to W', xlab=' ', ylab=' ')
boxplot(X3~factor(W), data=data, main='X3 continuous wrt to W', xlab=' ', ylab=' ')
boxplot(X4~factor(W), data=data, main='X4 continuous wrt to W', xlab=' ', ylab=' ')
boxplot(Y~factor(W), data=data, main='Y continuous wrt to W', xlab=' ', ylab=' ')

par(mfrow=c(1,1))

fit_x1 <- aov(X1~factor(W), data=data)
summary(fit_x1)
qqnorm(fit_x1$residuals, xlab=' ', ylab=' ')
qqline(fit_x1$residuals, col='red')
shapiro.test(fit_x1$residuals)
bartlett.test(X1~factor(W), data=data)
fligner.test(X1~factor(W), data=data)

fit_x2 <- aov(X2~factor(W), data=data)
summary(fit_x2)
qqnorm(fit_x2$residuals, xlab=' ', ylab=' ')
qqline(fit_x2$residuals, col='red')
shapiro.test(fit_x2$residuals)
bartlett.test(X2~factor(W), data=data)
fligner.test(X2~factor(W), data=data)

fit_x3 <- aov(X3~factor(W), data=data)
summary(fit_x3)
qqnorm(fit_x3$residuals, xlab=' ', ylab=' ')
qqline(fit_x3$residuals, col='red')
shapiro.test(fit_x3$residuals)
bartlett.test(X3~factor(W), data=data)
fligner.test(X3~factor(W), data=data)

fit_x4 <- aov(X4~factor(W), data=data)
summary(fit_x4)
qqnorm(fit_x4$residuals, xlab=' ', ylab=' ')
qqline(fit_x4$residuals, col='red')
shapiro.test(fit_x4$residuals)
bartlett.test(X4~factor(W), data=data)
fligner.test(X4~factor(W), data=data)

fit_y <- aov(Y~factor(W), data=data)
summary(fit_y)
qqnorm(fit_y$residuals, xlab=' ', ylab=' ')
qqline(fit_y$residuals, col='red')
shapiro.test(fit_y$residuals)
bartlett.test(Y~factor(W), data=data)
fligner.test(Y~factor(W), data=data)

# B
pairs(data[,1:5], pch = 21, bg=c("red", "green3", "blue")[factor(data$W)], lower.panel=NULL)
par(xpd = TRUE)
legend('bottomleft', fill=c("red", "green3", "blue"), legend=c(levels(factor(data$W))))

# C
reg_x4 <- lm(data$Y~data$X4)
summary(reg_x4)

# D:
X1 <- data$X1
X2 <- data$X2
X3 <- data$X3
X4 <- data$X4
W <- data$W
Y <- data$Y
reg <- lm(Y~X1+X2+X3+X4+W+X1*W+X2*W+X3*W+X4*W)
summary(reg)

# E
qqnorm(reg$residuals, xlab=' ', ylab=' ')
qqline(reg$residuals, col='red')
shapiro.test(reg$residuals)
Box.test(reg$residuals)

# F
stepBE <- step(reg, scope=list(lower=~1, upper= ~X1+X2+X3+X4+W+X1*W+X2*W+X3*W+X4*W), direction = 'backward')

# G
X1 <- c(120)
X2 <- c(30)
X3 <- c(10)
X4 <- c(90)
W <- c('B')
test <- data.frame(X1, X2, X3, X4, W)
predict(stepBE, newdata=test, interval='confidence', level=0.95)

# H
data$Z <- cut(data$X4, breaks=3, labels=c('Q1', 'Q2', 'Q3'))
struct <- structable(~ Z + W, data = data)
mosaic(struct, direction = "v", pop = FALSE)
labeling_cells(text = as.table(struct), margin = 0)(as.table(struct))

# I
W <- data$W
Z <- data$Z
fit_Z <- aov(Y~W+Z+W:Z)
summary(fit_Z)

par(mfrow=c(1,2))
qqnorm(fit_Z$residuals, xlab=' ', ylab=' ')
qqline(fit_Z$residuals, col='red')
plot(fit_Z, 1)
shapiro.test(fit_Z$residuals)

# Efstratios Karypiadis | f3352209 | MSc in Data Science | Fall 2022