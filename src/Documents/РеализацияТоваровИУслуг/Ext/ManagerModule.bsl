﻿#Область ПрограммныйИнтерфейс

// Возвращаемое значение:
//  Массив - массив объектов вида: { ИмяТЧ: Строка, Столбец: Строка } наименований
//  табличных частей (ТЧ) и столбцов ТЧ используемых для расчета суммы документа.
//  { ИмяТЧ - Имя ТабличнойЧасти, Столбец - Наименование Реквизита ТабличнойЧасти }
//
Функция ПолучитьПоляДляРасчетаСуммыДокумента() Экспорт
    имяТаблицыТоваров = Метаданные.Документы.РеализацияТоваровИУслуг.ТабличныеЧасти.Товары.Имя;
    имяТаблицыУслуг = Метаданные.Документы.РеализацияТоваровИУслуг.ТабличныеЧасти.Услуги.Имя;

    коллекцияПолей = Новый Массив(2);
    коллекцияПолей[0] = РаботаСДокументамиКлиентСервер.СоздатьЭлементРасчетаСуммыДокумента(имяТаблицыТоваров, "Сумма");
    коллекцияПолей[1] = РаботаСДокументамиКлиентСервер.СоздатьЭлементРасчетаСуммыДокумента(имяТаблицыУслуг, "Стоимость");

    Возврат коллекцияПолей;
КонецФункции

// Параметры:
//	документРТУСсылка - ДокументСсылка.РеализацияТоваровИУслуг
//  исходныйДокументНаОплатуСсылка - ДокументСсылка.ПоступлениеДенежныхСредств, ДокументСсылка.ПоступлениеНаРасчетныйСчет, Неопределено
// Возвращаемое значение:
//	- Структура
//      * ПризнакОплаты - ПеречислениеСсылка.ПризнакиОплаты
//      * ОсталосьОплатить - Число, Неопределено
Функция ПроверитьОплатуДокумента(Знач документРТУСсылка, Знач исходныйДокументНаОплатуСсылка = Неопределено) Экспорт
    структураОтвета = Новый Структура("ПризнакОплаты, ОсталосьОплатить", Перечисления.ПризнакиОплаты.НеОплачен, 0);

    Если НЕ ЗначениеЗаполнено(документРТУСсылка) Тогда
        структураОтвета.ПризнакОплаты = Перечисления.ПризнакиОплаты.НеОплачен;
        структураОтвета.ОсталосьОплатить = Неопределено;

        Возврат структураОтвета;
    КонецЕсли;

    запрос = Новый Запрос;
    текстЗапросаПоступлений =
        "ВЫБРАТЬ
        |	СУММА(ДокументПоступления.СуммаДокумента) КАК СуммаДокумента,
        |	ДокументПоступления.ДокументОснование КАК ДокументРТУ
        |ПОМЕСТИТЬ ВТ_Поступления_БанкМКасса
        |ИЗ
        |	Документ.ПоступлениеДенежныхСредств КАК ДокументПоступления
        |ГДЕ
        |   ДокументПоступления.ДокументОснование ССЫЛКА Документ.РеализацияТоваровИУслуг
        |	И ДокументПоступления.ДокументОснование = &Ссылка
        |	И ДокументПоступления.Проведен
        |   И ДокументПоступления.Ссылка <> &ИсходныйДокументНаОплату
        |
        |СГРУППИРОВАТЬ ПО
        |	ДокументПоступления.ДокументОснование
        |
        |ОБЪЕДИНИТЬ ВСЕ
        |
        |ВЫБРАТЬ
        |	СУММА(ДокументПоступления.СуммаДокумента),
        |	ДокументПоступления.ДокументОснование
        |ИЗ
        |	Документ.ПоступлениеНаРасчетныйСчет КАК ДокументПоступления
        |ГДЕ
        |   ДокументПоступления.ДокументОснование ССЫЛКА Документ.РеализацияТоваровИУслуг
        |	И ДокументПоступления.ДокументОснование = &Ссылка
        |	И ДокументПоступления.Проведен
        |   И ДокументПоступления.Ссылка <> &ИсходныйДокументНаОплату
        |
        |СГРУППИРОВАТЬ ПО
        |	ДокументПоступления.ДокументОснование
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ
        |	СУММА(ВТ_Поступления_БанкМКасса.СуммаДокумента) КАК СуммаДокумента,
        |	ВТ_Поступления_БанкМКасса.ДокументРТУ КАК ДокументРТУ
        |ПОМЕСТИТЬ ВТ_Поступления
        |ИЗ
        |	ВТ_Поступления_БанкМКасса КАК ВТ_Поступления_БанкМКасса
        |
        |СГРУППИРОВАТЬ ПО
        |	ВТ_Поступления_БанкМКасса.ДокументРТУ
        |;";

    текстЗапросаПризнакОплаты =
        "ВЫБРАТЬ
        |	РеализацияТоваровИУслуг.СуммаДокумента - ЕстьNULL(ВТ_Поступления.СуммаДокумента, 0) КАК ОсталосьОплатить,
        |	ВЫБОР
        |		КОГДА РеализацияТоваровИУслуг.СуммаДокумента - ЕстьNULL(ВТ_Поступления.СуммаДокумента, 0) > 0
        |			И ЕстьNULL(ВТ_Поступления.СуммаДокумента, 0) > 0
        |			ТОГДА ЗНАЧЕНИЕ(Перечисление.ПризнакиОплаты.ЧастичноОплачен)
        |		КОГДА ЕстьNULL(ВТ_Поступления.СуммаДокумента, 0) = 0
        |			ТОГДА ЗНАЧЕНИЕ(Перечисление.ПризнакиОплаты.НеОплачен)
        |		ИНАЧЕ ЗНАЧЕНИЕ(Перечисление.ПризнакиОплаты.ПолностьюОплачен)
        |	КОНЕЦ КАК ПризнакОплаты
        |ИЗ
        |	Документ.РеализацияТоваровИУслуг КАК РеализацияТоваровИУслуг
        |		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Поступления КАК ВТ_Поступления
        |		ПО РеализацияТоваровИУслуг.Ссылка = ВТ_Поступления.ДокументРТУ
        |ГДЕ
        |   РеализацияТоваровИУслуг.Ссылка = &Ссылка
        |";

    запрос.УстановитьПараметр("Ссылка", документРТУСсылка);
    Если исходныйДокументНаОплатуСсылка = Неопределено Тогда
        текстЗапросаПоступлений = СтрЗаменить(текстЗапросаПоступлений,
                "И ДокументПоступления.Ссылка <> &ИсходныйДокументНаОплату", "");
    Иначе
        запрос.УстановитьПараметр("ИсходныйДокументНаОплату", исходныйДокументНаОплатуСсылка);
    КонецЕсли;

    запрос.Текст = СтрШаблон("%1%2", текстЗапросаПоступлений, текстЗапросаПризнакОплаты);

    выборка = запрос.Выполнить().Выбрать();
    выборка.Следующий();

    структураОтвета.ПризнакОплаты = выборка.ПризнакОплаты;
    структураОтвета.ОсталосьОплатить = выборка.ОсталосьОплатить;

    ДиагностикаКлиентСервер.Утверждение(выборка.Следующий() = Ложь,
            "Выборка должна содержать только оду запись.");

    Возврат структураОтвета;
КонецФункции

// Получает выборку Номенклатуры текущего документа и остатки на складе по товарам
//
// Параметры:
//  документСсылка - ДокументСсылка.РеализацияТоваровИУслуг
//  склад - СправочникСсылка.Склады
//  моментВремени - МоментВремени
//  менеджерТаблиц - МенеджерВременныхТаблиц, Неопределено
// Возвращаемое значение:
//  - ВыборкаИзРезультатаЗапроса
Функция ПолучитьВыборкуНоменклатурыДокументаИОстатки(Знач документСсылка,
        Знач склад, Знач моментВремени, Знач менеджерТаблиц = Неопределено) Экспорт

    менеджерТаблиц = ?(менеджерТаблиц = Неопределено, Новый МенеджерВременныхТаблиц, менеджерТаблиц);

    запросНоменклатуры = Новый Запрос;
    запросНоменклатуры.МенеджерВременныхТаблиц = менеджерТаблиц;
    запросНоменклатуры.УстановитьПараметр("Ссылка", документСсылка);
    запросНоменклатуры.УстановитьПараметр("Склад", склад);
    запросНоменклатуры.УстановитьПараметр("МоментВремени", моментВремени);

    текстЗапросаТоваровИУслугДокумента =
        "ВЫБРАТЬ    // Товары
        |	РеализацияТоваровИУслугТовары.Товар КАК Номенклатура,
        |	&СКЛАД КАК Склад,
        |	СУММА(РеализацияТоваровИУслугТовары.Количество) КАК Количество,
        |	СУММА(РеализацияТоваровИУслугТовары.Сумма) КАК Сумма
        |ПОМЕСТИТЬ ВТ_Товары
        |ИЗ
        |	Документ.РеализацияТоваровИУслуг.Товары КАК РеализацияТоваровИУслугТовары
        |ГДЕ
        |	РеализацияТоваровИУслугТовары.Ссылка = &Ссылка
        |
        |СГРУППИРОВАТЬ ПО
        |	РеализацияТоваровИУслугТовары.Товар
        |
        |ОБЪЕДИНИТЬ ВСЕ
        |
        |ВЫБРАТЬ    // Услуги
        |	РеализацияТоваровИУслугУслуги.Услуга,
        |	NULL,
        |	NULL,
        |	СУММА(РеализацияТоваровИУслугУслуги.Стоимость)
        |ИЗ
        |	Документ.РеализацияТоваровИУслуг.Услуги КАК РеализацияТоваровИУслугУслуги
        |ГДЕ
        |	РеализацияТоваровИУслугУслуги.Ссылка = &Ссылка
        |
        |СГРУППИРОВАТЬ ПО
        |	РеализацияТоваровИУслугУслуги.Услуга
        |
        |ИНДЕКСИРОВАТЬ ПО
        |	Номенклатура
        |;";

    текстЗапросаОстатковПоТоварам =
        "ВЫБРАТЬ
        |	ВТ_Товары.Номенклатура КАК Номенклатура,
        |	ВЫБОР
        |		КОГДА ВТ_Товары.Номенклатура.ТипНоменклатуры = ЗНАЧЕНИЕ(Перечисление.ТипыНоменклатуры.Услуга)
        |			ТОГДА ЛОЖЬ
        |		ИНАЧЕ ИСТИНА
        |	КОНЕЦ КАК ЭтоТовар,
        |	ВТ_Товары.Номенклатура.Представление КАК НоменклатураПредставление,
        |	ВТ_Товары.Количество КАК КоличествоВДокументе,
        |	ВТ_Товары.Сумма КАК СуммаВДокументе,
        |	ВТ_Товары.Склад КАК Склад,
        |	ТоварыНаСкладахОстатки.СрокГодности КАК СрокГодности,
        |	ЕстьNULL(ТоварыНаСкладахОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток,
        |	ЕстьNULL(ТоварыНаСкладахОстатки.СуммаОстаток, 0) КАК СуммаОстаток,
        |	ВТ_Товары.Номенклатура.СтатьяЗатрат КАК СтатьяЗатрат,
        |   ВТ_Товары.Номенклатура.СчетБухгалтерскогоУчета КАК СчетБухгалтерскогоУчета
        |ИЗ
        |	ВТ_Товары КАК ВТ_Товары
        |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыНаСкладах.Остатки(
        |			&МоментВремени,
        |			Склад = &Склад
        |               И Номенклатура В (
        |				ВЫБРАТЬ
        |					ВТ_Товары.Номенклатура
        |				ИЗ
        |					ВТ_Товары КАК ВТ_Товары)) КАК ТоварыНаСкладахОстатки
        |		ПО ВТ_Товары.Номенклатура = ТоварыНаСкладахОстатки.Номенклатура
        |
        |УПОРЯДОЧИТЬ ПО
        |	ТоварыНаСкладахОстатки.СрокГодности
        |ИТОГИ
        |	МАКСИМУМ(КоличествоВДокументе),
        |	МАКСИМУМ(СуммаВДокументе),
        |	СУММА(КоличествоОстаток)
        |ПО
        |	Номенклатура
        |";

    запросНоменклатуры.Текст = СтрШаблон("%1%2", текстЗапросаТоваровИУслугДокумента, текстЗапросаОстатковПоТоварам);

    Возврат запросНоменклатуры.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
КонецФункции

Функция ПолучитьОстатокПоЗаписиКлиента(Знач записьКлиентаСсылка,
        Знач моментВремени = Неопределено, Знач клиентСсылка = Неопределено) Экспорт

    запрос = Новый Запрос;
    запрос.Текст =
        "ВЫБРАТЬ
        |	ЗаказыКлиентовОстатки.ЗаписьКлиента.Представление КАК ЗаписьКлиентаПредставление,
        |	ЗаказыКлиентовОстатки.СуммаОстаток КАК СуммаОстаток,
        |	ЗаказыКлиентовОстатки.Клиент КАК Клиент
        |ИЗ
        |	РегистрНакопления.ЗаказыКлиентов.Остатки(&МоментВремени, ЗаписьКлиента = &ЗаписьКлиента И Клиент = &Клиент) КАК ЗаказыКлиентовОстатки
        |";

    запрос.УстановитьПараметр("ЗаписьКлиента", записьКлиентаСсылка);

    Если клиентСсылка = Неопределено Тогда
        запрос.Текст = СтрЗаменить(запрос.Текст, " И Клиент = &Клиент", "");
    Иначе
        запрос.УстановитьПараметр("Клиент", клиентСсылка);
    КонецЕсли;

    Если моментВремени = Неопределено Тогда
        запрос.Текст = СтрЗаменить(запрос.Текст, "&МоментВремени", "");
    Иначе
        запрос.УстановитьПараметр("МоментВремени", моментВремени);
    КонецЕсли;

    результатЗапроса = запрос.Выполнить();
    Если результатЗапроса.Пустой() Тогда
        Возврат Неопределено;
    КонецЕсли;

    выборка = результатЗапроса.Выбрать();
    выборка.Следующий();

    Возврат Новый Структура("ЗаписьКлиентаПредставление, Клиент, Сумма",
        выборка.ЗаписьКлиентаПредставление, выборка.Клиент, выборка.СуммаОстаток);
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс

#Область ОбработчикиСобытий

Процедура Печать(ТабДок, Ссылка) Экспорт
    Макет = Документы.РеализацияТоваровИУслуг.ПолучитьМакет("Печать");
    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ
        |	РеализацияТоваровИУслуг.АвторДокумента,
        |	РеализацияТоваровИУслуг.Дата,
        |	РеализацияТоваровИУслуг.Клиент,
        |	РеализацияТоваровИУслуг.Номер,
        |	РеализацияТоваровИУслуг.ДокументОснование,
        |	РеализацияТоваровИУслуг.Сотрудник,
        |	РеализацияТоваровИУслуг.СуммаДокумента,
        |	РеализацияТоваровИУслуг.Услуги.(
        |		НомерСтроки,
        |		Услуга,
        |		Стоимость
        |	),
        |	РеализацияТоваровИУслуг.Товары.(
        |		НомерСтроки,
        |		Товар,
        |		Количество,
        |		Цена,
        |		Сумма
        |	)
        |ИЗ
        |	Документ.РеализацияТоваровИУслуг КАК РеализацияТоваровИУслуг
        |ГДЕ
        |	РеализацияТоваровИУслуг.Ссылка В (&Ссылка)";
    Запрос.Параметры.Вставить("Ссылка", Ссылка);
    Выборка = Запрос.Выполнить().Выбрать();

    ОбластьЗаголовок = Макет.ПолучитьОбласть("Заголовок");
    Шапка = Макет.ПолучитьОбласть("Шапка");
    ОбластьУслугиШапка = Макет.ПолучитьОбласть("УслугиШапка");
    ОбластьУслуги = Макет.ПолучитьОбласть("Услуги");
    ОбластьТоварыШапка = Макет.ПолучитьОбласть("ТоварыШапка");
    ОбластьТовары = Макет.ПолучитьОбласть("Товары");
    Подвал = Макет.ПолучитьОбласть("Подвал");

    ТабДок.Очистить();

    ВставлятьРазделительСтраниц = Ложь;
    Пока Выборка.Следующий() Цикл
        Если ВставлятьРазделительСтраниц Тогда
            ТабДок.ВывестиГоризонтальныйРазделительСтраниц();
        КонецЕсли;

        ТабДок.Вывести(ОбластьЗаголовок);

        Шапка.Параметры.Заполнить(Выборка);
        ТабДок.Вывести(Шапка, Выборка.Уровень());

        ВыборкаУслуги = Выборка.Услуги.Выбрать();
        Если ВыборкаУслуги.Количество() > 0 Тогда
            ТабДок.Вывести(ОбластьУслугиШапка);
            Пока ВыборкаУслуги.Следующий() Цикл
                ОбластьУслуги.Параметры.Заполнить(ВыборкаУслуги);
                ТабДок.Вывести(ОбластьУслуги, ВыборкаУслуги.Уровень());
            КонецЦикла;
        КонецЕсли;

        ВыборкаТовары = Выборка.Товары.Выбрать();
        Если ВыборкаТовары.Количество() > 0 Тогда
            ТабДок.Вывести(ОбластьТоварыШапка);
            Пока ВыборкаТовары.Следующий() Цикл
                ОбластьТовары.Параметры.Заполнить(ВыборкаТовары);
                ТабДок.Вывести(ОбластьТовары, ВыборкаТовары.Уровень());
            КонецЦикла;
        КонецЕсли;

        Подвал.Параметры.Заполнить(Выборка);
        ТабДок.Вывести(Подвал);

        ВставлятьРазделительСтраниц = Истина;
    КонецЦикла;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы
