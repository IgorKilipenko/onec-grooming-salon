﻿#Область ПрограммныйИнтерфейс

Функция ПолучитьТипыКонтрагентов() Экспорт
    Возврат Перечисления.ТипыКонтрагентов;
КонецФункции

Функция СодержитРеквизитаСИменем(Знач имяРеквизита) Экспорт
    Возврат Метаданные.Справочники.Контрагенты.Реквизиты.Найти(имяРеквизита) <> Неопределено;
КонецФункции

// Параметры:
//	ссылка - СправочникСсылка.Контрагенты, Произвольный
//
// Возвращаемое значение:
//	- ПеречислениеСсылка.ТипыКонтрагентов, Неопределено
//
Функция ПолучитьТипКонтрагента(Знач ссылка) Экспорт
    Если (НЕ ЗначениеЗаполнено(ссылка))
        ИЛИ ТипЗнч(ссылка) <> Тип("СправочникСсылка.Контрагенты") Тогда
        Возврат Неопределено;
    КонецЕсли;

    запросКонтрагента = Новый Запрос;
    запросКонтрагента.УстановитьПараметр("Ссылка", ссылка);

    запросКонтрагента.Текст =
        "ВЫБРАТЬ
        |	Контрагенты.ТипКонтрагента КАК ТипКонтрагента
        |ИЗ
        |	Справочник.Контрагенты КАК Контрагенты
        |ГДЕ
        |	Контрагенты.Ссылка = &Ссылка
        |";

    выборка = запросКонтрагента.Выполнить().Выбрать();
    Если выборка.Следующий() Тогда
        Возврат выборка.ТипКонтрагента;
    КонецЕсли;

    Возврат Неопределено;
КонецФункции

// Параметры:
//	ссылка - СправочникСсылка.Контрагенты, Произвольный
//
// Возвращаемое значение:
//	- Булево
Функция ЭтотКонтрагентКлиент(Знач ссылка) Экспорт
    Возврат ПолучитьТипКонтрагента(ссылка) = Перечисления.ТипыКонтрагентов.Клиент;
КонецФункции

// Параметры:
//	ссылка - СправочникСсылка.Контрагенты, Произвольный
//
// Возвращаемое значение:
//	- Булево
Функция ЭтотКонтрагентПоставщик(Знач ссылка) Экспорт
    Возврат ПолучитьТипКонтрагента(ссылка) = Перечисления.ТипыКонтрагентов.Поставщик;
КонецФункции

#КонецОбласти
