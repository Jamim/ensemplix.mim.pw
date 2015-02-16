## -*- coding: utf-8 -*-
<%! from time import time, localtime, strftime %>\
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
							<td>${row[2]}</td>
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
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css" />
		<title>Сведения о предмете Ensemplix</title>
	</head>
	<body role="document">
		<div class="container theme-showcase" role="main">
			<div class="page-header">
				<h2><img src="${item_info[2]}" alt="${item_info[1]}" /> #${item_info[0]} ${item_info[1].capitalize().replace('_', ' ')}</h2>
			</div>
${make_stats_table(daily_stats, 'день', 'success')}\
${make_stats_table(weekly_stats, 'неделю', 'info')}\
			<p id="generation_time" class="small">Время генерации: ${'%.2f' % ((time()-start_time) * 1000,)} мс</p>
		</div>
	</body>
</html>
