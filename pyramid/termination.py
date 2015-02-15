def get_termination(count, variants):
	count = count % 100
	if 4 < count < 21:
		return variants[2]

	count = count % 10
	if count == 1:
		return variants[0]
	if 1 < count < 4: return variants[1]

	return variants[2]
