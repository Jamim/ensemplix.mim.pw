## -*- coding: utf-8 -*-
<%! from time import time, localtime, strftime %>\
<%def name="make_history_row(row)">\
					<tr>
						<td>
							<span class="label label-warning">${row[0]['warp'][3]}</span><br />
							<span class="small text-muted">${'%.1f' % (row[0]['distance'],)} метра</span>
						</td>
						<td>
							<a class="label label-success" href="http://webapi.ensemplix.ru/#${row[2]}">${row[2]}</a>
							${row[3] and 'продал' or 'купил у'}
							<a class="label label-info" href="http://webapi.ensemplix.ru/#${row[4]}">${row[4]}</a>
						</td>
						<td>
							<a href="/item/${row[6]}">
								<img src="${row[5]}" alt="${row[7]}"/>
							</a>
						</td>
						<td>
							<a class="label label-primary" href="/item/${row[6]}">#${row[6]} ${row[7].capitalize().replace('_', ' ')}</a><br />
							${row[8]} шт. за <b>${row[9]}&nbsp;койн${get_termination(row[9], ('', 'а', 'ов'))}</b>
						</td>
						<td>${row[10]},${row[11]},${row[12]}</td>
						<td>${strftime('%Y.%m.%d %H:%M:%S', localtime(row[13]))}</td>
					</tr>
</%def>\
<!DOCTYPE html>
<html lang="ru">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" href="/css/mim.bootstrap.min.css" />
		<title>История магазинов Ensemplix</title>
	</head>
	<body role="document">
		<div class="container theme-showcase" role="main">
			<div class="page-header">
				<h2>История магазинов</h2>
			</div>
			<table class="table table-striped">
				<thead>
					<tr>
						<th>Варп</th>
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
		</div>
	</body>
</html>
