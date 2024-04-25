### Скрипт используется для дэшборда в qlik sense, который показывает кол-во монетизаций клиентов за последний час
### ---------------------------

select
eu.id user_id_back,
eu.dataReg signup_time,
eu.phoneNumber phone,
u.utm_source,
u.campaign,
u.medium,
u.request_url request_url_full,
case when
    	(eu.dataReg >= '2022-06-01' and p.affiliate_id is null and eu.dataReg<'2023-06-01') then u.partner
        when (eu.dataReg >= '2022-06-01' and eu.dataReg<'2023-06-01' and p.affiliate_id is not null) then p.affiliate_id
        else u.partner end as partner_back,
m.monet_date monet_time

from main.ec_users eu

	left join (SELECT
    user_id,
    partner,
    source utm_source,
    campaign,
    medium,
    request_url,
    term keyword
    from user_utms) u on u.user_id = eu.id
    	left join pap_user p on p.user_id = eu.id
        	left join (select ip.user_id, min(ip.date) monet_date from incoming_payments ip group by ip.user_id) m on m.user_id = eu.id
