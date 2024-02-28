﻿#Область ПрограммныйИнтерфейс

// Параметры:
//	расчетныйСчетСсылка - СправочникСсылка.БанковскиеСчета
//	моментВремени - МоментВремени, Неопределено
// Возвращаемое значение:
//	- Структура - Структура вида: { РасчетныйСчет: Строка, Сумма: Число }
//  - Неопределено - Если в РегистрНакопления.ДенежныеСредства нет записи с указанным расчетным счетом
Функция ПолучитьОстатокДенежныхСредствНаРасчетномСчете(Знач расчетныйСчетСсылка, Знач моментВремени = Неопределено) Экспорт
    Возврат РегистрыНакопления.ДенежныеСредства.ПолучитьОстатокПоКассе(расчетныйСчетСсылка, моментВремени);
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс
