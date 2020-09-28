t0 = Sys.time()
setwd('D:/Projects/余萍走神/睡眠和走神')
model_data <- read.csv('modelInput.csv', header = TRUE);
head(model_data)

# 中介模型

#model_0 <- lm(psqi ~ meq, model_data)

model_m <- lm(mediator_pos ~ psqi_scores, model_data)
summary(model_m)
confint.lm(model_m) # 回归系数的置信区间
model_Y <- lm(mw_scores ~ psqi_scores + mediator_pos, model_data)
#summary(model_0)

#summary(model_Y)

# 使用library(mediation) 中介分析
library(mediation)

#contcont <- mediate(model_m,model_Y,sims=1000, treat = 'meq', mediator = 'fcz')
#summary(b)
#summary(c)
#summary(contcont)
#正相关的5个连接均值作为mediator
med <- mediate(model_m,model_Y, boot = TRUE, treat = "psqi_scores", mediator = "mediator_pos", sims = 10000)
summary(med)
plot(med)

#负相关的5个连接均值作为mediator

model_m <- lm(mediator_neg ~ psqi_scores, model_data)
summary(model_m)
confint.lm(model_m) # 回归系数的置信区间
model_Y <- lm(mw_scores ~ psqi_scores + mediator_neg, model_data)
med <- mediate(model_m,model_Y, boot = TRUE, treat = "psqi_scores", mediator = "mediator_neg", sims = 10000)
summary(med)
plot(med)

t1 = Sys.time()
time_cost = t1 - t0
print(time_cost)

## reverse validation
model_m <- lm(fcz ~ psqi, model_data)
model_Y <- lm(meq ~ psqi + fcz, model_data)
med <- mediate(model_m,model_Y, boot = TRUE, treat = "psqi", mediator = "fcz", sims = 5000)
summary(med)