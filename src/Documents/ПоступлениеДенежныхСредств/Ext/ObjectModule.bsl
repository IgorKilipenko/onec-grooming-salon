﻿#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(данныеЗаполнения, __, ___)
    заполнитьДокументНаОсновании(данныеЗаполнения);
    РаботаСДокументами.ЗаполнитьПолеАвторДокументаНаСервере(ЭтотОбъект);
КонецПроцедуры

Процедура ОбработкаПроведения(_, __)
    выполнитьВсеДвижения();
    обновитьСтатусОплатыДокументаРТУ();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

Функция обновитьСтатусОплатыДокументаРТУ()
    Если ЗначениеЗаполнено(ДокументОснование) И ТипЗнч(ДокументОснование) = Тип("ДокументСсылка.РеализацияТоваровИУслуг") Тогда
        документРТУОбъект = ДокументОснование.ПолучитьОбъект();
        Если НЕ документРТУОбъект.Заблокирован() Тогда
            документРТУОбъект.ОбновитьСтатусОплатыДокумента();
            Если документРТУОбъект.Модифицированность() Тогда
                документРТУОбъект.Записать(РежимЗаписиДокумента.Запись);
            КонецЕсли;
            Возврат Истина;
        КонецЕсли;
    КонецЕсли;

    Возврат Ложь;
КонецФункции

#Область Движения
Процедура выполнитьВсеДвижения()
    Движения.ДенежныеСредства.Записывать = Истина;
    Движения.БезналичнаяОплата.Записывать = Истина;

    Если ЭтотОбъект.ТипДенежныхСредств = Перечисления.ТипыДенежныхСредств.Наличные Тогда
        выполнитьДвижениеДенежныеСредстваПриход();

    ИначеЕсли ЭтотОбъект.ТипДенежныхСредств = Перечисления.ТипыДенежныхСредств.Безналичные Тогда
        выполнитьДвижениеБезналичнаяОплатаОборот();

    КонецЕсли;

    выполнитьДвижениеБУХозрасчетный();
КонецПроцедуры

Процедура выполнитьДвижениеДенежныеСредстваПриход()
    движение = Движения.ДенежныеСредства.Добавить();
    движение.ВидДвижения = ВидДвиженияНакопления.Приход;
    движение.Период = ЭтотОбъект.Дата;
    движение.БанковскийСчетКасса = ЭтотОбъект.Касса;
    движение.ТипДенежныхСредств = ЭтотОбъект.ТипДенежныхСредств;
    движение.Сумма = ЭтотОбъект.СуммаДокумента;
КонецПроцедуры

Процедура выполнитьДвижениеБезналичнаяОплатаОборот()
    движение = Движения.БезналичнаяОплата.Добавить();
    движение.Период = ЭтотОбъект.Дата;
    движение.ЭквайринговыйТерминал = ЭтотОбъект.ЭквайринговыйТерминал;
    движение.Сумма = ЭтотОбъект.СуммаДокумента;
КонецПроцедуры

Процедура выполнитьДвижениеБУХозрасчетный()
    аналитикаПроводки = ПолучитьАналитикуПроводки();

    Движения.Хозрасчетный.Записывать = Истина;
    движение = Движения.Хозрасчетный.Добавить();

    движение.СчетДт = аналитикаПроводки.СчетДебета;
    движение.СчетКт = аналитикаПроводки.СчетКредита;
    движение.Период = ЭтотОбъект.Дата;
    движение.Сумма = ЭтотОбъект.СуммаДокумента;
    движение.Содержание = аналитикаПроводки.СодержаниеОперации;
    БухгалтерскийУчет.ЗаполнитьСубконтоПоСчету(движение.СчетДт, движение.СубконтоДт, аналитикаПроводки.СубконтоДебет);
    БухгалтерскийУчет.ЗаполнитьСубконтоПоСчету(движение.СчетКт, движение.СубконтоКт, аналитикаПроводки.СубконтоКредит);
КонецПроцедуры
#КонецОбласти // Движения

// Параметры:
//  данныеЗаполнения - ДокументСсылка
//
// Возвращаемое значение:
//  - Булево - Истина если значения заполнены иначе - Ложь
Функция заполнитьДокументНаОсновании(Знач данныеЗаполнения)
    данныеЗаполненияОснования = получитьДанныеЗаполненияНаОсновании(данныеЗаполнения);
    Если данныеЗаполненияОснования = Неопределено Тогда
        Возврат Ложь;
    КонецЕсли;

    ЗаполнитьЗначенияСвойств(ЭтотОбъект, данныеЗаполненияОснования);
    ЭтотОбъект.ДокументОснование = данныеЗаполнения;

    Возврат Истина;
КонецФункции

// Параметры:
//  данныеЗаполнения - ДокументСсылка
//
// Возвращаемое значение:
//  - Структура, Неопределено
Функция получитьДанныеЗаполненияНаОсновании(Знач данныеЗаполнения)
    результат = Неопределено;
    Если данныеЗаполнения = Неопределено ИЛИ НЕ ЗначениеЗаполнено(данныеЗаполнения) Тогда
        Возврат результат;
    КонецЕсли;

    типДокументаОСнования = ТипЗнч(данныеЗаполнения);
    Если типДокументаОСнования = Тип("ДокументСсылка.РеализацияТоваровИУслуг") Тогда
        данныеЗаполнения = РаботаСРеквизитами.ЗначенияРеквизитовОбъекта(данныеЗаполнения.Ссылка, "Клиент, СуммаДокумента");

        ДиагностикаКлиентСервер.Утверждение(ЗначениеЗаполнено(данныеЗаполнения.Клиент),
            СтрШаблон("Поле ""%1"" Документа основания ""%2"" должно быть заполнено", "Клиент",
                Строка(Тип("ДокументСсылка.РеализацияТоваровИУслуг"))),
            "ПоступлениеДенежныхСредств.МодульОбъекта.заполнитьДокументНаОсновании");

        результат = Новый Структура;
        результат.Вставить("ВидОперации", Перечисления.ВидыОперацийПоступленияДенег.ОплатаОтПокупателя);
        результат.Вставить("Плательщик", данныеЗаполнения.Клиент);
        результат.Вставить("СуммаДокумента", данныеЗаполнения.СуммаДокумента);

        кассаПоУмолчанию = Документы.ПоступлениеДенежныхСредств.ПолучитьКассуПоУмолчанию();
        результат.Вставить("Касса", ?(ЗначениеЗаполнено(кассаПоУмолчанию), кассаПоУмолчанию, ЭтотОбъект.Касса));
    КонецЕсли;

    Возврат результат;
КонецФункции

Функция ПолучитьАналитикуПроводки()
    значенияПолей = Новый Структура;
    значенияПолей.Вставить("Плательщик", ЭтотОбъект.Плательщик);
    значенияПолей.Вставить("Касса", ЭтотОбъект.Касса);
    значенияПолей.Вставить("ЭквайринговыйТерминал", ЭтотОбъект.ЭквайринговыйТерминал);
    значенияПолей.Вставить("РасчетныйСчет", ЭтотОбъект.РасчетныйСчет);

    Возврат Документы.ПоступлениеДенежныхСредств.ПолучитьАналитикуПроводки(
        ЭтотОбъект.ВидОперации, ЭтотОбъект.ТипДенежныхСредств, значенияПолей);
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
