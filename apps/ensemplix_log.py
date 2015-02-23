import datetime

def log(message_template, *args):
	message = args and message_template % args or message_template
	print('%s %s' % (datetime.datetime.now().strftime('%Y.%m.%d %H:%M:%S.%f'), message))
