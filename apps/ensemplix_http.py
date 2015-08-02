from http.client import HTTPConnection, ResponseNotReady, BadStatusLine
from ensemplix_log import log
from time import time, sleep
from socket import timeout
import json

CONNECTION_TIMEOUT = 15

def init_connection():
	global api_connection
	api_connection = HTTPConnection('api.ensemplix.ru', timeout=CONNECTION_TIMEOUT)

def close_connection():
	if api_connection:
		api_connection.close()

last_request_time = 0
MIN_REQUEST_INTERVAL = 0.333
OSERROR_DELAY = 60

def get_data(request):
	global last_request_time

	delay = MIN_REQUEST_INTERVAL - (time() - last_request_time)
	if delay > 0:
		sleep(delay)

	log('Запрос к API: \033[0;33m%s\033[0m', request)

	start_time = time()

	try:
		api_connection.request('GET', '/v2/%s' % (request,))
	except OSError as error:
		log('Произошла системная ошибка: \033[0;36m%s', error, style='0;31')
		sleep(OSERROR_DELAY)
		init_connection()
		return get_data(request)

	try:
		response = api_connection.getresponse()
	except BadStatusLine:
		response = None
	except timeout:
		response = None

	last_request_time = time()

	if response is None or response.status != 200:
		init_connection()
		return None

	try:
		response_data = response.read()
	except timeout:
		init_connection()
		return get_data(request)

	json_data = response_data.decode('utf-8')
	data = json.loads(json_data)

	log('Запрос выполнен за %.3f секунды', last_request_time - start_time)

	return data
