###Выгрузка несэмплированных данных их Я.метрики по фильтру на канал direct

#a7-m
# settings ---------------------------------------------------------------------
now <- Sys.time()+3*3600
now

#install.packages('rym')
library(rym)
login        = "astro7-ip"
token.path   = "~/tokens/yandex"
rym_auth(login = login, token.path = token.path)
# rym_auth()
# "astro7-ip.rymAuth.RData" <- token

counter      = 570115 #номер счетчика

date.from    = Sys.Date()-1# '2020-01-01' #
date.to      = Sys.Date()-1# '2020-12-31' #


# report ---------------------------------------------------------------------

#TEST-----------------------------------------------
reportdirect <- rym_get_data(counters = counter,
                             date.from  =  date.from,
                             date.to    =  date.to,
                             
                             dimensions = "ym:s:date",
                             
                             metrics    = "ym:s:pageviews,
                        ym:s:visits,
                        ym:s:users",
                             
                             filters    = "ym:pv:URLParamNameAndValue=='partner=direct'",
                             #sort      = "-ym:s:date",
                             #ym:pv:URLDomain=='astro7.ru'
                             #ym:pv:URL=*'astro7.'
                             #ym:pv:URL=='*astro7.*'
                             #ym:pv:URL=*'*astro7.*'
                             
                             accuracy   = "full",
                             login      = login,
                             token.path = token.path)
#lang = "ru")

reportdirect$partner             <-'Yandex Direct'
#report3$Отказы              <-report3$Визиты*report3$Отказы
#report3$'Глубина просмотра' <-report3$Визиты*report3$'Глубина просмотра'
#report3$'Время на сайте'    <-as.numeric(report3$Визиты*report3$'Время на сайте')


# содержимое окончательного репорта-----------------------------------------------
library(sqldf)

report <- sqldf("
              SELECT DATE(`Дата визита`) as date, partner as partner,
              sum(Просмотры) as pageviews,
              sum(Визиты) as visits,
              sum(Посетители) as users
              FROM reportdirect
              GROUP BY `Дата визита`
              ")

#report$date <- date(report$date)




# bigrquery ---------------------------------------------------------------------
library(bigrquery)
bigrquery::bq_auth(path = "~/tokens/bigquery/modern-cipher-186106-eddebc463b58.json")

bq_perform_upload(
  paste(
    "modern-cipher-186106", 
    "advertising_systems", 
    "ym_direct", 
    sep="."),
  report, 
  #"modern-cipher-186106", 
  create_disposition = "CREATE_IF_NEEDED", 
  write_disposition = "WRITE_APPEND") 
#"WRITE_TRUNCATE") #


# clear ---------------------------------------------------------------------
# rm(list = ls())
# rm(token)
rm(login, token.path, counter, date.from, date.to, reportdirect, report)
