from http.client import HTTPConnection
from ensemplix_log import log
from time import time
import json

def get_connection():
	return HTTPConnection('api.ensemplix.ru')

def get_data(connection, request):
	start_time = time()

	log('Запрос к API: %s', request)

	connection.request('GET', '/v2/%s' % (request,))
	response = connection.getresponse()

	if response.status != 200:
		return None

	json_data = response.read().decode('utf-8')
	data = json.loads(json_data)

	log('Запрос выполнен за %.3f секунды', time() - start_time)

	return data
