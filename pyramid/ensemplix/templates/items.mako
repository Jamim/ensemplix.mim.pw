## -*- coding: utf-8 -*-
<%! from time import time %>\
<%def name="make_items_row(item)">\
					<tr>
						<td>
							<a href="/item/${item[0]}"><img src="${item[2]}" alt="${item[1]}"/></a>
							<a class="label label-primary" href="/item/${item[0]}">#${item[0]} ${item[1].capitalize().replace('_', ' ')}</a>
						</td>
${make_price_td('Davids',  item[0], item[3], item[4])}\
${make_price_td('Sandbox', item[0], item[5], item[6])}\
${make_price_td('Amber',   item[0], item[7], item[8])}\
					</tr>
</%def>\
<%def name="make_price_td(server, item_id, buy, sell)">\
						<td>
							% if buy:
							<a class="label label-warning" href="/${server}/item/${item_id}" title="Покупка из магазина на ${server}">${'{0:.6f}'.format(buy).rstrip('0').rstrip('.')}</a><br />
							% else:
							<br />
							% endif
							%if sell:
							<a class="label label-danger" href="/${server}/item/${item_id}" title="Продажа в магазин на ${server}">${'{0:.6f}'.format(sell).rstrip('0').rstrip('.')}</a>
							% endif
						</td>
</%def>\
<!DOCTYPE html>
<html lang="ru">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" href="/css/mim.bootstrap.min.css" />
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
