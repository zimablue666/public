###Выгрузка поисковых запросов из рекламного кабинета Директа - с кликами и т.п.

#a7-yd
#install.packages("ryandexdirect")
print(Sys.time())

library(ryandexdirect)
Login <- "e-16732934" # с 03.03.2021
TokenPath <- "tokens/yandex"
#yadirAuth(Login = Login,  TokenPath = TokenPath)

date.from = "2023-01-01"
date.to = "2023-04-16"
#start.date = "2022-12-01"
#end.date = "2022-04-11"
#Sys.Date()-1

yd_search_queries <- yadirGetReport(ReportType = "SEARCH_QUERY_PERFORMANCE_REPORT", 
                                                  DateRangeType = "CUSTOM_DATE", 
                                                  DateFrom = date.from, 
                                                  DateTo = date.to,
                                                  FieldNames = c("Date",
                                                                 #"CampaignId",
                                                                 #"CampaignName",
                                                                 #"AdGroupId",
                                                                 #"AdId",
                                                                 #"LocationOfPresenceName",
                                                                 #"Keyword",
                                                                 "Query",
                                                                 "Impressions",
                                                                 "Clicks"), 
                                                  
                                                  #FilterList = "Keyword", 
                                                  #IncludeVAT = "YES", 
                                                  #IncludeDiscount = "NO", 
                                                  Login = Login, 
                                                  TokenPath = TokenPath)


# содержимое окончательного репорта-----------------------------------------------
library(sqldf)

report <- sqldf("
              SELECT Date,
              Query as Search_query,
              sum(Impressions) as Impressions,
              sum(Clicks) as Clicks

              FROM yd_search_queries
              GROUP BY Date, Query
              ")

#library(bit64)
# a7_yd_report_countries$CampaignId <- as.integer(a7_yd_report_countries$CampaignId)
# a7_yd_report_countries$AdGroupId <- as.integer(a7_yd_report_countries$AdGroupId)
# a7_yd_report_countries$AdId <- as.integer(a7_yd_report_countries$AdId)
# a7_yd_report_countries$Impressions <- as.integer(a7_yd_report_countries$Impressions)
# a7_yd_report_countries$Clicks <- as.integer(a7_yd_report_countries$Clicks)
# a7_yd_report_countries$Cost <- as.numeric(a7_yd_report_countries$Cost)
# a7_yd_report_countries$LocationOfPresenceName <- as.string(a7_yd_report_countries$LocationOfPresenceName)

# bigrquery ---------------------------------------------------------------------
library(bigrquery)
bigrquery::bq_auth(path = "~/tokens/bigquery/modern-cipher-186106-eddebc463b58.json")

bq_perform_upload(
  paste(
    "modern-cipher-186106", 
    "advertising_systems", 
    "a7_yd_search_queries_v2", 
    sep="."),
  report, 
  #"modern-cipher-186106", 
  create_disposition = "CREATE_IF_NEEDED", 
  write_disposition = "WRITE_APPEND") 
#"WRITE_TRUNCATE") #

# clear ---------------------------------------------------------------------
# rm(list = ls())
rm(Login, TokenPath, date.from, date.to, yd_search_queries, report)
