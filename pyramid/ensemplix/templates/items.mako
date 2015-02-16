## -*- coding: utf-8 -*-
<%! from time import time %>\
<%def name="make_items_row(item)">\
					<tr>
						<td>
							<a href="/item/${item[0]}">
								<img src="${item[2]}" alt="${item[1]}"/>
							</a>
						</td>
						<td>
							<a class="label label-primary" href="/item/${item[0]}">#${item[0]} ${item[1].capitalize().replace('_', ' ')}</a>
						</td>
						<td>${item[3] and '{0:.2f}'.format(item[3]).rstrip('0').rstrip('.') or ''}</td>
						<td>${item[4] and '{0:.2f}'.format(item[4]).rstrip('0').rstrip('.') or ''}</td>
					</tr>
</%def>\
<!DOCTYPE html>
<html lang="ru">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" href="/css/mim.bootstrap.min.css" />
		<title>Список предметов Ensemplix</title>
	</head>
	<body role="document">
		<div class="container theme-showcase" role="main">
			<div class="page-header">
				<h2>Список предметов</h2>
			</div>
			<table class="table table-striped">
				<thead>
					<tr>
						<th colspan="2">Предмет</th>
						<th>Покупка</th>
						<th>Продажа</th>
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
