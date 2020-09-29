t0 = Sys.time()
setwd('D:/Projects/余萍走神/睡眠和走神')
model_data <- read.csv('modelInput.csv', header = TRUE);
head(model_data)
# 排列 psqi,mw, pos, neg

library("lavaan")

#perpration model data
psqi <- model_data[,1]
poslinks <- model_data[,3]
mw <- model_data[,2]

neglinks <- model_data[,4]
fullData <- data.frame(X = psqi, Y = mw, M1 = poslinks, M2 = neglinks)

# set model
# contrast test whether differ significantly
# test direct effect to see whether is fully mediation

multipleMediation <- '
Y ~ b1* M1 + b2*M2 + c*X
M1~ a1*X
M2~ a2 * X
indirect1 := a1*b1
indirect2 := a2 * b2
contrast := indirect1-indirect2 
dirtect := c
total := c + (a1 * b1) + (a2 * b2)
M1 ~~ M2 
'

fit <- sem(model = multipleMediation, data = fullData, se = 'bootstrap', bootstrap = 5000)
summary(fit)
