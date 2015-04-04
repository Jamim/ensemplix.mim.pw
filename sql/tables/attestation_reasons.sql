CREATE TABLE attestation_reasons (
	id	SERIAL UNIQUE NOT NULL PRIMARY KEY,
	reason	TEXT NOT NULL
);

INSERT INTO attestation_reasons VALUES (1, 'Табличка цела');
INSERT INTO attestation_reasons VALUES (2, 'Закончилось место');
INSERT INTO attestation_reasons VALUES (3, 'Недостаточно средств');
INSERT INTO attestation_reasons VALUES (4, 'Товар закончился');
INSERT INTO attestation_reasons VALUES (5, 'Покупка отключена');
INSERT INTO attestation_reasons VALUES (6, 'Изменились условия');
INSERT INTO attestation_reasons VALUES (7, 'Изменился предмет');
INSERT INTO attestation_reasons VALUES (8, 'Магазин закрыт');
INSERT INTO attestation_reasons VALUES (9, 'Нет прохода к магазину');
