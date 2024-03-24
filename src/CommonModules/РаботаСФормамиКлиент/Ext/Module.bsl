﻿#Область ПрограммныйИнтерфейс

// Выполняет проверку является ли источник оповещения подчиненной формой
// Параметры:
//  формаВладелец - Форма
//  имяСобытия - Строка - Имя события из оповещения
//  параметрыСобытия - Произвольный
// Возвращаемое значение:
//  Булево
Функция ПроверитьЭтоОповещениеПодчиненнойФормы(
        Знач формаВладелец, Знач имяСобытия, Знач параметрыСобытия) Экспорт

    Если параметрыСобытия = Неопределено Тогда
        Возврат Ложь;
    КонецЕсли;

    создательФормы = Неопределено;
    параметрыСобытия.Свойство("СоздательФормы", создательФормы);
    Если создательФормы <> формаВладелец.УникальныйИдентификатор Тогда
        Возврат Ложь;
    КонецЕсли;

    Возврат Истина;
КонецФункции

// Параметры:
//  таблицаНоменклатуры - ТаблицаЗначений - Обновляемая таблица цен номенклатуры (приемник данных)
//  структураЦенНоменклатуры - Соответствие, ФиксированноеСоответствие - Структура цен номенклатуры (источник данных)
//      * Ключ - СправочникСсылка.Номенклатура - Номенклатура
//      * Значение - Число - Цена
// Возвращаемое значение:
//  Число - Количество обновленных строк
Функция ОбновитьЦеныНоменклатурыТаблицы(Знач таблицаНоменклатуры, Знач структураЦенНоменклатуры) Экспорт
    списокНоменклатуры = Новый Массив;
    Для Каждого строкаНоменклатуры Из таблицаНоменклатуры Цикл
        Если НЕ ЗначениеЗаполнено(строкаНоменклатуры.Номенклатура) Тогда
            Продолжить;
        КонецЕсли;

        списокНоменклатуры.Добавить(строкаНоменклатуры.Номенклатура);
    КонецЦикла;

    количествоОбновленных = 0;
    Для Каждого строкаНоменклатуры Из таблицаНоменклатуры Цикл
        Если НЕ ЗначениеЗаполнено(строкаНоменклатуры.Номенклатура) Тогда
            Продолжить;
        КонецЕсли;

        ценаНоменклатуры = структураЦенНоменклатуры.Получить(строкаНоменклатуры.Номенклатура);
        Если ценаНоменклатуры = Неопределено Тогда
            сообщение = Новый СообщениеПользователю;
            сообщение.Текст = СтрШаблон("Цена поставщика для номенклатуры ""%1"" не установлена. Номер строки - ""%2"".",
                    Строка(строкаНоменклатуры.Номенклатура), строкаНоменклатуры.НомерСтроки);
            сообщение.Сообщить();
        КонецЕсли;

        строкаНоменклатуры.Цена = ?(ценаНоменклатуры = Неопределено, 0, ценаНоменклатуры);
        Если ценаНоменклатуры <> Неопределено И ценаНоменклатуры <> строкаНоменклатуры.Цена Тогда
            количествоОбновленных = количествоОбновленных + 1;
            строкаНоменклатуры.Цена = ценаНоменклатуры;
        КонецЕсли;
    КонецЦикла;

    Возврат количествоОбновленных;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс
