###Скрипт для bigquery
### Используется среди прочих как последний шаг в формировании таблицы с приоритизацией провайдеров связи для бота телефонии - сортировка по цене внутри каждого кода региона. 

select *, 
ROW_NUMBER() OVER (PARTITION BY f2.raw_code_id order by f2.price_var asc) as code_rank 
from (SELECT distinct *
FROM 

(select a.raw_code_id, a.raw_code, a.destination_aggr, a.provider_var, a.max_provider_rank,
b.code_id_var, b.code_var, b. price_var, b.delta_price_var from

(select raw_code_id, raw_code, destination_aggr, provider_var, max(code_var_len) as max_provider_rank from

(select raw_code_id, raw_code, destination_aggr, code_id_var, code_var, code_var_len, price_var, delta_price_var, code_rank, provider_var,
count(provider_var) OVER (PARTITION BY raw_code_id, provider_var) as provider_rank
FROM `modern-cipher-186106.telephony.sorted_tech_2023-1109` 

group by raw_code_id, raw_code, destination_aggr, code_id_var, code_var, code_var_len, price_var, delta_price_var, code_rank, provider_var
order by 1,11 asc) x

group by raw_code_id, raw_code, destination_aggr, provider_var) as a

  left join `modern-cipher-186106.telephony.sorted_tech_2023-1109` as b on b.raw_code_id= a.raw_code_id and b.provider_var = a.provider_var and b.code_var_len = a.max_provider_rank

order by 1,8 asc) f

where price_var>0
order by raw_code_id, price_var asc) f2

order by 1,8 asc
