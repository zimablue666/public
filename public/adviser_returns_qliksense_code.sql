### Заказы клеинтов по экспертам и типам консультаций. Используется в дэшборде qlik sense, который считает возвраты клиентов к эксперты, с которым была совершены 1-я консультация. 
### ---------------------------

SELECT
sub_u.id as user_id,
sub_u.dataReg as user_dateReg,
sub_calls.startTime as order_date,
sub_calls.maxDuration as booked_dur,
sub_calls.duration as fact_dur,
bt.amount/100 as order_price,
sub_a.id as adviser_id,
if (sub_calls.startTime is not null,'call','-') as order_type


from ec_orders40 sub_calls
	left join ec_users sub_u on sub_u.uid = sub_calls.custUId
    	left join ec_advisers sub_a on sub_a.uid = sub_calls.advUId
        	left join billing_transactions bt on bt.referer_id = sub_calls.id and bt.referer_type='PHONE_ORDER' and bt.type ='WITHDRAWAL'

where sub_calls.status = 'EXECUTED' AND sub_calls.billingType <> 'g' AND sub_calls.bonus =0 AND sub_calls.bonus_loyalty = 0  and sub_u.id>0
//and sub_calls.startTime>= (curdate() - interval 90 day)

union ALL
SELECT
sub_text_o.user_id,
sub_u2.dataReg as user_dateReg,
sub_text_o.created_at order_date,
'-' as booked_dur,
'-' as fact_dur,
bt2.amount/100  as order_price,
sub_text_o.adviser_id,
if(sub_text_o.created_at is not null,'extra','-') order_type

from extra_orders sub_text_o
	left join ec_users sub_u2 on sub_text_o.user_id = sub_u2.id
    	left join ec_advisers sub_a2 on sub_a2.id = sub_text_o.adviser_id
			left join billing_transactions bt2 on bt2.referer_id = sub_text_o.id and bt2.referer_type='EXTRA_ORDER' and bt2.type ='WITHDRAWAL'  

where 
// sub_text_o.created_at>= (curdate() - interval 90 day) and 
(sub_text_o.status = 'performed' or sub_text_o.status = 'closed') and sub_text_o.user_id>0

union ALL
SELECT
sub_chat.user_id,
sub_u3.dataReg as user_dateReg,
sub_chat.start_time order_date,
sub_chat.max_duration booked_dur,
sub_chat.duration fact_dur,
bt3.amount/100  as order_price,
sub_chat.adviser_id,
if(sub_chat.start_time is not null,'chat','-') order_type

from chat_sessions sub_chat
	left join ec_users sub_u3 on sub_u3.id = sub_chat.user_id
    	left join ec_advisers sub_a3 on sub_a3.id = sub_chat.adviser_id
        	left join billing_transactions bt3 on bt3.referer_id = sub_chat.id and bt3.referer_type='CHAT' and bt3.type ='WITHDRAWAL'

where 
// sub_chat.start_time>= (curdate() - interval 90 day) and 
sub_chat.end_time is not null and sub_chat.user_id>0


union all
select
ao.user_id user_id,
sub_u4.dataReg as user_dateReg,
ao.updated_at order_date,
'-' booked_dur,
ao.duration/60 fact_dur,
bt4.amount/100 order_price,
ao.adviser_id adviser_id,
'audio_extra' order_type

from audio_orders ao 
	left join billing_transactions bt4 on bt4.referer_id = ao.id and bt4.referer_type='AUDIO_ORDER' and bt4.type ='WITHDRAWAL'
    	left join ec_users sub_u4 on sub_u4.id = ao.user_id
    
where ao.status in ('closed','process') and ao.created_at>='2023-11-01' and ao.type='paid'
and ao.adviser_id<>299

order by 1,4;
