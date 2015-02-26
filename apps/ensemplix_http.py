from http.client import HTTPConnection, ResponseNotReady
from ensemplix_log import log
from time import time, sleep
import json

def get_connection():
	return HTTPConnection('api.ensemplix.ru')

last_request_time = 0
min_request_interval = 1
def get_data(connection, request):
	global last_request_time

	delay = min_request_interval - (time() - last_request_time)
	if delay > 0:
		sleep(delay)

	log('Запрос к API: \033[0;33m%s\033[0m', request)

	start_time = time()
	connection.request('GET', '/v2/%s' % (request,))
	response = connection.getresponse()
	last_request_time = time()

	if response.status != 200:
		return None

	json_data = response.read().decode('utf-8')
	data = json.loads(json_data)

	log('Запрос выполнен за %.3f секунды', last_request_time - start_time)

	return data
