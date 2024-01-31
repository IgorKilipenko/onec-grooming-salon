﻿#Область ПрограммныйИнтерфейс

// Обновляет поле СуммаДокумента.\
// Для корректной рабаты все суммы по строкам ТЧ должны быть предварительно рассчитаны.\
// =========================\
// [примечание разработчика] - в текущей реализации (Спринт 4) не используется.
// Обновление суммы документа выполняется в процессе заполнения формы.
Процедура ОбновитьСуммуДокумента() Экспорт
	опцииРасчета = Документы.ПоступленияТоваров.ПолучитьПоляДляРасчетаСуммыДокумента();
	сумма = РаботаСДокументамиКлиентСервер.РассчитатьСуммуДокумента(ЭтотОбъект, опцииРасчета);
	СуммаДокумента = сумма;
КонецПроцедуры

#КонецОбласти // ПрограммныйИнтерфейс

#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(_, __)
	отражатьСрокиГодности = получитьУчетнуюПолитику() = Перечисления.ВидыУчетнойПолитики.FEFO;

	Движения.ТоварыНаСкладах.Записывать = Истина;

	выборкаТоварыДокумента = получитьВыборкуТоварыДокумента(отражатьСрокиГодности);
    Если выборкаТоварыДокумента = Неопределено Тогда
        Возврат;
    КонецЕсли;

	Пока выборкаТоварыДокумента.Следующий() Цикл
        выполнитьДвижениеТоварыНаСкладах(выборкаТоварыДокумента, отражатьСрокиГодности);
	КонецЦикла;
КонецПроцедуры

Процедура ОбработкаЗаполнения(_, __, ___)
	РаботаСДокументами.ЗаполнитьПолеАвторДокументаНаСервере(ЭтотОбъект);
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

#Область Движения
Процедура выполнитьДвижениеТоварыНаСкладах(текСтрокаТовары, Знач отражатьСрокиГодности = Ложь)
	движение = Движения.ТоварыНаСкладах.Добавить();
	движение.ВидДвижения = ВидДвиженияНакопления.Приход;
	движение.Период = Дата;
    движение.Склад = Склад;
	движение.Номенклатура = текСтрокаТовары.Номенклатура;
	движение.Количество = текСтрокаТовары.Количество;
	движение.Сумма = текСтрокаТовары.Сумма;
	Если отражатьСрокиГодности Тогда
		движение.СрокГодности = текСтрокаТовары.СрокГодности;
	КонецЕсли;
КонецПроцедуры
#КонецОбласти // Движения

Функция получитьВыборкуТоварыДокумента(отражатьСрокиГодности) // => Выборка | Неопределено
	запросТовары = Новый Запрос;
	запросТовары.УстановитьПараметр("Ссылка", Ссылка);

	запросТовары.Текст =
        "ВЫБРАТЬ
		|	ПоступленияТоваров.Номенклатура КАК Номенклатура,
		|	СУММА(ПоступленияТоваров.Количество) КАК Количество,
		|	СУММА(ПоступленияТоваров.Сумма) КАК Сумма,
		|	ПоступленияТоваров.СрокГодности КАК СрокГодности
		|ИЗ
		|	Документ.ПоступленияТоваров.Товары КАК ПоступленияТоваров
		|ГДЕ
		|	ПоступленияТоваров.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ПоступленияТоваров.Номенклатура,
		|	ПоступленияТоваров.СрокГодности
		|";

    Если НЕ отражатьСрокиГодности Тогда // Удаляем поле СрокГодности из запроса
        запросТовары.Текст = СтрЗаменить(запросТовары.Текст, "Сумма,", "Сумма");
        запросТовары.Текст = СтрЗаменить(запросТовары.Текст, "ПоступленияТоваров.СрокГодности КАК СрокГодности", "");
        запросТовары.Текст = СтрЗаменить(запросТовары.Текст, "Номенклатура,", "Номенклатура");
        запросТовары.Текст = СтрЗаменить(запросТовары.Текст, "ПоступленияТоваров.СрокГодности,", "");
    КонецЕсли;

    результатЗапроса = запросТовары.Выполнить();
    Если результатЗапроса.Пустой() Тогда
        Возврат Неопределено;
    КонецЕсли;

	Возврат результатЗапроса.Выбрать();
КонецФункции

Функция получитьУчетнуюПолитику()
	Возврат РегистрыСведений.УчетнаяПолитика.ПолучитьПоследнее(Дата).УчетнаяПолитика;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
