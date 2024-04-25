###Скрипт R, который выгружает данные из опредленных таблиц airtable (ретаргет) и заливает в bq


# ---- Подключаем библиотеки и AT ----
# devtools::install_github("bergant/airtabler")
library("lubridate")
library(airtabler)
Sys.setenv("AIRTABLE_API_KEY"="***")

AIRTABLE_CONNECT <- 
  airtable(
    base = "appi3x2o7q4ptPyUJ", 
    tables = c("tbldwTClhPYVwq0so", "tbltldZe0KaLZt6Qz", "tbllNKfjCwWLZnCsX")
  )


# ---- Грузим данные За все время (по-умолчанию) ----
at_table <- AIRTABLE_CONNECT$"tbldwTClhPYVwq0so"$select_all(sort = list(list(field="Created", direction = "desc")))

# ---- Форматируем, переименовываем под BQ ----
# ------ at_table ----
TABLE <- at_table
#TABLE <- subset(TABLE, select = -c(Phone))

TABLE$Created <- parse_date_time(TABLE$Created, orders="ymd_HMS")

names(TABLE)[names(TABLE) == 'fx_phone'] <- 'phone'
names(TABLE)[names(TABLE) == 'Результат'] <- 'result'
names(TABLE)[names(TABLE) == 'Оплата'] <- 'payment'
names(TABLE)[names(TABLE) == 'Страна'] <- 'country'
names(TABLE)[names(TABLE) == 'Мессенджер'] <- 'messenger'
names(TABLE)[names(TABLE) == 'partner'] <- 'partner'
names(TABLE)[names(TABLE) == 'campaign'] <- 'campaign'
names(TABLE)[names(TABLE) == 'source'] <- 'source'
names(TABLE)[names(TABLE) == 'problem'] <- 'problem'

TABLE <- subset(TABLE, select = c(Created,
                                  phone, 
                                  result, 
                                  payment, 
                                  country, 
                                  messenger, 
                                  partner, 
                                  campaign, 
                                  source, 
                                  problem))


#----------------------------------------------------------------
#----------------------------------------------------------------
at_table2 <- AIRTABLE_CONNECT$"tbltldZe0KaLZt6Qz"$select_all(sort = list(list(field="Created", direction = "desc")))

# ---- Форматируем, переименовываем под BQ ----
# ------ at_table ----
TABLE2 <- at_table2
#TABLE2 <- subset(TABLE2, select = -c(Phone))

TABLE2$Created <- parse_date_time(TABLE2$Created, orders="ymd_HMS")

names(TABLE2)[names(TABLE2) == 'fx_phone'] <- 'phone'
names(TABLE2)[names(TABLE2) == 'Результат'] <- 'result'
names(TABLE2)[names(TABLE2) == 'Оплата'] <- 'payment'
names(TABLE2)[names(TABLE2) == 'Страна'] <- 'country'
names(TABLE2)[names(TABLE2) == 'Мессенджер'] <- 'messenger'
names(TABLE2)[names(TABLE2) == 'partner'] <- 'partner'
names(TABLE2)[names(TABLE2) == 'campaign'] <- 'campaign'
names(TABLE2)[names(TABLE2) == 'source'] <- 'source'
names(TABLE2)[names(TABLE2) == 'problem'] <- 'problem'

TABLE2 <- subset(TABLE2, select = c(Created,
                                  phone, 
                                  result, 
                                  payment, 
                                  country, 
                                  messenger, 
                                  partner, 
                                  campaign, 
                                  source, 
                                  problem))


#----------------------------------------------------------------
#----------------------------------------------------------------
at_table3 <- AIRTABLE_CONNECT$"tbllNKfjCwWLZnCsX"$select_all(sort = list(list(field="Created", direction = "desc")))

# ---- Форматируем, переименовываем под BQ ----
# ------ at_table ----
TABLE3 <- at_table3

TABLE3$Created <- parse_date_time(TABLE3$Created, orders="ymd_HMS")

names(TABLE3)[names(TABLE3) == 'fx_phone'] <- 'phone'
names(TABLE3)[names(TABLE3) == 'Результат'] <- 'result'
names(TABLE3)[names(TABLE3) == 'Оплата'] <- 'payment'
names(TABLE3)[names(TABLE3) == 'partner_new'] <- 'partner'
names(TABLE3)[names(TABLE3) == 'utm_campaign'] <- 'campaign'
names(TABLE3)[names(TABLE3) == 'utm_source'] <- 'source'

TABLE3 <- subset(TABLE3, select = c(Created,
                                    phone, 
                                    result, 
                                    payment, 
                                    partner, 
                                    campaign, 
                                    source)) 


#----------------------------------------------------------------
#----------------------------------------------------------------
# ---- Грузим в BQ  ----
library(bigrquery)
bigrquery::bq_auth(path = "~/git/tokens/bigquery/modern-cipher-186106-eddebc463b58.json")

# ------ astro7_21_bot ----
bq_perform_upload(
  paste(
    "modern-cipher-186106", 
    "airtable", 
    "AT_retarget_2023", 
    sep="."),
  TABLE, 
  create_disposition = "CREATE_IF_NEEDED",
  write_disposition = "WRITE_TRUNCATE" # "WRITE_APPEND" # 
)

#----------------------------------------------------------------
#----------------------------------------------------------------
# ---- Грузим в BQ  ----
library(bigrquery)
bigrquery::bq_auth(path = "~/git/tokens/bigquery/modern-cipher-186106-eddebc463b58.json")

# ------ astro7_21_bot ----
bq_perform_upload(
  paste(
    "modern-cipher-186106", 
    "airtable", 
    "AT_retarget_2023_2", 
    sep="."),
  TABLE2, 
  create_disposition = "CREATE_IF_NEEDED",
  write_disposition = "WRITE_TRUNCATE" # "WRITE_APPEND" # 
)


#----------------------------------------------------------------
#----------------------------------------------------------------
# ---- Грузим в BQ  ----
library(bigrquery)
bigrquery::bq_auth(path = "~/git/tokens/bigquery/modern-cipher-186106-eddebc463b58.json")

# ------ astro7_21_bot ----
bq_perform_upload(
  paste(
    "modern-cipher-186106", 
    "airtable", 
    "AT_retarget_2023_3", 
    sep="."),
  TABLE3, 
  create_disposition = "CREATE_IF_NEEDED",
  write_disposition = "WRITE_TRUNCATE" # "WRITE_APPEND" # 
)

# ---- Удаляем ненужное ----
# rm(list = ls())
rm(AIRTABLE_CONNECT, TABLE, TABLE2, TABLE3, at_table, at_table2, at_table3)
