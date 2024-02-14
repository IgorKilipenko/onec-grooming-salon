﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(_, __)
    Если НЕ Объект.Ссылка.Пустая() Тогда
        Объект.УслугаОказана = получитьСтатусОказанияУслуги(Объект.Ссылка);

    Иначе
        Если Параметры.Свойство("Начало") Тогда
            Объект.ДатаЗаписи = Параметры.Начало;
        КонецЕсли;

        Если Параметры.Свойство("Окончание") Тогда
            Объект.ДатаОкончанияЗаписи = Параметры.Окончание;
        КонецЕсли;

        Если Параметры.Свойство("Сотрудник") Тогда
            Объект.Сотрудник = Параметры.Сотрудник;
        КонецЕсли;
    КонецЕсли;

    установитьДоступностьЭлементовФормыНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
    Объект.УслугаОказана = получитьСтатусОказанияУслуги(Объект.Ссылка);
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(_)
    параметрыОповещенияЗаписиКлиента = Новый Структура("Документ", Объект.Ссылка);
    Оповестить("Записан заказ", параметрыОповещенияЗаписиКлиента, ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(имяСобытия, параметрыСобытия, ___)
    Если имяСобытия = "Записан документРТУ" Тогда
        документОснованиеИсточника = ?(параметрыСобытия.Свойство("ДокументОснование"),
                параметрыСобытия.ДокументОснование, Неопределено);
        Если документОснованиеИсточника = Объект.Ссылка Тогда
            Объект.УслугаОказана = получитьСтатусОказанияУслуги(Объект.Ссылка);
        КонецЕсли;
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы

#Область ОбработчикиСобытийЭлементовТаблицыФормыУслуги

&НаКлиенте
Процедура УслугиУслугаПриИзменении(_)
    текущаяСтрокаУслуги = Элементы.Услуги.ТекущиеДанные;
    текущаяСтрокаУслуги.Стоимость = получитьЦенуПродажи(текущаяСтрокаУслуги.Услуга);
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийЭлементовТаблицыФормыУслуги

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция получитьЦенуПродажи(Знач номенклатура)
    цена = РаботаСЦенамиВызовСервера.ПолучитьЦенуПродажиНаДату(номенклатура);

    Если цена = Неопределено Тогда
        текстСообщения = СтрШаблон(
                "Не удалось получить текущую цену продажи для номенклатуры: ""%1"".
                |Проверьте наличие цены для номенклатуры в регистре цен",
                номенклатура);
        ПоказатьПредупреждение( , текстСообщения, , "Внимание!");
        цена = 0;
    КонецЕсли;

    Возврат цена;
КонецФункции

&НаСервере
Процедура установитьДоступностьЭлементовФормыНаСервере()
    этоПривилегированныйПользователь = РольДоступна("ПолныеПрава") ИЛИ ПривилегированныйРежим();
    Элементы.УслугаОказана.ТолькоПросмотр = НЕ этоПривилегированныйПользователь;
    Элементы.Дата.ТолькоПросмотр = НЕ этоПривилегированныйПользователь;
КонецПроцедуры

&НаСервереБезКонтекста
Функция получитьСтатусОказанияУслуги(Знач записьКлиентаСсылка)
    Возврат Документы.ЗаписьКлиента.ПолучитьСтатусОказанияУслуги(записьКлиентаСсылка);
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
