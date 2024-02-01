﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(_, __)
    ЭтотОбъект.ДатаНачалаДействияЦены = НачалоДня(ТекущаяДатаСеанса());
    ЭтотОбъект.Номенклатура = Параметры.Номенклатура;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы

#Область ОбработчикиКомандФормы

&НаСервере
Процедура ЗаписатьНаСервере()
    наборЗаписейРегистра = РегистрыСведений.ЦеныНоменклатуры.СоздатьНаборЗаписей();
    наборЗаписейРегистра.Отбор.Номенклатура.Установить(Номенклатура);
    наборЗаписейРегистра.Отбор.ВидЦены.Установить(ВидЦены);
    наборЗаписейРегистра.Отбор.Период.Установить(ДатаНачалаДействияЦены);

    наборЗаписейРегистра.Прочитать();
    Если наборЗаписейРегистра.Количество() Тогда
        наборЗаписейРегистра[0].Цена = Цена;

    Иначе
        новаяЗаписьЦены = наборЗаписейРегистра.Добавить();
        новаяЗаписьЦены.Номенклатура = Номенклатура;
        новаяЗаписьЦены.ВидЦены = ВидЦены;
        новаяЗаписьЦены.Период = ДатаНачалаДействияЦены;
        новаяЗаписьЦены.Цена = Цена;
    КонецЕсли;

    наборЗаписейРегистра.Записать();
КонецПроцедуры

&НаКлиенте
Процедура Записать(_)
    ценаНаДату = РаботаСЦенамиВызовСервера.ПолучитьЦенуНаКонкретнуюДату(
            ЭтотОбъект.Номенклатура, ЭтотОбъект.ВидЦены, ЭтотОбъект.ДатаНачалаДействияЦены);
    Если ценаНаДату <> Неопределено Тогда

        текстВопроса = СтрШаблон("На указанную дату уже имеется введенная цена %1, вы действительно хотите изменить цену?", ценаНаДату);
        оповещение = Новый ОписаниеОповещения("_послеОтветаНаВопросОбИзмененииЦены_ОВ", ЭтотОбъект);
        ПоказатьВопрос(оповещение, текстВопроса, РежимДиалогаВопрос.ДаНет, , , "Внимание!");
    Иначе
        записатьИЗакрыть();

    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиКомандФормы

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура записатьИЗакрыть()
    ЗаписатьНаСервере();
    Закрыть();
КонецПроцедуры

#КонецОбласти // СлужебныеПроцедурыИФункции

#Область СлужебныйПрограммныйИнтерфейс

&НаКлиенте
Процедура _послеОтветаНаВопросОбИзмененииЦены_ОВ(результатДиалога, __) Экспорт
    Если результатДиалога = КодВозвратаДиалога.Да Тогда
        записатьИЗакрыть();
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // СлужебныйПрограммныйИнтерфейс
