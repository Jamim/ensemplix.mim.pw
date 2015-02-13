from http.client import HTTPConnection
import json

def get_connection():
	return HTTPConnection('api.ensemplix.ru')

def get_data(connection, request):
	connection.request('GET', '/v2/%s' % (request,))
	response = connection.getresponse()

	if response.status != 200:
		return None

	json_data = response.read().decode('utf-8')
	data = json.loads(json_data)

	return data
