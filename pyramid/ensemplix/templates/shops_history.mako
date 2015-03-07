## -*- coding: utf-8 -*-
<%! from time import time, localtime, strftime %>\
<%def name="make_history_row(deal)">\
					<tr>
						<td>
							% if not server:
							<a class="label label-default" href="/${deal.server}/shops/history/last">${deal.server}</a><br />
							% endif
							<span class="small text-muted">${deal.coords}</span>
						</td>
						<td>
							<span class="label label-warning">${deal.warp.title}</span><br />
							<span class="small text-muted">${'%.1f' % (deal.warp.distance,)} метра</span>
						</td>
						<td>
							<a class="label label-success" href="http://webapi.ensemplix.ru/#${deal.client}">${deal.client}</a>
							${deal.operation and 'продал' or 'купил у'}
							<a class="label label-info" href="http://webapi.ensemplix.ru/#${deal.owner}">${deal.owner}</a><br />
							<span class="small text-muted">${strftime('%Y.%m.%d %H:%M:%S', localtime(deal.time))}</span>
						</td>
						<td>
							<a href="/${server or deal.server}/item/${deal.item.id_with_data}">
								<img src="${deal.item.icon_image}" alt="" />
							</a>
						</td>
						<td>
							<a class="label label-primary" href="/${server or deal.server}/item/${deal.item.id_with_data}">${deal.item.id_with_title}</a><br />
							<span title="Сделка ${deal.id}">${deal.amount} шт. за <b>${deal.price}&nbsp;койн${get_termination(deal.price, ('', 'а', 'ов'))}</b></span>
						</td>
					</tr>
</%def>\
<!DOCTYPE html>
<html lang="ru">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" href="/css/mim.bootstrap.min.css" />
		<link rel="icon" type="image/x-icon" href="/images/favicon.ico" />
		<title>${server and server + ' &bull; ' or ''}История магазинов Ensemplix</title>
	</head>
	<body role="document">
		<div class="container theme-showcase" role="main">
			<div class="page-header">
				<h2>История магазинов${server and ' ' + server or ''}</h2>
			</div>
			<table class="table table-striped">
				<thead>
					<tr>
						<th>${server and 'Координаты' or 'Сервер'}</th>
						<th>Варп</th>
						<th>Операция</th>
						<th colspan="2">Предмет</th>
					</tr>
				</thead>
				<tbody>
				% for deal in history:
${make_history_row(deal)}\
				% endfor
				</tbody>
			</table>

			<p id="generation_time" class="small">Время генерации: ${'%.2f' % ((time()-start_time) * 1000,)} мс</p>
		</div>
	</body>
</html>
