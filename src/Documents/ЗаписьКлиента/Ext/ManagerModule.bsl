﻿#Область ПрограммныйИнтерфейс

// Возвращает ссылку на документ РеализацияТоваровИУслуг созданный на основании документа ЗаписьКлиента.\
// Документ РеализацияТоваровИУслуг должен иметь статус: Проведен
//
// Параметры:
//	записьКлиентаСсылка - ДокументСсылка.ЗаписьКлиента
//
// Возвращаемое значение:
//	- ДокументСсылка.РеализацияТоваровИУслуг, Неопределено
//
Функция ПолучитьДокументРеализацииНаОсновании(Знач записьКлиентаСсылка) Экспорт
    Если НЕ ЗначениеЗаполнено(записьКлиентаСсылка) Тогда
        Возврат Неопределено;
    КонецЕсли;

    запросДокументаРеализации = Новый Запрос;
    запросДокументаРеализации.УстановитьПараметр("Ссылка", записьКлиентаСсылка);

    запросДокументаРеализации.Текст =
        "ВЫБРАТЬ ПЕРВЫЕ 1
        |	РеализацияТоваровИУслуг.Ссылка КАК Ссылка
        |ИЗ
        |	Документ.РеализацияТоваровИУслуг КАК РеализацияТоваровИУслуг
        |ГДЕ
        |	РеализацияТоваровИУслуг.ДокументОснование = &Ссылка
        |		И РеализацияТоваровИУслуг.Проведен
        |";

    результатЗапроса = запросДокументаРеализации.Выполнить();
    Если результатЗапроса.Пустой() Тогда
        Возврат Неопределено;
    КонецЕсли;

    выборка = результатЗапроса.Выбрать();
    выборка.Следующий();

    Возврат выборка.Ссылка;

КонецФункции

// Параметры:
//  записьКлиентаСсылка - ДокументСсылка.ЗаказыКлиентов
// Возвращаемое значение:
//  - Булево - Если Истина - услуга оказана, иначе - Ложь
Функция ПолучитьСтатусОказанияУслуги(Знач записьКлиентаСсылка) Экспорт
    документРТУ = ПолучитьДокументРеализацииНаОсновании(записьКлиентаСсылка);
    Возврат документРТУ <> Неопределено И НЕ документРТУ.Ссылка.Пустая();
КонецФункции

// Параметры:
//	списокНоменклатуры - ТаблицаЗначений, Массив
//	минимальноеВремяОказанияУслугиВМинутах - Число, Неопределено - Минимальная длительность приема клиента, в минутах
//
// Возвращаемое значение:
//	Число - Время оказания услуг, в минутах
//
Функция РассчитатьДлительностьОказанияУслуг(Знач списокНоменклатуры, Знач минимальноеВремяОказанияУслугиВМинутах = Неопределено) Экспорт

    Если минимальноеВремяОказанияУслугиВМинутах = Неопределено Тогда
        минимальноеВремяОказанияУслугиВМинутах = ПолучитьМинимальноеВремяОказанияУслугиВМинутах();
    КонецЕсли;

    Если НЕ ЗначениеЗаполнено(списокНоменклатуры)
        ИЛИ НЕ проверитьЭтоДопустимоеЗначениеСпискаНоменклатуры(
            списокНоменклатуры, "Документы.ЗаписьКлиента.РассчитатьДатуОкончанияЗаписи") Тогда
        Возврат минимальноеВремяОказанияУслугиВМинутах;
    КонецЕсли;

    Если ТипЗнч(списокНоменклатуры) = Тип("Массив") Тогда
        услугиТЗ = РаботаСКоллекциями.КонвертироватьМассивВТаблицуЗначений(списокНоменклатуры,
                Метаданные.Документы.ЗаписьКлиента.ТабличныеЧасти.Услуги.Реквизиты.Услуга.Имя,
                Тип("СправочникСсылка.Номенклатура"));
    Иначе
        услугиТЗ = списокНоменклатуры;
    КонецЕсли;

    запрос = Новый Запрос;
    запрос.УстановитьПараметр("УслугиТЗ", услугиТЗ);

    запрос.Текст =
        "ВЫБРАТЬ
        |	УслугиТЗ.Услуга КАК Номенклатура
        |ПОМЕСТИТЬ ВТ_Услуги
        |ИЗ
        |	&УслугиТЗ КАК УслугиТЗ
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ
        |	ЕстьNULL(СУММА(НоменклатураТиУ.ДлительностьУслуги), 0) КАК ДлительностьУслуги
        |ИЗ
        |	ВТ_Услуги КАК ВТ_Услуги
        |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК НоменклатураТиУ
        |		ПО ВТ_Услуги.Номенклатура = НоменклатураТиУ.Ссылка
        |";

    результат = запрос.Выполнить();
    Если результат.Пустой() Тогда
        Возврат минимальноеВремяОказанияУслугиВМинутах;
    КонецЕсли;

    выборка = запрос.Выполнить().Выбрать();
    выборка.Следующий();
    Возврат Макс(выборка.ДлительностьУслуги, минимальноеВремяОказанияУслугиВМинутах);
КонецФункции

// Возвращаемое значение:
//	- Число - Минимальная длительность приема клиента, в минутах
Функция ПолучитьМинимальноеВремяОказанияУслугиВМинутах() Экспорт
    Возврат 60;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Если проверка не пройдена - вызывает исключение
//
// Параметры:
//	списокНоменклатуры - ТаблицаЗначений, Массив
//	контекстДиагностики - Строка
//
// Возвращаемое значение:
//	Булево
Функция проверитьЭтоДопустимоеЗначениеСпискаНоменклатуры(Знач списокНоменклатуры, контекстДиагностики = Неопределено)
    контекстДиагностики = ?(ЗначениеЗаполнено(контекстДиагностики),
            контекстДиагностики, "Документы.ЗаписьКлиента.проверитьЭтоДопустимоеЗначениеСпискаНоменклатуры");
    имяАргументаДиагностики = "СписокНоменклатуры";
    имяКолонкиНоменклатура = Метаданные.Документы.ЗаписьКлиента.ТабличныеЧасти.Услуги.Реквизиты.Услуга.Имя;
    типЗнчСпискаНоменклатуры = ТипЗнч(списокНоменклатуры);

    ДиагностикаКлиентСервер.Утверждение(списокНоменклатуры <> Неопределено,
        СтрШаблон("Аргумент ""%1"" не может иметь значение ""Неопределено""",
            имяАргументаДиагностики),
        контекстДиагностики);

    этоДопустимыйТипСпискаНоменклатуры = типЗнчСпискаНоменклатуры = Тип("ТаблицаЗначений")
        ИЛИ типЗнчСпискаНоменклатуры = Тип("Массив");

    ДиагностикаКлиентСервер.Утверждение(этоДопустимыйТипСпискаНоменклатуры,
        СтрШаблон("Аргумент ""%1"" имеет недопустимый тип ""%2"" значения",
            имяАргументаДиагностики, имяКолонкиНоменклатура),
        контекстДиагностики);

    ДиагностикаКлиентСервер.Утверждение(типЗнчСпискаНоменклатуры <> Тип("ТаблицаЗначений")
        ИЛИ списокНоменклатуры.Колонки.Найти(имяКолонкиНоменклатура) <> Неопределено,
        СтрШаблон("Аргумент ""%1"" типа ""ТаблицаЗначений"" и должен иметь колонку ""%2""",
            имяАргументаДиагностики, имяКолонкиНоменклатура),
        контекстДиагностики);

    Возврат Истина;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
