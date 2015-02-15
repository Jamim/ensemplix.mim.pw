## -*- coding: utf-8 -*-
<%! from time import time, localtime, strftime %>\
<%def name="make_history_row(row)">\
				<tr>
					<td>${row[0]}</td>
					<td>${strftime('%Y.%m.%d %H:%M:%S', localtime(row[1]))}</td>
					<td>${row[2]}</td>
					<td>${row[3]}</td>
					<td>${row[4]}</td>
					<td>${row[5]}</td>
					<td>${row[6]}</td>
					<td>${row[7] and 'продажа' or 'покупка'}</td>
				</tr>
</%def>\
<!DOCTYPE html>
<html lang="ru">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">
		<title>История магазинов Ensemplix</title>
	</head>
	<body>
		<div class="page-header">
			<h2>История магазинов</h2>
		</div>
		<table class="table table-striped">
			<thead>
				<tr>
					<th>#</th>
					<th>Время</th>
					<th>Клиент</th>
					<th>Владелец</th>
					<th>Предмет</th>
					<th>Количество</th>
					<th>Цена</th>
					<th>Тип&nbsp;операции</th>
				</tr>
			</thead>
			<tbody>
			% for event in history:
${make_history_row(event)}\
			% endfor
			</tbody>
		</table>

		<p id="generation_time" class="small">Время генерации: ${'%.2f' % ((time()-start_time) * 1000,)} мс</p>
	</body>
</html>
