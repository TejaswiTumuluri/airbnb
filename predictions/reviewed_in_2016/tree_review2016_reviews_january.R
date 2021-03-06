#to create and generate the tree for if there was a review or not in 2016
#for the Januray cohort and generate the ROC curve
#using price, ammenities, verifications, and room type

library(rpart)
library(rpart.plot)
library(readr)
library(dplyr)
library(ROCR)

#load the test and train data
#this file was created by  "create_test_train_january_cohort.R"
load("jan_test_train.RData")

set.seed(123)

#reviews data
tree_rv <- rpart(has_reviews_2016 ~ first_review_year + last_review_year +
                   num_as_of_2015 + num_reviews_in_2015 + has_reviews_2015 +
                   first_review_month_2015 + last_review_month_2015 + 
                   last_rating, 
                 data = jan_train, 
                 control = rpart.control(cp = 0.001))
printcp(tree_rv)
bestcp_rv <- tree_rv$cptable[which.min(tree_rv$cptable[,"xerror"]), "CP"]
#prune tree using best cp
tree_pruned_rv <- prune(tree_rv, cp = bestcp_rv)

#plots
plot(tree_pruned_rv, uniform = TRUE)
text(tree_pruned_rv, cex = 0.8, use.n = TRUE, xpd = TRUE)
png(file = "../figures/reviews2016_jan_rv.png")
prp(tree_pruned_rv, main = "Predicting Reviews in 2016 for January Cohort
    Using Reviews", faclen = 0, cex = 0.8, extra = 1)
dev.off()

#use the tree_pruned_rf to predict on the test set
rv_predict <- predict(tree_pruned_rv, jan_test)
ROCR_rv <- prediction(rv_predict, jan_test$has_reviews_2016)
roc_perf_rv <- performance(ROCR_rv, measure = "tpr", x.measure = "fpr")
png(file = "../figures/reviews2016_jan_rv_ROC.png")
plot(roc_perf_rv, main = "ROC Predicting Reviews in 2016 for January Cohort Using
     Reviews", sub = "AUC = 0.914")
abline(a=0, b= 1)
dev.off()
auc_rv <- performance(ROCR_rv, measure = "auc")
auc_rv@y.values
#0.91399

#add in price to reviews
tree_rv_p <- rpart(has_reviews_2016 ~ first_review_year + last_review_year +
                     num_as_of_2015 + num_reviews_in_2015 + has_reviews_2015 +
                     first_review_month_2015 + last_review_month_2015 + 
                     last_rating + min_price + 
                     max_price + mean_price, 
                   data = jan_train, 
                   control = rpart.control(cp = 0.001))
printcp(tree_rv_p)
bestcp_rv_p<- tree_rv_p$cptable[which.min(tree_rv_p$cptable[,"xerror"]), "CP"]
#prune tree using best cp
tree_pruned_rv_p <- prune(tree_rv_p, cp = bestcp_rv_p)

#plots
plot(tree_pruned_rv_p, uniform = TRUE)
text(tree_pruned_rv_p, cex = 0.8, use.n = TRUE, xpd = TRUE)
prp(tree_pruned_rv_p, faclen = 0, cex = 0.8, extra = 1)

#use the tree_pruned_rf to predict on the test set
rv_p_predict <- predict(tree_pruned_rv_p, jan_test)
ROCR_rv_p <- prediction(rv_p_predict, jan_test$has_reviews_2016)
roc_perf_rv_p <- performance(ROCR_rv_p, measure = "tpr", x.measure = "fpr")
plot(roc_perf_rv_p)
abline(a=0, b= 1)
auc_rv_p <- performance(ROCR_rv_p, measure = "auc")
auc_rv_p@y.values
#0.91399

#add in ammenities, verification, and room type
tree_all <- rpart(has_reviews_2016 ~ min_price + 
                    max_price + mean_price + TV + Internet + Wireless.Internet +
                    Air.Conditioning + Kitchen + Heating + Family.Kid.Friendly + 
                    Smoke.Detector + Carbon.Monoxide.Detector + Essentials +
                    Shampoo + Cable.TV + Free.Parking.on.Premises + Breakfast +
                    Pets.live.on.this.property + Dog.s. + First.Aid.Kit + 
                    Buzzer.Wireless.Intercom + Washer + Dryer + Pets.Allowed + 
                    Gym + Safety.Card + Fire.Extinguisher + Wheelchair.Accessible +
                    Cat.s. + Indoor.Fireplace + Suitable.for.Events + Doorman + 
                    Hot.Tub + Elevator.in.Building + Pool + Smoking.Allowed + 
                    Other.pet.s. + Washer...Dryer + Lock.on.Bedroom.Door + 
                    X24.Hour.Check.in + Hangers + Hair.Dryer + Iron + 
                    Laptop.Friendly.Workspace + 
                    translation.missing..en.hosting_amenity_49 + 
                    translation.missing..en.hosting_amenity_50 + email + phone +
                    facebook + reviews + kba + google + jumio + sent_id + 
                    linkedin +
                    manual_offline + manual_online + weibo + photographer + 
                    None +
                    amex + verifications_count + room_type, 
                  data = jan_train, 
                  control = rpart.control(cp = 0.01))
printcp(tree_all)
bestcp_all<- tree_all$cptable[which.min(tree_all$cptable[,"xerror"]), "CP"]
#prune tree using best cp
tree_pruned_all <- prune(tree_all, cp = bestcp_all)

#plots
plot(tree_pruned_all, uniform = TRUE)
text(tree_pruned_all, cex = 0.8, use.n = TRUE, xpd = TRUE)
png(file = "../figures/reviews2016_jan_p_amen_ver.png")
prp(tree_pruned_all, main = "Predicting Reviews in 2016 for January Cohort
Using Amenities, Price, and Verifications", faclen = 0, cex = 0.8, extra = 1)
dev.off()


#use the tree_pruned_rf to predict on the test set
all_predict <- predict(tree_pruned_all, jan_test)
ROCR_all <- prediction(all_predict, jan_test$has_reviews_2016)
roc_perf_all <- performance(ROCR_all, measure = "tpr", x.measure = "fpr")
png(file = "../figures/reviews2016_jan_p_amen_ver_ROC.png")
plot(roc_perf_all, main = "ROC for Predicting Reviews in 2016 for the January Cohort
     Using Amenities, Price, and Verifications", sub = "AUC = 0.735")
abline(a=0, b= 1)
dev.off()
auc_all <- performance(ROCR_all, measure = "auc")
auc_all@y.values
#0.7353522


