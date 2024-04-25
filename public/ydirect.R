###Выгрузка расходов и кликов по кампаниям и объявлениям из рекламного кабинета Директа


#a7-yd
#install.packages("ryandexdirect")
print(Sys.time())

library(ryandexdirect)
Login <- "e-16732934" # с 03.03.2021
TokenPath <- "tokens/yandex"
#yadirAuth(Login = Login,  TokenPath = TokenPath)

date.from = Sys.Date()-7
date.to = Sys.Date()-1
#date.from = "2022-12-01"
#date.to = "2022-04-11"
#Sys.Date()-1

a7_yd_report_country_age_vat_v3 <- yadirGetReport(ReportType = "AD_PERFORMANCE_REPORT", 
                                                  DateRangeType = "CUSTOM_DATE", 
                                                  DateFrom = date.from, 
                                                  DateTo = date.to,
                                                  FieldNames = c("Date",
                                                                 "CampaignId",
                                                                 "CampaignName",
                                                                 "AdGroupId",
                                                                 "AdGroupName",
                                                                 "AdId",
                                                                 "LocationOfPresenceName",
                                                                 "Cost",
                                                                 "Impressions",
                                                                 "Clicks"), 
                                                  FilterList = NULL, 
                                                  IncludeVAT = "YES", 
                                                  IncludeDiscount = "NO", 
                                                  Login = Login, 
                                                  TokenPath = TokenPath)


#library(bit64)
# a7_yd_report_countries$CampaignId <- as.integer(a7_yd_report_countries$CampaignId)
# a7_yd_report_countries$AdGroupId <- as.integer(a7_yd_report_countries$AdGroupId)
# a7_yd_report_countries$AdId <- as.integer(a7_yd_report_countries$AdId)
# a7_yd_report_countries$Impressions <- as.integer(a7_yd_report_countries$Impressions)
# a7_yd_report_countries$Clicks <- as.integer(a7_yd_report_countries$Clicks)
# a7_yd_report_countries$Cost <- as.numeric(a7_yd_report_countries$Cost)
# a7_yd_report_countries$LocationOfPresenceName <- as.string(a7_yd_report_countries$LocationOfPresenceName)

#write.csv(a7_yd_report_country_age_vat_v2, file="a7_yd_report_country_age_vat_v2.csv")


#BQ --------
library(bigrquery)
bigrquery::bq_auth(path = "~/git/tokens/bigquery/modern-cipher-186106-eddebc463b58.json")
bq_perform_upload(
  paste(
    "modern-cipher-186106", 
    "advertising_systems", 
    "a7_yd_report_country_age_vat_v3", 
    sep="."),
  a7_yd_report_country_age_vat_v3, 
  create_disposition = "CREATE_IF_NEEDED",
  write_disposition = "WRITE_APPEND" # "WRITE_TRUNCATE") #
)

# clear ---------------------------------------------------------------------
# rm(list = ls())
rm(Login, TokenPath, date.from, date.to, a7_yd_report_country_age_vat_v3)
