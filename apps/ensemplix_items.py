from ensemplix_log import log


def insert_items(cursor, new_items):
	if not new_items:
		return

	cursor.executemany("INSERT INTO items VALUES (%(id)s, %(data)s, %(title)s, %(icon_image)s);", new_items)
	log('Добавлено предметов: \033[0;36m%d', len(new_items), style='0;35')
