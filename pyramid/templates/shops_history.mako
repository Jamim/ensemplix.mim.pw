## -*- coding: utf-8 -*-
<%! from time import time %>\
<%def name="make_history_row(row)">\
			<tr>
				<td>${row[0]}</td>
				<td>${row[1]}</td>
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
		<title>История магазинов ensemplix.ru</title>
	</head>
	<body>
		<table>
		% for event in history:
${make_history_row(event)}\
		% endfor
		</table>

		<p id="generation_time">Время генерации: ${'%.2f' % ((time()-start_time) * 1000,)} мс</p>
	</body>
</html>
