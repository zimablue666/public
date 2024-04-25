###Скрипт R, который ищет на корп. гуглодиске предсозданный csv и пушит таблицу в slack. Используется менеджерами для отслеживания информации по срывам консультаций и динамики. 


print('-------------------------')
print(Sys.time()+3*3600)
library("tidyr")
library("dplyr")
# library('slackr')

#-------------
#блок ниже использовался для поиска csv с динамическим именем по дате начала недели. 
#Но впоследствии на корп. гуглдиске что-то сломали и этот csv стал сохраняться в 2 копиях за раз с одинаковым именем. 
#Скрипт на этом этапе выдает ошибку. Т.о. пришлось заменить на файл с единым названием.
date_today = Sys.Date()# '2020-01-01' #
date_format <- date_today - as.numeric(strftime(date_today, "%w")) +1
print(date_format)

date_week <- paste0("name contains ","'Срывы_экспертов_",format(date_format,"%Y-%m-%d"),"'")
print(date_week)

file_name <- paste0("Срывы_экспертов_",format(date_format,"%d.%m.%Y"),".csv")
print(file_name)
#-------------

#-------------------------------------
# vignette('scoped-bot-setup', package = 'slackr')

# ---- Выгружаем csv из гуглдиска ----
print('---- Выгружаем csv из гуглдиска ----')
library("googledrive")
drive_auth(path =  "~/git/tokens/googlesheets/modern-cipher-186106-b376fe48cf4e.json")
gd <- drive_find(q = "name contains 'callsFails-alerts_summary_v3.csv'")

drive_download(gd, type = "csv", overwrite = TRUE)
gd_data <- read.csv(file = toString(gd["name"]))
# file.remove(toString(gd["name"]))

gd_data <- gd_data

# library("lubridate")
# gd_data$weekstart <- parse_date_time(gd_data$weekstart, orders="ymd")
# gd_data$weekend <- parse_date_time(gd_data$weekend, orders="ymd")
#gd_data <- gd_data[order(gd_data$avg,decreasing=TRUE),]

msg <- paste(gd_data)
msg
msg_fails <- paste0('----------------------------------------------','\n',
                    '☎️❌ Общая статистика по % срывов за посл. 5 недель, вкл. текущую')
msg_fails


# ---- Сообщение в slack ----
library(slackr)
token = '***'
#slackr::auth_test(token = token)
if(exists('msg_fails')) {
  slackr_msg(
    txt = msg_fails,
    channel = 'C05Q13SU10E', # Sys.getenv("SLACK_CHANNEL"), # 'C05HRANF6E7'
    username = 'Внимательный Бот', # Sys.getenv("SLACK_USERNAME"),
    #icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
    token = token, # Sys.getenv("SLACK_TOKEN"),
    thread_ts = NULL,
    reply_broadcast = FALSE
  )
}

if(exists('msg')) {
slackr_upload(
  'callsFails-alerts_summary_v3.csv',
  title = NULL,
  initial_comment = NULL,
  token = token,
  channels = '#adviser_fails_alerts',
  thread_ts = NULL
)
}


#----------------ЭКСПЕРТЫ-------------------------
# ---- Выгружаем csv из гуглдиска ----
print('---- Выгружаем csv из гуглдиска ----')
# library("googledrive")
# drive_auth(path =  "~/git/tokens/googlesheets/modern-cipher-186106-b376fe48cf4e.json")
gd_e <- drive_find(q = "name contains 'Срывы_экспертов_alerts_v3.csv'")

drive_download(gd_e, type = "csv", overwrite = TRUE)
gd_data_e <- read.csv(file = toString(gd_e["name"]))
# file.remove(toString(gd["name"]))

gd_data_e <- gd_data_e

msg_e <- paste(gd_data_e)
msg_e
msg_adv <- paste0('----------------------------------------------','\n',
                    '👤❗️Эксперты с % срывов на их стороне от 15% (за текущ. неделю)')
msg_adv


# ---- Сообщение в slack ----
library(slackr)
# token = '***'
#slackr::auth_test(token = token)
if(exists('msg_adv')) {
  slackr_msg(
    txt = msg_adv,
    channel = 'C05Q13SU10E', # Sys.getenv("SLACK_CHANNEL"), # 'C05HRANF6E7'
    username = 'Внимательный Бот', # Sys.getenv("SLACK_USERNAME"),
    #icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
    token = token, # Sys.getenv("SLACK_TOKEN"),
    thread_ts = NULL,
    reply_broadcast = FALSE
  )
}


if(exists('msg_e')) {
  slackr_upload(
    'Срывы_экспертов_alerts_v3.csv',
    title = NULL,
    initial_comment = NULL,
    token = token,
    channels = '#adviser_fails_alerts',
    thread_ts = NULL
  )
}


#----------------ЭКСПЕРТЫ CSV-------------------------
# ---- Выгружаем csv из гуглдиска ----
print('---- Выгружаем csv из гуглдиска ----')
library("googledrive")
# drive_auth(path =  "~/git/tokens/googlesheets/modern-cipher-186106-b376fe48cf4e.json")
#gd_e2 <- drive_find(q = date_week, type = "csv") - для старого файла с динамическим именем
gd_e2 <- drive_find(q = "name contains 'Срывы_экспертов_weekly_v3.csv'")

drive_download(gd_e2, type = "csv", overwrite = TRUE)
gd_data_e2 <- read.csv(file = toString(gd_e2["name"]))
# file.remove(toString(gd["name"]))

gd_data_e2 <- gd_data_e2

msg_e2 <- paste(gd_data_e2)
msg_e2
msg_adv2 <- paste0('----------------------------------------------','\n',
                   '📩 CSV со всеми сорванными заказами "проблемных" экспертов, указанных выше (за текущ. неделю)','\n',
                   'Этот файл также можешь найти по названию на общем диске https://drive.google.com/drive/u/2/folders/195DU5FBcgVECB8pwoncROEqSI6PfMSr1 и открыть как гуглдоку')
msg_adv2


# ---- Сообщение в slack ----
library(slackr)
# token = '***'
#slackr::auth_test(token = token)
if(exists('msg_adv2')) {
  slackr_msg(
    txt = msg_adv2,
    channel = 'C05Q13SU10E', # Sys.getenv("SLACK_CHANNEL"), # 'C05HRANF6E7'
    username = 'Внимательный Бот', # Sys.getenv("SLACK_USERNAME"),
    #icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
    token = token, # Sys.getenv("SLACK_TOKEN"),
    thread_ts = NULL,
    reply_broadcast = FALSE
  )
}


if(exists('msg_e2')) {
  slackr_upload(
    # file_name,
    'Срывы_экспертов_weekly_v3.csv',
    title = NULL,
    initial_comment = NULL,
    token = token,
    channels = '#adviser_fails_alerts',
    thread_ts = NULL
  )
}


# # ---- Удаляем ненужное ----
rm(list = ls())
print('---- Молодец! ----')
