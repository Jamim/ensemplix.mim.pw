## -*- coding: utf-8 -*-
<%! from time import time, localtime, strftime %>\
<%def name="make_shops_table(shops, action, owner, panel)">\
					<div class="panel panel-${panel}">
						<div class="panel-heading">
							<h3 class="panel-title">Где ${action}</h3>
						</div>
						<table class="panel-body table table-striped">
							<thead>
								<tr>
									<th>Варп</th>
									<th>${owner}</th>
									<th>Цена</th>
									<th>Сделка</th>
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
										<span class="label label-warning">${shop.warp.title}</span><br />
										<span class="small text-muted">${'%.1f' % (shop.warp.distance,)} метра</span>
									</td>
									<td>
										<a class="label label-info" href="http://webapi.ensemplix.ru/#${shop.owner}">${shop.owner}</a><br />
										<span class="small text-muted">${shop.coords}</span>
									</td>
									<td>
										${make_price(shop.single_price)}
									</td>
									<td>
										${shop.amount} шт. за <b>${shop.price}&nbsp;койн${get_termination(shop.price, ('', 'а', 'ов'))}</b><br />
										<span class="small text-muted">${strftime('%Y.%m.%d %H:%M:%S', localtime(shop.deal_time))}</span>
									</td>
								</tr>
</%def>\
<%def name="make_stats_table(stats, period, panel)">\
					<div class="panel panel-${panel}">
						<div class="panel-heading">
							<h3 class="panel-title">Торговля за ${period}</h3>
						</div>
						<table class="panel-body table">
							<thead>
								<tr>
									<th>Тип операций</th>
									<th colspan="2">Всего</th>
									<th colspan="2">Цена в койнах</th>
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
<%def name="make_price(price)">\
${'{0:.6f}'.format(price).rstrip('0').rstrip('.')}<br /><span class="small text-muted">x 64 =</span> ${'{0:.5f}'.format(price*64).rstrip('0').rstrip('.')}\
</%def>\
<%def name="make_stats_row(row)">\
								<tr>
									<td rowspan="3">${row[0] and 'Продажа в магазины' or 'Покупка из магазинов'}</td>
									<td class="small text-muted">Сделок</td>
									<td>${row[1]}</td>
									<td class="small text-muted">Максимальная</td>
									<td>${make_price(row[6])}</td>
								</tr>
								<tr>
									<td class="small text-muted">Блоков</td>
									<td>${row[2]}<br /><span class="small text-muted">/ 64 =</span> ${'{0:.2f}'.format(row[2]/64).rstrip('0').rstrip('.')}</td>
									<td class="small text-muted">Средняя</td>
									<td>${make_price(row[5])}</td>
								</tr>
								<tr>
									<td class="small text-muted">На&nbsp;сумму</td>
									<td>${row[3]}&nbsp;койн${get_termination(row[3], ('', 'а', 'ов'))}</td>
									<td class="small text-muted">Минимальная</td>
									<td>${make_price(row[4])}</td>
								</tr>
</%def>\
<!DOCTYPE html>
<html lang="ru">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" href="/css/mim.bootstrap.min.css" />
		<link rel="icon" type="image/png" href="${item.icon_image}" />
		<title>${item.id_with_title} &bull;${single_server and ' %s &bull;' % (single_server,) or ''} Сведения о предмете Ensemplix</title>
	</head>
	<body role="document">
		<div class="container theme-showcase" role="main">
			<div class="page-header">
				<h2><img src="${item.icon_image}" alt="${item.title}" /> ${item.id_with_title}</h2>
			</div>
% for server in (len(item.stats) == 3 and ('Davids', 'Sandbox', 'Amber') or item.stats):
<% stats = item.stats[server] %>\
% if stats.where_to_buy or stats.where_to_sell:
			<div class="page-header">
				<h3>Магазины ${server}</h3>
			</div>
			<div class="row">
				<div class="col-sm-6">
% if stats.where_to_buy:
${make_shops_table(stats.where_to_buy, 'купить', 'Продавец', 'warning')}\
% endif
				</div>
				<div class="col-sm-6">
% if stats.where_to_sell:
${make_shops_table(stats.where_to_sell, 'продать', 'Покупатель', 'danger')}\
% endif
				</div>
			</div>
% endif
% if stats.weekly:
			<div class="page-header">
				<h3>Статистика ${server}</h3>
			</div>
			<div class="row">
				<div class="col-sm-6">
% if stats.daily:
${make_stats_table(stats.daily, 'день', 'success')}\
% endif
				</div>
				<div class="col-sm-6">
${make_stats_table(stats.weekly, 'неделю', 'info')}\
				</div>
			</div>
% endif
% endfor
			<p id="generation_time" class="small">Время генерации: ${'%.2f' % ((time()-start_time) * 1000,)} мс</p>
		</div>
	</body>
</html>
