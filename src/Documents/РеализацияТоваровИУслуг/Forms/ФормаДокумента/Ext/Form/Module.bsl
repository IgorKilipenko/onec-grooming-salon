﻿#Область ОписаниеПеременных

// Хранит названия табличных частей и наименования столбцов необходимые
// для расчета суммы документа
&НаКлиенте
Перем _ПоляРасчетаСуммыДокумента;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(_)
    _ПоляРасчетаСуммыДокумента = получитьПоляИтогов();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы

#Область ОбработчикиСобытийЭлементовТаблицыФормыТовары

&НаКлиенте
Процедура ТоварыКоличествоПриИзменении(_)
    текущаяСтрокаТовары = Элементы.Товары.ТекущиеДанные;
    обновитьСуммуДокумента(текущаяСтрокаТовары);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыТоварПриИзменении(_)
    текущаяСтрокаТовары = Элементы.Товары.ТекущиеДанные;
    текущаяСтрокаТовары.Цена = получитьЦенуПродажи(текущаяСтрокаТовары.Товар);

    обновитьСуммуДокумента(текущаяСтрокаТовары);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПослеУдаления(_)
	обновитьСуммуДокумента();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийЭлементовТаблицыФормыТовары

#Область ОбработчикиСобытийЭлементовТаблицыФормыУслуги

&НаКлиенте
Процедура УслугиУслугаПриИзменении(_)
    текущаяСтрокаУслуги = Элементы.Услуги.ТекущиеДанные;
    текущаяСтрокаУслуги.Стоимость = получитьЦенуПродажи(текущаяСтрокаУслуги.Услуга);

    обновитьСуммуДокумента();
КонецПроцедуры

&НаКлиенте
Процедура УслугиПослеУдаления(_)
	обновитьСуммуДокумента();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийЭлементовТаблицыФормыУслуги

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция рассчитатьСуммуПоСтрокеТовары(текущСтрокаТовары)
    Возврат текущСтрокаТовары.Цена * текущСтрокаТовары.Количество;
КонецФункции

&НаКлиенте
Функция рассчитатьСуммуДокумента()
    Возврат РаботаСДокументамиКлиентСервер.РассчитатьСуммуДокумента(Объект, _ПоляРасчетаСуммыДокумента);
КонецФункции

&НаКлиенте
Процедура обновитьСуммуДокумента(текущаяСтрокаТовары = Неопределено)
    Если текущаяСтрокаТовары <> Неопределено Тогда
        текущаяСтрокаТовары.Сумма = рассчитатьСуммуПоСтрокеТовары(текущаяСтрокаТовары);
    КонецЕсли;

    Объект.СуммаДокумента = рассчитатьСуммуДокумента();
КонецПроцедуры

&НаСервереБезКонтекста
Функция получитьПоляИтогов()
    Возврат Документы.РеализацияТоваровИУслуг.ПолучитьПоляДляРасчетаСуммыДокумента();
КонецФункции

&НаКлиенте
Функция получитьЦенуПродажи(Знач номенклатура)
    цена = РаботаСЦенамиВызовСервера.ПолучитьЦенуПродажиНаДату(номенклатура);

    Если цена = NULL Тогда
        текстСообщения = СтрШаблон("Не удалось получить текущую цену продажи для номенклатуры: ""%1"".\n
                |Проверьте наличие цены для номенклатуры в регистре цен",
                номенклатура);
        ПоказатьПредупреждение( , текстСообщения);
        цена = 0;
    КонецЕсли;

    Возврат цена;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
