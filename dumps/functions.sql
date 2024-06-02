-- ========================================================================================================================
-- ========================================================================================================================
-- ========================================================================================================================

-- Представления

create view `v_employees` as
select 
    e.id,
    e.lastname,
    e.name,
    e.secondname,
    group_concat(w.name separator ', ') as `posts`,
    e.hired_at,
    e.fired_at
from `employees_posts` as p
left join `employees` as e on e.id = p.employee_id
left join `work_posts` as w on w.id = p.post_id
group by e.id;

create view `v_devices` as 
select
    d.id,
    d.name,
    d.description,
    t.name as `type`,
    p.name as `producer`,
    d.price,
    d.created_at,
    d.deleted_at
from `devices` as d
left join `device_types` as t on t.id = d.type_id
left join `device_producers` as p on p.id = d.producer_id;

create view `v_device_models` as
select
    m.id,
    m.model_number,
    d.name as `device`,
    s.address as `storage`,
    m.sold_at
from `device_models` as m
left join `devices` as d on d.id = m.device_id
left join `storages` as s on s.id = m.storage_id;

create view `v_tariffs` as
select
    t.id,
    t.name,
    t.description as `description (MBit/s)`,
    t.internet_speed,
    count(distinct ct.id) as `channels_amount`,
    count(distinct mt.id) as `movies_amount`,
    t.price    
from `tariffs` as t
left join `channels_tariffs` as ct on t.id = ct.tariff_id
left join `movies_tariffs` as mt on t.id = mt.tariff_id
group by t.id;

-- ========================================================================================================================
-- ========================================================================================================================
-- ========================================================================================================================










-- ========================================================================================================================
-- ========================================================================================================================
-- ========================================================================================================================

-- Процедура по изменению баланса пользователя с указанием типа операции

delimiter //

drop procedure if exists p_change_balance//
create procedure if not exists p_change_balance(
    in userId int(10) unsigned, 
    in typeId int(10) unsigned, 
    in diff decimal(10,2))
process:begin
    declare checkId int;
    declare oldBalance decimal(10,2);

    select id, balance into checkId, oldBalance from `users` where id = userId and deleted_at is null limit 1;
    if isnull(checkId) then
        select 'No user with such id' as `Error`;
        leave process;
    end if;

    select id into checkId from `payment_types` where id = typeId and deleted_at is null limit 1;
    if isnull(checkId) then
        select 'No type with such id' as `Error`;
        leave process;
    end if;

    if oldBalance + diff < 0 then
        select 'Final user\'s balance is below 0' as `Error`;
        leave process;
    end if;

    update `users`
        set balance = balance + diff
        where id = userId
        limit 1;

    insert into `balance_changes_log`(`user_id`, `type_id`, `sum`, `old_balance`, `new_balance`, `completed_at`) values
        (userId, typeId, diff, oldBalance, oldBalance + diff, now());

end//

delimiter ;

-- ========================================================================================================================
-- ========================================================================================================================
-- ========================================================================================================================














-- ========================================================================================================================
-- ========================================================================================================================
-- ========================================================================================================================

-- Процедуры, связанные с таблицами девайсов (добавление заказа, его удаление и доставка по заказу)

delimiter //
drop procedure if exists p_order_devices//
create procedure if not exists p_order_devices(
    in userId int(10) unsigned,
    in deviceId int(10) unsigned,
    in amount int(10) unsigned
)
process:begin
    declare outId int;
    declare outBalance decimal(10,2);
    declare outPrice decimal(10,2);
    declare oldBalance decimal(10,2);

    select id, balance into outId, outBalance from `users` where id = userId and deleted_at is null limit 1;

    if isnull(outId) then
        select 'No user with such id' as `Error`;
        leave process;
    end if;

    select id into outId from `device_models` where device_id = deviceId and sold_at is null limit 1;
    if isnull(outId) then
        select 'No models of that device on storages' as `Error`;
        leave process;
    end if;

    select id, price into outId, outPrice from `devices` where id = deviceId limit 1;
    if isnull(outId) then
        select 'No device with such id' as `Error`;
        leave process;
    elseif outPrice*amount > outBalance then
        select 'The user has too little balance' as `Error`;
        leave process;
    end if;

    insert into `devices_orders`(`user_id`, `device_id`, `amount`, `ordered_at`) values 
        (userId, deviceId, amount, now());

end//

delimiter ;





delimiter //

drop procedure if exists p_delete_device_order//
create procedure if not exists p_delete_device_order(
    in orderId int(10) unsigned
)
process:begin
    declare outId int;
    declare deliveryId int;

    select id into outId from `devices_orders` where id = orderId and deleted_at is null limit 1;
    if isnull(outId) then
        select 'No order with such id or it was deleted' as `Error`;
        leave process;
    end if;

    select id into deliveryId from `devices_deliveries` where order_id = orderId limit 1;
    if !isnull(deliveryId) then
        select 'Devices were already delivered so that\'s impossible to delete order' as `Error`;
        leave process;
    end if;

    update `devices_orders`
        set deleted_at = now()
        where id = orderId;

end //

delimiter ;



delimiter //
drop procedure if exists p_deliver_device//
create procedure if not exists p_deliver_device(
    in orderId int(10) unsigned,
    in deliverymanId int(10) unsigned
)
process:begin
    declare outId int;
    declare deliveryId int;
    declare employeeId int;
    declare userId int;
    declare deviceId int;
    declare deviceAmount int;
    declare devicePrice decimal(10,2);

    select id, user_id, device_id, amount into outId, userId, deviceId, deviceAmount from `devices_orders` where id = orderId and deleted_at is null limit 1;
    if isnull(outId) then
        select 'No order with such id or it was deleted' as `Error`;
        leave process;
    end if;

    select id into deliveryId from `devices_deliveries` where order_id = orderId limit 1;
    if !isnull(deliveryId) then
        select 'Order with this id is already delivered' as `Error`;
        leave process;
    end if;

    select id into employeeId from `employees` where id = deliverymanId and fired_at is null limit 1;
    if isnull(employeeId) then
        select 'No employee with such id or he was fired' as `Error`;
        leave process;
    end if;

    select id, price into outId, devicePrice from `devices` where id = deviceId limit 1;

    select id into outId from `device_models` where device_id = deviceId limit 1;
    if isnull(outId) then
        select 'Devices ended on storages so now device can\'t be delivered' as `Error`;
        leave process;
    end if;

    call p_change_balance(userId, 3, -1 * devicePrice * deviceAmount);

    insert into `devices_deliveries`(`order_id`, `deliveryman_id`, `delivered_at`) values
        (orderId, deliverymanId, now());

    update `device_models`
        set sold_at = now()
        where id = outId;

end//

delimiter ;

-- ========================================================================================================================
-- ========================================================================================================================
-- ========================================================================================================================









-- ========================================================================================================================
-- ========================================================================================================================
-- ========================================================================================================================

-- Процедуры, связанные с тарифами


delimiter //

drop procedure if exists p_connect_tariff//
create procedure if not exists p_connect_tariff(
    in userId int(10) unsigned,
    in tariffId int(10) unsigned,
    in monthAmount int(10) unsigned
)
process:begin
    declare outUserId int;
    declare outBalance decimal(10,2);
    declare outTariffId int;
    declare outPrice decimal(10,2);

    select id, balance into outUserId, outBalance from `users` where id = userId and deleted_at is null limit 1;
    if isnull(outUserId) then
        select 'No user with such id' as `Error`;
        leave process;
    end if;

    select id, price into outTariffId, outPrice from `tariffs` where id = tariffId and deleted_at is null limit 1;
    if isnull(outTariffId) then
        select 'No tariff with such id' as `Error`;
        leave process;
    end if;

    if monthAmount not between 1 and 12 then
        select 'It\'s possible to buy tariff only for 1..12 months' as `Error`;
        leave process;
    end if;

    if outPrice*monthAmount > outBalance then
        select 'Final user\'s balance is below 0' as `Error`;
        leave process;
    end if;

    insert into `tariffs_connections`(`user_id`, `tariff_id`, `month_amount`, `connected_at`, `canceled_at`) values
        (userId, tariffId, monthAmount, now(), date_add(now(), interval monthAmount month));

    call p_change_balance(userId, 2, -1 * outPrice * monthAmount);

end//

delimiter ;

-- ========================================================================================================================
-- ========================================================================================================================
-- ========================================================================================================================











-- ========================================================================================================================
-- ========================================================================================================================
-- ========================================================================================================================

-- Процедуры, связанные с услугами (добавление заявки на выполнение услуги по адресу, удаление заявки и отметка о выполнении заявки)

delimiter //

drop procedure if exists p_order_service//
create procedure if not exists p_order_service(
    in userId int(10) unsigned,
    in serviceId int(10) unsigned,
    in userAddress varchar(255),
    in executeAt timestamp
)
process:begin
    declare outUserId int;
    declare outBalance decimal(10,2);
    declare outServiceId int;
    declare outPrice decimal(10,2);
    

    select id, balance into outUserId, outBalance from `users` where id = userId and deleted_at is null limit 1;
    if isnull(outUserId) then
        select 'No user with such id' as `Error`;
        leave process;
    end if;

    select id, price into outUserId, outPrice from `services` where id = userId and deleted_at is null limit 1;
    if isnull(outUserId) then
        select 'No service with such id' as `Error`;
        leave process;
    end if;

    if outPrice > outBalance then
        select 'Final user\'s balance is below 0' as `Error`;
        leave process;
    end if;

    if timestampdiff(hour, now(), executeAt) <= 1 then
        select 'It\'s possible to order service at least an hour in advance' as `Error`;
        leave process;
    end if;

    insert into `services_orders`(`user_id`, `service_id`, `address`, `ordered_at`, `execute_at`) values
        (userId, serviceId, userAddress, now(), executeAt);

end//

delimiter ;


delimiter //

drop procedure if exists p_delete_service_order//
create procedure if not exists p_delete_service_order(
    in orderId int(10) unsigned
)
process:begin
    declare outOrderId int;
    declare executionId int;

    select id into outOrderId from `services_orders` where id = orderId and deleted_at is null limit 1;
    if isnull(outOrderId) then
        select 'No order with such id or it was deleted' as `Error`;
        leave process;
    end if;

    select id into executionId from `services_orders_executions` where order_id = orderId limit 1;
    if !isnull(executionId) then
        select 'Service was already executed so that\'s impossible to delete order' as `Error`;
        leave process;
    end if;

    update `services_orders`
        set deleted_at = now()
        where id = orderId;

end//

delimiter ;




delimiter //

drop procedure if exists p_execute_service//
create procedure if not exists p_execute_service(
    in orderId int(10) unsigned,
    in workerId int(10) unsigned
)
process:begin
    declare outOrderId int;
    declare outUserId int;
    declare outServiceId int;
    declare outWorkerId int;
    declare userBalance decimal(10,2);
    declare servicePrice decimal(10,2);

    select id, user_id, service_id into outOrderId, outUserId, outServiceId from `services_orders` where id = orderId and deleted_at is null limit 1;
    if isnull(outOrderId) then
        select 'No order with such id or it was deleted' as `Error`;
        leave process;
    end if;

    select id into outWorkerId from `employees` where id = workerId and fired_at is null limit 1;
    if isnull(outWorkerId) then
        select 'No worker with such id or he was fired' as `Error`;
        leave process;
    end if;

    select balance into userBalance from `users` where id = outUserId and deleted_at is null limit 1;
    if isnull(userBalance) then
        select 'User with id from order doesn\'t exist' as `Error`;
        leave process;
    end if;

    select price into servicePrice from `services` where id = outServiceId and deleted_at is null limit 1;
    if isnull(servicePrice) then
        select 'Service with id from order doesn\'t exist' as `Error`;
        leave process;
    end if;

    if servicePrice > userBalance then
        select 'User\'s balance is too low to pay for that service' as `Error`;
        leave process;
    end if;

    insert into `services_orders_executions`(`order_id`, `worker_id`, `executed_at`) values
        (orderId, workerId, now());

    call p_change_balance(outUserId, 1, -1*servicePrice);
    
end//

delimiter ;


-- ========================================================================================================================
-- ========================================================================================================================
-- ========================================================================================================================