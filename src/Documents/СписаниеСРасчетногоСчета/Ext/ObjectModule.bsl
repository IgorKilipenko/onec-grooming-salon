﻿#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(отказ, __)
    движенияВыполненыУспешно = выполнитьВсеДвижения();
    Если НЕ движенияВыполненыУспешно Тогда
        отказ = Истина;
    КонецЕсли;
КонецПроцедуры

Процедура ОбработкаЗаполнения(данныеЗаполнения, __)
    заполнитьДокументНаОсновании(данныеЗаполнения);
    РаботаСДокументами.ЗаполнитьПолеАвторДокументаНаСервере(ЭтотОбъект);
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

#Область Движения
Функция выполнитьВсеДвижения()
    выполнитьДвижениеДенежныеСредстваРасход();
    выполнитьДвижениеБУХозрасчетный();
    Движения.Записать();

    результатКонтроляОстатковДС = выполнитьКонтрольОстатковДенежныхСредств();

    Если результатКонтроляОстатковДС.Отказ Тогда
        Для Каждого описаниеОшибки Из результатКонтроляОстатковДС.ОписанияОшибок Цикл
            сообщение = Новый СообщениеПользователю;
            сообщение.Текст = описаниеОшибки.Сообщение;
            сообщение.Поле = описаниеОшибки.Поле;
            сообщение.УстановитьДанные(ЭтотОбъект);
            сообщение.Сообщить();
        КонецЦикла;

        Возврат Ложь; // Превышены остатки ДС
    КонецЕсли;

    Возврат Истина; // Контроль прошел успешно, превышений остатков ДС нет
КонецФункции

Функция выполнитьДвижениеБУХозрасчетный()
    Движения.Хозрасчетный.Записывать = Истина;
    Если ЭтотОбъект.ВидОперации = Перечисления.ВидыОперацийСписанияСРасчетногоСчета.СнятиеНаличныхВКассу Тогда
        Возврат Ложь; // Бухгалтерские проводки по взносу наличными формируются документом Расход денежных средств
    КонецЕсли;

    аналитикаПроводки = ПолучитьАналитикуПроводки();

    движение = Движения.Хозрасчетный.Добавить();
    движение.СчетДт = аналитикаПроводки.Дебет.Счет;
    движение.СчетКт = аналитикаПроводки.Кредит.Счет;
    движение.Период = ЭтотОбъект.Дата;
    движение.Сумма = ЭтотОбъект.СуммаДокумента;
    движение.Содержание = аналитикаПроводки.СодержаниеОперации;
    БухгалтерскийУчет.ЗаполнитьСубконтоПоСчету(движение.СчетДт, движение.СубконтоДт, аналитикаПроводки.Дебет.Субконто);
    БухгалтерскийУчет.ЗаполнитьСубконтоПоСчету(движение.СчетКт, движение.СубконтоКт, аналитикаПроводки.Кредит.Субконто);

    Возврат Истина;
КонецФункции

Процедура выполнитьДвижениеДенежныеСредстваРасход()
    движение = Движения.ДенежныеСредства.Добавить();
    движение.ВидДвижения = ВидДвиженияНакопления.Расход;
    движение.Период = ЭтотОбъект.Дата;
    движение.ТипДенежныхСредств = Перечисления.ТипыДенежныхСредств.Безналичные;
    движение.БанковскийСчетКасса = ЭтотОбъект.РасчетныйСчет;
    движение.Сумма = ЭтотОбъект.СуммаДокумента;

    Движения.ДенежныеСредства.БлокироватьДляИзменения = Истина;
    Движения.ДенежныеСредства.Записывать = Истина;
КонецПроцедуры
#КонецОбласти // Движения

Функция выполнитьКонтрольОстатковДенежныхСредств()
    результат = Новый Структура("Отказ, ОписанияОшибок", Ложь, Новый Массив);
    остатокДС = Справочники.БанковскиеСчета.ПолучитьОстатокДенежныхСредствНаРасчетномСчете(
            ЭтотОбъект.РасчетныйСчет, Новый Граница(МоментВремени()));
    Если остатокДС = Неопределено ИЛИ остатокДС.Сумма < 0 Тогда
        форматФинансовыхДанных = "ЧДЦ=2; ЧРГ= ; ЧН=0.00";
        результат.Отказ = Истина;
        результат.ОписанияОшибок.Добавить(Новый Структура("Сообщение, Поле",
                СтрШаблон(
                    "По расчетному счету ""%1"" недостаточно денежных средств для списания в размере: %2.
                    |Текущий остаток на расчетном счете: %3.",
                    остатокДС.РасчетныйСчет,
                    Формат(-остатокДС.Сумма, форматФинансовыхДанных),
                    Формат(СуммаДокумента + остатокДС.Сумма, форматФинансовыхДанных)), "СуммаДокумента"));
    КонецЕсли;

    Возврат результат;
КонецФункции

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
//  документОснованиеСсылка - ДокументСсылка
// Возвращаемое значение:
//  - Структура - Структура вида: { Получатель, СуммаДокумента, [ДоговорПоставщика] }
Функция получитьДанныеЗаполненияНаОсновании(Знач документОснованиеСсылка)
    Если НЕ ЗначениеЗаполнено(документОснованиеСсылка) Тогда
        Возврат Неопределено;
    КонецЕсли;

    типДокументаОснования = ТипЗнч(документОснованиеСсылка);
    этоРеализацияТиУ = типДокументаОснования = Тип("ДокументСсылка.РеализацияТоваровИУслуг");
    этоПоступлениеТиМ = типДокументаОснования = Тип("ДокументСсылка.ПоступлениеТоваров");
    этоПоступлениеУслуг = типДокументаОснования = Тип("ДокументСсылка.ПоступлениеУслуг");

    Если НЕ (этоРеализацияТиУ ИЛИ этоПоступлениеТиМ ИЛИ этоПоступлениеУслуг) Тогда
        Возврат Неопределено;
    КонецЕсли;

    результат = Новый Структура;

    Если этоРеализацияТиУ Тогда
        результат = получитьДанныеПоРеализацииТоваровИУслуг(документОснованиеСсылка);
    Иначе
        результат = получитьДанныеПоПоступлениюТоваровИМатериаловИлиУслуг(документОснованиеСсылка);
    КонецЕсли;

    Возврат результат;
КонецФункции

Функция получитьДанныеПоРеализацииТоваровИУслуг(Знач ссылка)
    выбираемыеРеквизиты = Новый Структура;
    выбираемыеРеквизиты.Вставить("Клиент", "Получатель");
    выбираемыеРеквизиты.Вставить("СуммаДокумента", "СуммаДокумента");

    результат = РаботаСРеквизитами.ЗначенияРеквизитовОбъекта(ссылка, выбираемыеРеквизиты);
    результат.Вставить("ВидОперации", Перечисления.ВидыОперацийСписанияСРасчетногоСчета.ВозвратПокупателю);

    Возврат результат;
КонецФункции

Функция получитьДанныеПоПоступлениюТоваровИМатериаловИлиУслуг(Знач ссылка)
    выбираемыеРеквизиты = Новый Структура;
    выбираемыеРеквизиты.Вставить("Поставщик", "Получатель");
    выбираемыеРеквизиты.Вставить("ДоговорПоставщика", "ДоговорКонтрагента");
    выбираемыеРеквизиты.Вставить("СуммаДокумента", "СуммаДокумента");

    результат = РаботаСРеквизитами.ЗначенияРеквизитовОбъекта(ссылка, выбираемыеРеквизиты);
    результат.Вставить("ВидОперации", Перечисления.ВидыОперацийСписанияСРасчетногоСчета.ОплатаПоставщику);

    Возврат результат;
КонецФункции

Функция ПолучитьАналитикуПроводки()
    значенияПолей = Новый Структура;
    значенияПолей.Вставить("Получатель", ЭтотОбъект.Получатель);
    значенияПолей.Вставить("РасчетныйСчет", ЭтотОбъект.РасчетныйСчет);

    Возврат Документы.СписаниеСРасчетногоСчета.ПолучитьАналитикуПроводки(ЭтотОбъект.ВидОперации, значенияПолей);
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
