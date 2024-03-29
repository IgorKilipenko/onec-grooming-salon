﻿#Область ПрограммныйИнтерфейс

// Параметры:
//  движение - Движение
//  периодНачисления - Дата
//  структураНачисления - Структура, ФиксированнаяСтруктура - Пустая структура начисления
//      * ВидРасчета - ПланВидовРасчетаСсылка.Начисления
//      * ДатаНачала - Дата
//      * ДатаОкончания - Дата
//      * Сотрудник - СправочникСсылка.Сотрудник
//      * ПоказательРасчета - Число
//      * График - СправочникСсылка.График
//      * Сумма - Число, Неопределено
// Возвращаемое значение:
//  - Движение
Функция ЗаполнитьДвижениеНачисления(Знач движение, Знач периодНачисления, Знач структураНачисления) Экспорт
    ДиагностикаКлиентСервер.Утверждение(ЗначениеЗаполнено(структураНачисления.ВидРасчета.СтатьяЗатрат),
        "Статья затрат для поля движения ""ВидРасчета"" должна быть заполнена.");

    движение.Сторно = Ложь;
    движение.ПериодРегистрации = периодНачисления;

    движение.ВидРасчета = структураНачисления.ВидРасчета;
    движение.ПериодДействияНачало = структураНачисления.ДатаНачала;
    движение.ПериодДействияКонец = структураНачисления.ДатаОкончания;
    движение.БазовыйПериодНачало = структураНачисления.ДатаНачала;
    движение.БазовыйПериодКонец = структураНачисления.ДатаОкончания;
    движение.Сотрудник = структураНачисления.Сотрудник;
    движение.ПоказательРасчета = структураНачисления.ПоказательРасчета;
    движение.График = структураНачисления.ГрафикРаботы;

    структураНачисления.Свойство("Сумма", движение.Сумма);
    движение.Сумма = ?(движение.Сумма = Неопределено, 0, движение.Сумма);

    Возврат движение;
КонецФункции

// Возвращаемое значение:
//  - Структура - Пустая структура начисления
//      * ВидРасчета - Неопределено
//      * ДатаНачала - Неопределено
//      * ДатаОкончания - Неопределено
//      * Сотрудник - Неопределено
//      * ПоказательРасчета - Неопределено
//      * График - Неопределено
//      * Сумма - Неопределено
Функция СоздатьПустуюСтруктуруНачисления() Экспорт
    структураНачисления = Новый Структура;

    структураНачисления.Вставить("ВидРасчета");
    структураНачисления.Вставить("ДатаНачала");
    структураНачисления.Вставить("ДатаОкончания");
    структураНачисления.Вставить("ПоказательРасчета");
    структураНачисления.Вставить("ГрафикРаботы");
    структураНачисления.Вставить("Сотрудник");
    структураНачисления.Вставить("Сумма");

    Возврат структураНачисления;
КонецФункции

// Возвращаемое значение:
//  - Массив
Функция ПолучитьКлючиСтруктурыНачисления() Экспорт
    Возврат РаботаСКоллекциямиКлиентСервер.ПолучитьКлючиСтруктуры(СоздатьПустуюСтруктуруНачисления());
КонецФункции

// Параметры:
//  документСсылка - ДокументСсылка.НачислениеЗарплаты, ДокументСсылка.НачислениеПремии
//  выгрузить - Булево - Если Истина, выполнятся выгрузка результатов запроса, иначе результаты возвращаются как выборки
//  получатьДетальные - Булево - Если Истина, Начисления = Неопределено
// Возвращаемое значение:
//  Структура
//  * Начисления - ТаблицаЗначений, ВыборкаИзРезультатаЗапроса, Неопределено
//  * НачисленияПоСтатьямЗатрат - ТаблицаЗначений, ВыборкаИзРезультатаЗапроса
Функция ПолучитьДанныеНачисленийДокумента(Знач документСсылка, Знач выгрузить = Ложь, получатьДетальные = Истина) Экспорт

    метаданныеДокумента = Метаданные.НайтиПоТипу(ТипЗнч(документСсылка));

    #Область ДиагностикаАргументов
    ДиагностикаКлиентСервер.Утверждение(документСсылка <> Неопределено,
        "Аргумент ""ДокументСсылка"" должен иметь определенное значение."".");

    ДиагностикаКлиентСервер.Утверждение(метаданныеДокумента <> Неопределено,
        "Аргумент ""ДокументСсылка"" не определен в метаданных."".");

    ДиагностикаКлиентСервер.Утверждение(
        РаботаСоСтрокамиВызовСервера.ПодобнаПоРегулярномуВыражению(
            метаданныеДокумента.ПолноеИмя(), "^Документ\..+"),
        "Тип аргумента ""ДокументСсылка"" должен быть типом объекта ""Документ"".");
    #КонецОбласти // ДиагностикаАргументов

    запрос = Новый Запрос;
    запрос.УстановитьПараметр("Регистратор", документСсылка);

    текстЗапросаНачисления =
        "ВЫБРАТЬ
        |	Начисления.Сумма КАК Сумма,
        |	Начисления.Сотрудник КАК Сотрудник,
        |	Начисления.ВидРасчета.СтатьяЗатрат КАК СтатьяЗатрат
        |ПОМЕСТИТЬ ВТ_Начисления
        |ИЗ
        |	РегистрРасчета.Начисления КАК Начисления
        |ГДЕ
        |	Начисления.Регистратор ССЫЛКА %1
        |	И Начисления.Регистратор = &Регистратор
        |";

    текстЗапросаНачисленияПоСтатьямЗатрат =
        "ВЫБРАТЬ
        |	СУММА(ВТ_Начисления.Сумма) КАК Сумма,
        |	ВТ_Начисления.СтатьяЗатрат КАК СтатьяЗатрат
        |ИЗ
        |	ВТ_Начисления КАК ВТ_Начисления
        |
        |СГРУППИРОВАТЬ ПО
        |	ВТ_Начисления.СтатьяЗатрат
        |";

    текстЗапросаНачисления = СтрШаблон(текстЗапросаНачисления, метаданныеДокумента.ПолноеИмя());
    запрос.Текст = СтрШаблон(
            "%1
            |;
            |%2", текстЗапросаНачисления, текстЗапросаНачисленияПоСтатьямЗатрат);

    результатЗапроса = Неопределено;
    Если получатьДетальные Тогда
        результатЗапроса = запрос.ВыполнитьПакетСПромежуточнымиДанными();
    Иначе
        результатЗапроса = запрос.ВыполнитьПакет();
    КонецЕсли;

    результат = Новый Структура("Начисления, НачисленияПоСтатьямЗатрат");
    Если получатьДетальные Тогда
        результат.Начисления = ?(выгрузить, результатЗапроса[0].Выгрузить(), результатЗапроса[0].Выбрать());
    КонецЕсли;
    результат.НачисленияПоСтатьямЗатрат = ?(выгрузить, результатЗапроса[1].Выгрузить(), результатЗапроса[1].Выбрать());

    Возврат результат;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс
