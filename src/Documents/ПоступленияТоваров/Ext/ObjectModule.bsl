﻿#Область ПрограммныйИнтерфейс

// Обновляет поле СуммаДокумента.\
// Для корректной рабаты все суммы по строкам ТЧ должны быть предварительно рассчитаны.\
// =========================\
// [примечание разработчика] - в текущей реализации (Спринт 3) не используется.
// Обновление суммы документа выполняется в процессе заполнения формы.
Процедура ОбновитьСуммуДокумента() Экспорт
    опцииРасчета = Документы.ПоступленияТоваров.ПолучитьПоляДляРасчетаСуммыДокумента();
	сумма = РаботаСДокументамиКлиентСервер.РассчитатьСуммуДокумента(ЭтотОбъект, опцииРасчета);
    СуммаДокумента = сумма;
КонецПроцедуры

#КонецОбласти // ПрограммныйИнтерфейс

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(_, __, ___)
    РаботаСДокументами.ЗаполнитьПолеАвторДокументаНаСервере(ЭтотОбъект);
КонецПроцедуры

Процедура ОбработкаПроведения(_, __)
    Если Товары.Количество() = 0 Тогда
        Возврат;
    КонецЕсли;

    Движения.ТоварыНаСкладах.Записывать = Истина;
    Для Каждого ТекСтрокаТовары Из Товары Цикл
        движение = Движения.ТоварыНаСкладах.Добавить();
        движение.ВидДвижения = ВидДвиженияНакопления.Приход;
        движение.Период = Дата;
        движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
        движение.СрокГодности = ТекСтрокаТовары.СрокГодности;
        движение.Склад = Склад;
        движение.Количество = ТекСтрокаТовары.Количество;
    КонецЦикла;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий
