﻿
Функция ШаблонURL_GET_userGetUser(Запрос)
	Ответ = Новый HTTPСервисОтвет(200);
	
	Запись = Новый ЗаписьJSON;
	Запись.УстановитьСтроку();
	Запись.ЗаписатьИмяСвойства("СообщениеСервера1с");	
	Запись.ЗаписатьЗначение("Привет");
	Результат = Запись.Закрыть();
	
	Ответ.УстановитьТелоИзСтроки(Результат);
	Ответ.Заголовки.Вставить("Content-type", "application/json");

	Возврат Ответ;
КонецФункции
