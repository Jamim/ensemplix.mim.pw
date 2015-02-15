## -*- coding: utf-8 -*-
<%! from time import time, localtime, strftime %>\
<%! from termination import get_termination %>\
<%def name="make_history_row(row)">\
				<tr>
					<td>
						<a class="label label-success" href="http://webapi.ensemplix.ru/#${row[1]}">${row[1]}</a>
						${row[2] and 'продал' or 'купил у'}
						<a class="label label-info" href="http://webapi.ensemplix.ru/#${row[3]}">${row[3]}</a>
					</td>
					<td>
						<img src="${row[4]}" alt="${row[6]}"/>
					</td>
					<td>
						<b>#${row[5]}</b> ${row[6]}<br />
						${row[7]} шт. за <b>${row[8]} койн${get_termination(row[8], ('', 'а', 'ов'))}</b>
					</td>
					<td>${row[9]},${row[10]},${row[11]}</td>
					<td>${strftime('%Y.%m.%d %H:%M:%S', localtime(row[12]))}</td>
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
					<th>Операция</th>
					<th colspan="2">Предмет</th>
					<th>Координаты</th>
					<th>Время</th>
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
