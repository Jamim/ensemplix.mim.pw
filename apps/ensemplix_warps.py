from ensemplix_log import log
from ensemplix_players import players_ignore_list


def insert_warps(cursor, server_id, world, players, new_warps):
	if not new_warps:
		return

	accepted_warps = []
	for warp in new_warps:
		owner  = warp['owner'].lower()
		if owner in players_ignore_list:
			log('Пропущен варп: \033[0;31m%s', warp['warp'], style='0;33')
			continue

		warp['server_id'] = server_id
		warp['owner']     = players[owner]
		accepted_warps.append(warp)


	cursor.executemany("INSERT INTO warps (created, server_id, warp, owner, x, y, z, yaw, pitch, greeting) VALUES ("
		"%(created)s, %(server_id)s, %(warp)s, %(owner)s, "
		"%(x)s, %(y)s, %(z)s, %(yaw)s, %(pitch)s,"
		"%(greeting)s);", accepted_warps)

	log('Добавлено варпов: \033[0;36m%s \033[0;35m— \033[0;36m%d', world, len(accepted_warps), style='0;35')
