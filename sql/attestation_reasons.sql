CREATE TABLE attestation_reasons (
	id	SERIAL UNIQUE NOT NULL PRIMARY KEY,
	reason	TEXT NOT NULL
);

INSERT INTO attestation_reasons VALUES (1, 'Проверено');
INSERT INTO attestation_reasons VALUES (2, 'Нет места');
INSERT INTO attestation_reasons VALUES (3, 'Недостаточно средств');
INSERT INTO attestation_reasons VALUES (4, 'Товар закончился');
INSERT INTO attestation_reasons VALUES (5, 'Изменились условия');
INSERT INTO attestation_reasons VALUES (6, 'Покупка отключена');
INSERT INTO attestation_reasons VALUES (7, 'Магазин закрыт');
