/*
 * Создание таблиц
 */

\i tables/servers.sql
\i tables/players.sql
\i tables/warps.sql
\i tables/items.sql
\i tables/shops_history.sql
\i tables/attestation_reasons.sql
\i tables/shops_attestation.sql


/*
 * Создание хранимых функций и процедур
 */
\i functions/last_deals_ids.sql
\i functions/last_deals_ids_with_attestation_ids.sql
\i functions/item_last_deals_ids.sql
\i functions/item_last_deals_ids_with_attestation_ids.sql
\i functions/last_unique_deals.sql

\i functions/max_sell_prices.sql
\i functions/min_buy_prices.sql

\i functions/deal_attestation.sql
\i functions/shop_attestation.sql

\i functions/shops_for_attestation.sql
\i functions/shops_manual_attestation.sql

\i functions/item_stats.sql
\i functions/item_shops_buy.sql
\i functions/item_shops_sell.sql

\i functions/items_stats.sql


/*
 * Создание триггеров
 */
\i triggers/shop_attestation_trigger.sql
