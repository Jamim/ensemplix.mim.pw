## -*- coding: utf-8 -*-
<%! from time import time, localtime, strftime %>\
<%def name="make_shops_table(shops, action, panel)">\
					<div class="panel panel-${panel}">
						<div class="panel-heading">
							<h3 class="panel-title">Где ${action}</h3>
						</div>
						<table class="panel-body table table-striped">
							<thead>
								<tr>
									<th>Варп</th>
									<th>Владелец</th>
									<th>Цена</th>
									<th>Сделка</th>
									<th>Координаты</th>
								</tr>
							</thead>
							<tbody>
							% for shop in shops:
		${make_shop_row(shop)}\
							% endfor
							</tbody>
						</table>
					</div>
</%def>\
<%def name="make_shop_row(shop)">\
						<tr>
							<td>
								<span class="label label-warning">${shop[0]['warp'][3]}</span><br />
								<span class="small text-muted">${'%.1f' % (shop[0]['distance'],)} метра</span>
							</td>
							<td>
								<a class="label label-info" href="http://webapi.ensemplix.ru/#${shop[1]}">${shop[1]}</a>
							</td>
							${make_price_td(shop[2])}\
							<td>
								${shop[3]} шт. за <b>${shop[4]}&nbsp;койн${get_termination(shop[4], ('', 'а', 'ов'))}</b><br />
								<span class="small text-muted">${strftime('%Y.%m.%d %H:%M:%S', localtime(shop[5]))}</span>
							</td>
							<td>${shop[6]},${shop[7]},${shop[8]}</td>
						</tr>
</%def>\
<%def name="make_stats_table(stats, period, panel)">\
			<div class="panel panel-${panel}">
				<div class="panel-heading">
					<h3 class="panel-title">Статистика торговли за ${period}</h3>
				</div>
				<table class="panel-body table table-striped">
					<thead>
						<tr>
							<th rowspan="2">Тип операций</th>
							<th colspan="2">Общее количество</th>
							<th rowspan="2">Сумма</th>
							<th colspan="3">Цена в койнах</th>
						</tr>
						<tr>
							<th>Сделок</th>
							<th>Блоков</th>
							<th>Минимальная</th>
							<th>Средняя</th>
							<th>Максимальная</th>
						</tr>
					</thead>
					<tbody>
					% for row in stats:
${make_stats_row(row)}\
					% endfor
					</tbody>
				</table>
			</div>
</%def>\
<%def name="make_price_td(price)">\
<td>${'{0:.6f}'.format(price).rstrip('0').rstrip('.')} <span class="small text-muted">x 64 =</span> ${'{0:.5f}'.format(price*64).rstrip('0').rstrip('.')}</td>
</%def>\
<%def name="make_stats_row(row)">\
						<tr>
							<td>${row[0] and 'Продажа в магазины' or 'Покупка из магазинов'}</td>
							<td>${row[1]}</td>
							<td>${row[2]} <span class="small text-muted">/ 64 =</span> ${'{0:.2f}'.format(row[2]/64).rstrip('0').rstrip('.')}</td>
							<td>${row[3]} койн${get_termination(row[3], ('', 'а', 'ов'))}</td>
							${make_price_td(row[4])}\
							${make_price_td(row[5])}\
							${make_price_td(row[6])}\
						</tr>
</%def>\
<!DOCTYPE html>
<html lang="ru">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" href="/css/mim.bootstrap.min.css" />
		<title>Сведения о предмете Ensemplix</title>
	</head>
	<body role="document">
		<div class="container theme-showcase" role="main">
			<div class="page-header">
				<h2><img src="${item_info[2]}" alt="${item_info[1]}" /> #${item_info[0]} ${item_info[1].capitalize().replace('_', ' ')}</h2>
			</div>
% if where_to_buy or where_to_sell:
			<div class="row">
				<div class="col-sm-6">
% if where_to_buy:
${make_shops_table(where_to_buy, 'купить', 'warning')}\
% endif
				</div>
				<div class="col-sm-6">
% if where_to_sell:
${make_shops_table(where_to_sell, 'продать', 'danger')}\
% endif
				</div>
			</div>
% endif
% if daily_stats:
${make_stats_table(daily_stats, 'день', 'success')}\
% endif
% if weekly_stats:
${make_stats_table(weekly_stats, 'неделю', 'info')}\
% endif
			<p id="generation_time" class="small">Время генерации: ${'%.2f' % ((time()-start_time) * 1000,)} мс</p>
		</div>
	</body>
</html>
