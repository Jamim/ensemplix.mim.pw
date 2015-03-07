## -*- coding: utf-8 -*-
<%! from time import time %>\
<%def name="make_items_row(item)">\
					<tr>
						<td>
							<a href="/item/${item.id_with_data}"><img src="${item.icon_image}" alt="" /></a>
							<a class="label label-primary" href="/item/${item.id_with_data}">${item.id_with_title}</a>
						</td>
${make_price_td('Davids',  item.id_with_data, item.davids_buy_price,  item.davids_sell_price)}\
${make_price_td('Sandbox', item.id_with_data, item.sandbox_buy_price, item.sandbox_sell_price)}\
${make_price_td('Amber',   item.id_with_data, item.amber_buy_price,   item.amber_sell_price)}\
					</tr>
</%def>\
<%def name="make_price_td(server, id_with_data, buy, sell)">\
						<td>
							% if buy:
							<a class="label label-warning" href="/${server}/item/${id_with_data}" title="Покупка из магазина на ${server}">${'{0:.6f}'.format(buy).rstrip('0').rstrip('.')}</a><br />
							% else:
							<br />
							% endif
							%if sell:
							<a class="label label-${buy and sell and buy < sell and 'success' or 'danger'}" href="/${server}/item/${id_with_data}" title="Продажа в магазин на ${server}">${'{0:.6f}'.format(sell).rstrip('0').rstrip('.')}</a>
							% endif
						</td>
</%def>\
<!DOCTYPE html>
<html lang="ru">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" href="/css/mim.bootstrap.min.css" />
		<link rel="icon" type="image/x-icon" href="/images/favicon.ico" />
		<title>Лучше курсы Ensemplix</title>
	</head>
	<body role="document">
		<div class="container theme-showcase" role="main">
			<div class="page-header">
				<h2>Лучшие курсы</h2>
			</div>
			<table class="table table-striped">
				<thead>
					<tr>
						<th>Предмет</th>
						<th>Davids</th>
						<th>Sandbox</th>
						<th>Amber</th>
					</tr>
				</thead>
				<tbody>
				% for item in items:
${make_items_row(item)}\
				% endfor
				</tbody>
			</table>

			<p id="generation_time" class="small">Время генерации: ${'%.2f' % ((time()-start_time) * 1000,)} мс</p>
		</div>
	</body>
</html>
