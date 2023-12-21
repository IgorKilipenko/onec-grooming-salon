﻿#Область ОписаниеПеременных

// Содержит ссылки на объекты предопределенных групп номенклатуры (Только для чтения)
&НаКлиенте
Перем _ПредопределенныеГруппыНоменклатуры;

// Содержит значения из Перечисление.ТипыНоменклатуры (Только для чтения)
&НаКлиенте
Перем _ТипыНоменклатуры;

#КонецОбласти

#Область ОбработчикиСобытийФормы

// Обработчик события формы ПриОткрытии
// Параметры:
// _ - ЭлементФормы - не используется в текущей реализации
&НаКлиенте
Процедура ПриОткрытии(_)
    инициализация();
    установитьТипНоменклатуры();
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(отказ, __)
    Если Объект.Родитель.Пустая() Тогда
        установитьРодителя();
    КонецЕсли;

    сообщение = проверитьЗаполнениеРодителя();
    Если проверитьЗаполнениеРодителя() <> NULL Тогда
        сообщение.Сообщить();
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ТипНоменклатурыПриИзменении(_)
    установитьРодителя();
КонецПроцедуры

&НаКлиенте
Процедура РодительПриИзменении(_)
    установитьТипНоменклатуры();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийЭлементовШапкиФормы

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура инициализация()
    // Инициализация _ПредопределенныеГруппыНоменклатуры
    имяГруппаТовары = "Товары";
    имяГруппаМатериалы = "Материалы";
    имяГруппаУслуги = "Услуги";

    _ПредопределенныеГруппыНоменклатуры = Новый Структура;
    _ПредопределенныеГруппыНоменклатуры.Вставить(имяГруппаТовары,
        получитьПредопределенныйЭлементНоменклатуры(имяГруппаТовары));
    _ПредопределенныеГруппыНоменклатуры.Вставить(имяГруппаМатериалы,
        получитьПредопределенныйЭлементНоменклатуры(имяГруппаМатериалы));
    _ПредопределенныеГруппыНоменклатуры.Вставить(имяГруппаУслуги,
        получитьПредопределенныйЭлементНоменклатуры(имяГруппаУслуги));

    // Инициализация _ТипыНоменклатуры
    имяТипаНоменклатурыТовар = "Товар";
    имяТипаНоменклатурыМатериал = "Материал";
    имяТипаНоменклатурыУслуга = "Услуга";

    _ТипыНоменклатуры = Новый Структура;
    _ТипыНоменклатуры.Вставить(имяТипаНоменклатурыТовар,
        получитьЗначениеТипаНоменклатуры(имяТипаНоменклатурыТовар));
    _ТипыНоменклатуры.Вставить(имяТипаНоменклатурыМатериал,
        получитьЗначениеТипаНоменклатуры(имяТипаНоменклатурыМатериал));
    _ТипыНоменклатуры.Вставить(имяТипаНоменклатурыУслуга,
        получитьЗначениеТипаНоменклатуры(имяТипаНоменклатурыУслуга));
КонецПроцедуры

&НаКлиенте
Процедура установитьРодителя()
    Если этоТовар() Тогда
        Объект.Родитель = _ПредопределенныеГруппыНоменклатуры.Товары;
    ИначеЕсли этоМатериал() Тогда
        Объект.Родитель = _ПредопределенныеГруппыНоменклатуры.Материалы;
    ИначеЕсли этоУслуга() Тогда
        Объект.Родитель = _ПредопределенныеГруппыНоменклатуры.Услуги;
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура установитьТипНоменклатуры()
    Если Объект.Родитель.Пустая() Тогда
        Возврат;
    КонецЕсли;

    Если Объект.Родитель = _ПредопределенныеГруппыНоменклатуры.Товары Тогда
        Объект.ТипНоменклатуры = _ТипыНоменклатуры.Товар;
    ИначеЕсли Объект.Родитель = _ПредопределенныеГруппыНоменклатуры.Материалы Тогда
        Объект.ТипНоменклатуры = _ТипыНоменклатуры.Материал;
    ИначеЕсли Объект.Родитель = _ПредопределенныеГруппыНоменклатуры.Услуги Тогда
        Объект.ТипНоменклатуры = _ТипыНоменклатуры.Услуга;
    КонецЕсли;
КонецПроцедуры

// Возвращаемое значение:
// 	Булево - Истина, если текущий элемент это Материал
&НаКлиенте
Функция этоМатериал()
    Возврат Объект.ТипНоменклатуры = _ТипыНоменклатуры.Материал;
КонецФункции

// Возвращаемое значение:
// 	Булево - Истина, если текущий элемент это Товар
&НаКлиенте
Функция этоТовар()
    Возврат Объект.ТипНоменклатуры = _ТипыНоменклатуры.Товар;
КонецФункции

// Возвращаемое значение:
// 	Булево - Истина, если текущий элемент это Услуга
&НаКлиенте
Функция этоУслуга()
    Возврат Объект.ТипНоменклатуры = _ТипыНоменклатуры.Услуга;
КонецФункции

// Получить предопределенный элемент метаданных. \
// [прим. разработчика] - нужно вынести в общий модуль
//
// Параметры:
//  полныйПуть - Строка - полный путь к объекту метаданных
//
// Возвращаемое значение:
//  Любой - объект метаданных или NULL
&НаКлиенте
Функция получитьПредопределенныйЭлемент(Знач полныйПуть)
    Попытка
        Возврат ПредопределенноеЗначение(полныйПуть);
    Исключение
        Возврат NULL;
    КонецПопытки;
КонецФункции

// Получить предопределенный элемент Справочника Номенклатура
//
// Параметры:
//  имяЭлемента - Строка - имя элемента
//
// Возвращаемое значение:
//  Любой - значение поля Справочник.Номенклатура или NULL
&НаКлиенте
Функция получитьПредопределенныйЭлементНоменклатуры(Знач имяЭлемента)
    Возврат получитьПредопределенныйЭлемент(СтрШаблон("Справочник.Номенклатура.%1", имяЭлемента));
КонецФункции

// Получить значение из Перечисления ТипыНоменклатуры
//
// Параметры:
//  имяТипаНоменклатуры - Строка - имя ТипаНоменклатуры
//
// Возвращаемое значение:
//  Перечисление.ТипыНоменклатуры - значение из ТипыНоменклатуры или NULL
&НаКлиенте
Функция получитьЗначениеТипаНоменклатуры(Знач имяТипаНоменклатуры)
    Возврат получитьПредопределенныйЭлемент(СтрШаблон("Перечисление.ТипыНоменклатуры.%1", имяТипаНоменклатуры));
КонецФункции

// Выполняет проверку заполнения поля Родитель. Если поле не заполнено - формирует сообщение
// с предупреждением для пользователя.
//
// Возвращаемое значение:
//  СообщениеПользователю - в случае если проверка не пройдена - возвращает сообщение
//  с предупреждением, иначе (в случае успеха) - NULL
&НаКлиенте
Функция проверитьЗаполнениеРодителя()
    сообщение = NULL;

    Если Объект.Родитель.Пустая() Тогда
        сообщение = Новый СообщениеПользователю();
        сообщение.Текст = "Поле ""Родитель"" не заполнено";
        сообщение.Поле = Элементы.Родитель.Имя;
        сообщение.КлючДанных = Объект.Ссылка;
        сообщение.ПутьКДанным = "Объект";
    КонецЕсли;

    Возврат сообщение;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
