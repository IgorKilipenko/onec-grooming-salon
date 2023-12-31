﻿#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(данныеЗаполнения, __, ___)
    Если ТипЗнч(данныеЗаполнения) = Тип("ДокументСсылка.ЗаписьКлиента") Тогда
        Клиент = данныеЗаполнения.Клиент;
        Сотрудник = данныеЗаполнения.Сотрудник;
        Основание = данныеЗаполнения.Ссылка;
        СуммаДокумента = 0.0;

        Для Каждого текСтрокаУслуги Из данныеЗаполнения.Услуги Цикл
            новаяСтрока = Услуги.Добавить();
            новаяСтрока.Стоимость = текСтрокаУслуги.Стоимость;
            новаяСтрока.Услуга = текСтрокаУслуги.Услуга;
            СуммаДокумента = СуммаДокумента + текСтрокаУслуги.Стоимость;
        КонецЦикла;
    КонецЕсли;

    РаботаСДокументами.ЗаполнитьПолеАвторДокументаНаСервере(ЭтотОбъект);
КонецПроцедуры

Процедура ОбработкаПроведения(_, __)

    Движения.ТоварыНаСкладах.Записывать = Товары.Количество() > 0;
    Движения.Продажи.Записывать = Товары.Количество() > 0 ИЛИ Услуги.Количество() > 0;

    Для Каждого текСтрокаТовары Из Товары Цикл
        выполнитьДвижениеТоварыНаСкладахРасход(текСтрокаТовары);
        выполнитьДвижениеПродажиТоваровОборот(текСтрокаТовары);
    КонецЦикла;

    Для Каждого текСтрокаУслуги Из Услуги Цикл
        выполнитьДвижениеПродажиУслугОборот(текСтрокаУслуги);
    КонецЦикла;

    Если (НЕ Основание.Пустая()) И ТипЗнч(Основание) = Тип("ДокументСсылка.ЗаписьКлиента") Тогда
        Движения.ЗаказыКлиентов.Записывать = Истина;
        выполнитьДвижениеЗаказыКлиентовРасход();
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

#Область Движения
Процедура выполнитьДвижениеТоварыНаСкладахРасход(текСтрокаТовары)
    движение = Движения.ТоварыНаСкладах.Добавить();
    движение.ВидДвижения = ВидДвиженияНакопления.Расход;
    движение.Период = Дата;
    движение.Номенклатура = текСтрокаТовары.Товар;
    движение.Склад = Склад;
    движение.Количество = текСтрокаТовары.Количество;
КонецПроцедуры

Процедура выполнитьДвижениеЗаказыКлиентовРасход()
    движение = Движения.ЗаказыКлиентов.Добавить();
    движение.ВидДвижения = ВидДвиженияНакопления.Расход;
    движение.Период = Дата;
    движение.Клиент = Клиент;
    движение.ЗаписьКлиента = Основание;
    движение.Сумма = СуммаДокумента;
КонецПроцедуры

Функция создатьДвижениеПродажиОборот()
    движение = Движения.Продажи.Добавить();
    движение.Период = Дата;
    движение.Клиент = Клиент;
    движение.Сотрудник = Сотрудник;

    Возврат движение;
КонецФункции

Процедура выполнитьДвижениеПродажиТоваровОборот(текСтрокаТовары)
    движение = создатьДвижениеПродажиОборот();
    движение.Номенклатура = текСтрокаТовары.Товар;
    движение.Сумма = текСтрокаТовары.Сумма;
КонецПроцедуры

Процедура выполнитьДвижениеПродажиУслугОборот(текСтрокаУслуги)
    движение = создатьДвижениеПродажиОборот();
    движение.Номенклатура = текСтрокаУслуги.Услуга;
    движение.Сумма = текСтрокаУслуги.Стоимость;
КонецПроцедуры
#КонецОбласти // Движения

#КонецОбласти // СлужебныеПроцедурыИФункции
