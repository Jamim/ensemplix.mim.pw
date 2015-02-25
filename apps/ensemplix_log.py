import datetime

def log(message_template, *args, style=None):
	message = args and message_template % args or message_template
	if style:
		message = '\033[%sm%s\033[0m' % (style, message)
	print('%s %s' % (datetime.datetime.now().strftime('%Y.%m.%d %H:%M:%S.%f'), message))
