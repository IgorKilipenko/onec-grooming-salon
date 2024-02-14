﻿#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(данныеЗаполнения, __)
    Если ТипЗнч(данныеЗаполнения) = Тип("ДокументСсылка.РеализацияТоваровИУслуг") Тогда
        ЭтотОбъект.ДокументОснование = данныеЗаполнения.Ссылка;
        ЭтотОбъект.ВидОперации = Перечисления.ВидыОперацийПоступленияДенег.ОплатаОтПокупателя;
        ЭтотОбъект.ТипДенежныхСредств = Перечисления.ТипыДенежныхСредств.Наличные;
        ЭтотОбъект.Плательщик = данныеЗаполнения.Клиент;
        ЭтотОбъект.СуммаДокумента = данныеЗаполнения.СуммаДокумента;

        основнаяКасса = Справочники.Кассы.ПолучитьОсновнуюКассу();
        Если ЗначениеЗаполнено(основнаяКасса) Тогда
            ЭтотОбъект.Касса = основнаяКасса;
        КонецЕсли;
    КонецЕсли;

    РаботаСДокументами.ЗаполнитьПолеАвторДокументаНаСервере(ЭтотОбъект);
КонецПроцедуры

Процедура ОбработкаПроведения(_, __)
    очиститьДвижения();

    Если ТипДенежныхСредств = Перечисления.ТипыДенежныхСредств.Наличные Тогда
        Движения.ДенежныеСредства.Записывать = Истина;
        выполнитьДвижениеДенежныеСредстваПриход();

    ИначеЕсли ТипДенежныхСредств = Перечисления.ТипыДенежныхСредств.Безналичные Тогда
        Движения.БезналичнаяОплата.Записывать = Истина;
        выполнитьДвижениеБезналичнаяОплатаОборот();

    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

#Область Движения
Процедура очиститьДвижения()
    Движения.ДенежныеСредства.Записывать = Истина;
    Движения.БезналичнаяОплата.Записывать = Истина;

    Движения.Записать();
КонецПроцедуры

Процедура выполнитьДвижениеДенежныеСредстваПриход()
    движение = Движения.ДенежныеСредства.Добавить();
    движение.ВидДвижения = ВидДвиженияНакопления.Приход;
    движение.Период = Дата;
    движение.БанковскийСчетКасса = Касса;
    движение.ТипДенежныхСредств = ТипДенежныхСредств;
    движение.Сумма = СуммаДокумента;
КонецПроцедуры

Процедура выполнитьДвижениеБезналичнаяОплатаОборот()
    движение = Движения.БезналичнаяОплата.Добавить();
    движение.Период = Дата;
    движение.ЭквайринговыйТерминал = ЭквайринговыйТерминал;
    движение.Сумма = СуммаДокумента;
КонецПроцедуры
#КонецОбласти // Движения

#КонецОбласти // СлужебныеПроцедурыИФункции
